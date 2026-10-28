import assert from "node:assert/strict";
import { mkdtempSync, mkdirSync, writeFileSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test from "node:test";
import { ModelRuntime, createAgentSession, DefaultResourceLoader, SettingsManager, SessionManager } from "generation-harness-core";
import { InMemoryCredentialStore, fauxProvider, fauxAssistantMessage, fauxToolCall } from "generation-ai";
import { executeSubagent, discoverAgents, createSubagentExtension } from "../dist/index.js";
import { createDefaultChildSessionFactory } from "../dist/runs/shared/child-session.js";
import { buildInProcessChildLaunch } from "../dist/runs/shared/child-launch.js";
import { childCacheRetentionEnv, pinChildCacheRetention } from "../dist/shared/child-cache-retention.js";

const aiEntry = import.meta.resolve("generation-ai");
const toolSource = (body = '"custom-result"') => `api.registerTool({name:"fixture_tool",label:"Fixture",description:"offline fixture",parameters:{type:"object",properties:{}},execute:async()=>({content:[{type:"text",text:${body}}],details:undefined})});`;
async function fixture(t) {
	const cwd = mkdtempSync(join(tmpdir(), "generation-parity-"));
	t.after(() => rmSync(cwd, { recursive: true, force: true }));
	const runtime = await ModelRuntime.create({ credentials: new InMemoryCredentialStore(), modelsPath: null, refreshOnCreate: false });
	const faux = fauxProvider({ models: [{ id: "thinker", reasoning: true }] });
	runtime.registerNativeProvider(faux.provider);
	return { cwd, faux, runtime, context: { cwd, agentDir: join(cwd, "agent"), sessionDir: join(cwd, "sessions"), parentSessionId: "parent", modelRuntime: runtime, parentModel: faux.getModel("thinker"), agents: [{ name: "worker", tools: [] }] } };
}
function requestTool(faux) {
	faux.setResponses([
		fauxAssistantMessage(fauxToolCall("fixture_tool", {}), { stopReason: "toolUse" }),
		ctx => fauxAssistantMessage(ctx.messages.find(m => m.role === "toolResult").content[0].text),
	]);
}
function providerExtension(file, provider, output) {
	writeFileSync(file, `import {fauxProvider,fauxAssistantMessage} from ${JSON.stringify(aiEntry)};
		export default api=>{const child=fauxProvider({provider:${JSON.stringify(provider)},models:[{id:"model",reasoning:true}]});
		child.setResponses([fauxAssistantMessage(${JSON.stringify(output)})]);api.registerProvider(child.provider);};`);
}

test("review regression: child and sibling provider overrides do not mutate their parent", async t => {
	const { cwd, faux, runtime, context } = await fixture(t);
	const extensions = [join(cwd, "first.mjs"), join(cwd, "second.mjs")];
	providerExtension(extensions[0], "faux", "first-provider");
	providerExtension(extensions[1], "faux", "second-provider");
	const result = await executeSubagent({ tasks: [{ agent: "first", task: "first" }, { agent: "second", task: "second" }] }, {
		...context, agents: extensions.map((file, i) => ({ name: i ? "second" : "first", model: "faux/model", tools: [], subagentOnlyExtensions: [file] })),
	});
	assert.equal(result.status, "completed", JSON.stringify(result));
	assert.deepEqual(result.results.map(r => r.output), ["first-provider", "second-provider"]);
	assert.deepEqual(runtime.getRegisteredProviderIds(), ["faux"]);
	assert.equal(runtime.getModel("faux", "model"), undefined);
	faux.setResponses([fauxAssistantMessage("parent-still-owned")]);
	const parent = await executeSubagent({ agent: "worker", task: "parent provider" }, context);
	assert.equal(parent.results[0].output, "parent-still-owned");
});

test("review regression: child-only providers load before child model and thinking resolution", async t => {
	const { cwd, faux, runtime, context } = await fixture(t);
	const extension = join(cwd, "provider.mjs");
	providerExtension(extension, "child-only", "child-model-used");
	const result = await executeSubagent({ agent: "worker", task: "child model", model: "child-only/model:high" }, {
		...context, agents: [{ name: "worker", tools: [], subagentOnlyExtensions: [extension] }],
	});
	assert.equal(result.status, "completed", JSON.stringify(result));
	assert.equal(result.results[0].output, "child-model-used");
	assert.equal(faux.state.callCount, 0);
	assert.equal(runtime.getModel("child-only", "model"), undefined);
	assert.match(readFileSync(result.results[0].sessionFile, "utf8"), /"thinkingLevel":"high"/);
});

test("review regression: agent-local extension and path-like tools resolve from the definition directory", async t => {
	const { cwd, faux, context } = await fixture(t);
	const dir = join(cwd, ".generation", "agents");
	mkdirSync(join(dir, "tools"), { recursive: true });
	writeFileSync(join(dir, "tools", "custom.mjs"), `export default api=>{${toolSource()}}`);
	for (const field of ["subagentOnlyExtensions", "tools"]) {
		writeFileSync(join(dir, "worker.md"), `---\nname: worker\n${field === "tools" ? "tools: fixture_tool, ./tools/custom.mjs" : "tools: fixture_tool\nsubagentOnlyExtensions: ./tools/custom.mjs"}\n---\nOnly this task.`);
		requestTool(faux);
		const result = await executeSubagent({ agent: "worker", task: "execute custom tool" }, { ...context, agents: discoverAgents(cwd, context.agentDir) });
		assert.equal(result.status, "completed", JSON.stringify(result));
		assert.equal(result.results[0].output, "custom-result");
	}
});

test("review regression: transformed native extension modules have fresh state in independent children", async t => {
	const { cwd, faux, context } = await fixture(t);
	const extension = join(cwd, "state.ts");
	// A non-erasable enum exercises the native loader's Jiti transform rather
	// than Node's permanent ESM cache. The separate boundary test covers ESM.
	writeFileSync(extension, `enum Initial { Zero = 0 }; let count=Initial.Zero; export default api=>{const instance=++count;${toolSource("String(instance)")}}`);
	const outputs = [];
	for (let i = 0; i < 2; i++) {
		requestTool(faux);
		const result = await executeSubagent({ agent: "worker", task: "instance" }, { ...context, agents: [{ name: "worker", tools: ["fixture_tool"], subagentOnlyExtensions: [extension] }] });
		assert.equal(result.status, "completed", JSON.stringify(result));
		outputs.push(result.results[0].output);
	}
	assert.deepEqual(outputs, ["1", "1"]);
});

test("native ESM cache boundary is recorded, not falsely claimed to be isolated", async t => {
	const { cwd, faux, context } = await fixture(t);
	const extension = join(cwd, "state.mjs");
	writeFileSync(extension, `let count=0; export default api=>{const instance=++count;${toolSource("String(instance)")}}`);
	const outputs = [];
	for (let i = 0; i < 2; i++) {
		requestTool(faux);
		const result = await executeSubagent({ agent: "worker", task: "instance" }, { ...context, agents: [{ name: "worker", tools: ["fixture_tool"], subagentOnlyExtensions: [extension] }] });
		assert.equal(result.status, "completed", JSON.stringify(result));
		outputs.push(result.results[0].output);
	}
	assert.deepEqual(outputs, ["1", "2"], "Core's native ESM module map is not cleared by public resource reload");
});

test("review regression: explicit model suffix overrides agent thinking without losing configured defaults", async t => {
	const { faux, context } = await fixture(t);
	context.agents[0].thinking = "low";
	for (const [override, expected] of [[undefined, "low"], ["faux/thinker:high", "high"]]) {
		faux.setResponses([fauxAssistantMessage("done")]);
		const result = await executeSubagent({ agent: "worker", task: "think", ...(override ? { model: override } : {}) }, context);
		assert.equal(result.status, "completed", JSON.stringify(result));
		const entries = readFileSync(result.results[0].sessionFile, "utf8").trim().split("\n").map(JSON.parse);
		assert.equal(entries.find(e => e.type === "thinking_level_change").thinkingLevel, expected);
	}
});

test("native SDK search definitions execute as selected child-only tools without changing Core defaults", async t => {
	const { cwd, faux, context } = await fixture(t);
	writeFileSync(join(cwd, "fixture-file.txt"), "offline");
	faux.setResponses([
		fauxAssistantMessage(fauxToolCall("ls", { path: "." }), { stopReason: "toolUse" }),
		ctx => fauxAssistantMessage(ctx.messages.find(m => m.role === "toolResult").content[0].text),
	]);
	const result = await executeSubagent({ agent: "worker", task: "list fixture" }, { ...context, agents: [{ name: "worker", tools: ["ls"] }] });
	assert.equal(result.status, "completed", JSON.stringify(result));
	assert.match(result.results[0].output, /fixture-file.txt/);
});

test("child cache retention maps to both native Generation namespaces without changing parent options", () => {
	const env = { GENERATION_SUBAGENT_CACHE_RETENTION: "short" };
	assert.deepEqual(childCacheRetentionEnv(env), { GENERATION_AI_CACHE_RETENTION: "short", GENERATION_HARNESS_CACHE_RETENTION: "short" });
	let captured;
	const agent = { streamFunction: (_model, _context, options) => { captured = options; return "fixture-stream"; } };
	pinChildCacheRetention(agent, env);
	const parentOptions = { env: { GENERATION_AI_CACHE_RETENTION: "long", OTHER: "preserved" } };
	assert.equal(agent.streamFunction({}, {}, parentOptions), "fixture-stream");
	assert.equal(captured.env.GENERATION_AI_CACHE_RETENTION, "short");
	assert.equal(captured.env.GENERATION_HARNESS_CACHE_RETENTION, "short");
	assert.equal(captured.env.OTHER, "preserved");
	assert.equal(parentOptions.env.GENERATION_AI_CACHE_RETENTION, "long");
});

test("required extension startup errors fail closed and shut down before inference", async t => {
	const { cwd, faux, runtime, context } = await fixture(t);
	const extension = join(cwd, "broken.mjs");
	const marker = join(cwd, "shutdown");
	writeFileSync(extension, `import {writeFileSync} from "node:fs";export default api=>{api.on("session_start",()=>{throw Error("startup failed")});api.on("session_shutdown",()=>writeFileSync(${JSON.stringify(marker)},"closed"));};`);
	const factory = createDefaultChildSessionFactory({ agentDir: context.agentDir, createModelRuntime: () => ModelRuntime.create({ credentials: new InMemoryCredentialStore(), modelsPath: null, refreshOnCreate: false }) });
	t.after(() => factory.dispose());
	const launch = buildInProcessChildLaunch({ cwd, host: "parent", childAgentName: "worker", childIndex: 0, sessionEnabled: true, sessionDir: context.sessionDir, model: "faux/thinker", tools: [], requiredExtensions: [{ id: "required-fixture", path: extension }], inheritProjectContext: false, inheritGlobalContext: false, inheritSkills: false });
	await assert.rejects(factory.create({ ...launch.session, parentProviderRegistry: runtime }), /startup failed/);
	assert.equal(faux.state.callCount, 0);
	assert.equal(readFileSync(marker, "utf8"), "closed");
});

test("native default extension registers management/activation and model-only orchestration without leaking child tools", async t => {
	const { cwd, runtime, context } = await fixture(t);
	const settingsManager = SettingsManager.inMemory({ cacheWarming: "off", retry: { enabled: false } });
	const loader = new DefaultResourceLoader({ cwd, agentDir: context.agentDir, settingsManager, noExtensions: true, noSkills: true, noThemes: true, noContextFiles: true, extensionFactories: [createSubagentExtension()] });
	await loader.reload();
	const { session } = await createAgentSession({ cwd, agentDir: context.agentDir, modelRuntime: runtime, model: context.parentModel, settingsManager, resourceLoader: loader, sessionManager: SessionManager.create(cwd, join(cwd, "parent")) });
	t.after(async () => { try { await session.extensionRunner.emit({ type: "session_shutdown", reason: "quit" }); } finally { session.dispose(); } });
	await session.bindExtensions({ mode: "print" });
	assert.equal(session.getAllTools().find(tool => tool.name === "subagent").exposure, "model-only");
	assert.ok(session.getAllTools().some(tool => tool.name === "bg_wait"));
	assert.ok(session.getAllTools().some(tool => tool.name === "subagents_enable"));
	assert.ok(!session.getAllTools().some(tool => tool.name === "fixture_tool"));
});
