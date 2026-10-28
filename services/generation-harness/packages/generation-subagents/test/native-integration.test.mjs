import assert from "node:assert/strict";
import { mkdtempSync, mkdirSync, writeFileSync, readFileSync, existsSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { setTimeout as delay } from "node:timers/promises";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import test from "node:test";
import { createAgentSession, DefaultResourceLoader, ModelRuntime, SessionManager, SettingsManager } from "generation-harness-core";
import { InMemoryCredentialStore, fauxProvider, fauxAssistantMessage, fauxToolCall } from "generation-ai";
import { createSubagentExtension } from "../dist/index.js";
import { deliverStopRequest } from "../dist/runs/background/control-channel.js";
const aiEntry = import.meta.resolve("generation-ai");

async function fixture(t, config = {}, registerChildMetadata = true) {
	const cwd = mkdtempSync(join(tmpdir(), "generation-native-integration-"));
	const agentDir = join(cwd, "agent");
	const previous = process.env.GENERATION_HARNESS_AGENT_DIR;
	process.env.GENERATION_HARNESS_AGENT_DIR = agentDir;
	t.after(() => { if (previous === undefined) delete process.env.GENERATION_HARNESS_AGENT_DIR; else process.env.GENERATION_HARNESS_AGENT_DIR = previous; rmSync(cwd, { recursive: true, force: true }); });
	const configDir = join(agentDir, "extensions", "subagent");
	mkdirSync(configDir, { recursive: true });
	writeFileSync(join(configDir, "config.json"), JSON.stringify({ toolActivation: "eager", defaultSubagentContext: "fresh", ...config }));
	const extension = join(cwd, "offline-provider.mjs");
	writeFileSync(extension, `import {fauxProvider,fauxAssistantMessage,fauxToolCall} from ${JSON.stringify(aiEntry)};
		import {writeFileSync,existsSync} from "node:fs";import {join} from "node:path";
		export default api=>{let tag="default";const fake=fauxProvider({provider:"offline",models:[{id:"model"}]});
		fake.setResponses([async ctx=>{const task=ctx.messages.filter(m=>m.role==="user").at(-1).content.map(x=>x.text??"").join(" ");
		tag=task.includes("TASK-ONE")?"one":task.includes("TASK-TWO")?"two":"default";
		if(tag!=="default"){const root=${JSON.stringify(cwd)};writeFileSync(join(root,"started-"+tag),"started");const deadline=Date.now()+5000;while(!existsSync(join(root,"started-one"))||!existsSync(join(root,"started-two"))){if(Date.now()>deadline)throw Error("parallel children did not overlap");await new Promise(resolve=>setTimeout(resolve,10));}}
		else await new Promise(resolve=>setTimeout(resolve,task.includes("slow-cancel")?10000:task.includes("parent-exit")?2000:750));
		return fauxAssistantMessage(fauxToolCall("write",{path:"child-completed.txt",content:"detached-proof"}),{stopReason:"toolUse"});},()=>fauxAssistantMessage("OFFLINE-CHILD-COMPLETE:"+tag)]);
		api.registerProvider(fake.provider);};`);
	const agents = join(cwd, ".generation", "agents"); mkdirSync(agents, { recursive: true });
	writeFileSync(join(agents, "offline.md"), `---\nname: offline\ndescription: Offline integration child\nmodel: offline/model\ntools: write\nsubagentOnlyExtensions: ${extension}\ninheritProjectContext: false\ninheritSkills: false\n---\nComplete the offline task.`);
	const runtime = await ModelRuntime.create({ credentials: new InMemoryCredentialStore(), modelsPath: null, refreshOnCreate: false });
	const faux = fauxProvider({ models: [{ id: "parent" }] }); runtime.registerNativeProvider(faux.provider);
	if (registerChildMetadata) runtime.registerNativeProvider(fauxProvider({ provider: "offline", models: [{ id: "model" }] }).provider);
	const sessions = new Set();
	async function parent(sessionFile) {
		const settings = SettingsManager.inMemory({ cacheWarming: "off", retry: { enabled: false }, compaction: { enabled: false } });
		const loader = new DefaultResourceLoader({ cwd, agentDir, settingsManager: settings, noExtensions: true, noSkills: true, noPromptTemplates: true, noThemes: true, noContextFiles: true, extensionFactories: [createSubagentExtension()] });
		await loader.reload();
		const { session } = await createAgentSession({ cwd, agentDir, modelRuntime: runtime, model: faux.getModel("parent"), settingsManager: settings, resourceLoader: loader, sessionManager: sessionFile ? SessionManager.open(sessionFile) : SessionManager.create(cwd, join(cwd, "parent-sessions")) });
		// An RPC client supplies a UI context; without one the upstream contract
		// deliberately drains background work before a one-shot prompt returns.
		await session.bindExtensions({ mode: "rpc", uiContext: { ...session.extensionRunner.getUIContext() } }); sessions.add(session); return session;
	}
	async function close(session) { if (!sessions.delete(session)) return; try { await session.extensionRunner.emit({ type: "session_shutdown", reason: "quit" }); } finally { session.dispose(); } }
	t.after(async () => { for (const session of sessions) await close(session); });
	async function invoke(session, args, tool = "subagent") {
		faux.setResponses([fauxAssistantMessage(fauxToolCall(tool, args), { stopReason: "toolUse" }), fauxAssistantMessage("PARENT-COMPLETE")]);
		await session.prompt(`Offline operation ${tool}`);
		const result = session.messages.filter(m => m.role === "toolResult" && m.toolName === tool).at(-1);
		assert.ok(result, "native tool result must be persisted");
		assert.ok(!result.isError, JSON.stringify(result));
		return result;
	}
	return { cwd, agentDir, runtime, faux, parent, close, invoke };
}
async function until(read, predicate, description, timeout = 15000) {
	const started = Date.now(); let value;
	while (Date.now() - started < timeout) { value = read(); if (predicate(value)) return value; await delay(25); }
	assert.fail(`${description}: ${JSON.stringify(value)}`);
}
function status(dir) { try { return JSON.parse(readFileSync(join(dir, "status.json"), "utf8")); } catch { return undefined; } }
function cleanupRun(t, details) { t.after(() => { const current = status(details.asyncDir); if (current?.state === "running") deliverStopRequest({ asyncDir: details.asyncDir, pid: current.pid, source: "offline-test-cleanup" }); }); }

test("native foreground default executes an agent's custom provider and built-in tool through the standard parent loop", { timeout: 30000 }, async t => {
	const f = await fixture(t); const session = await f.parent();
	const result = await f.invoke(session, { agent: "offline", task: "foreground", async: false });
	assert.match(result.content[0].text, /OFFLINE-CHILD-COMPLETE/);
	assert.equal(readFileSync(join(f.cwd, "child-completed.txt"), "utf8"), "detached-proof");
	assert.equal(result.details.results[0].agent, "offline");
});

test("native default parallel workflow launches independent children concurrently with stable task identity", { timeout: 30000 }, async t => {
	const f = await fixture(t); const session = await f.parent();
	const result = await f.invoke(session, { workflow: "parallel", args: { tasks: [{ agent: "offline", task: "TASK-ONE" }, { agent: "offline", task: "TASK-TWO" }] }, async: false });
	assert.match(JSON.stringify(result), /OFFLINE-CHILD-COMPLETE:one/);
	assert.match(JSON.stringify(result), /OFFLINE-CHILD-COMPLETE:two/);
	assert.ok(existsSync(join(f.cwd, "started-one")) && existsSync(join(f.cwd, "started-two")));
});

test("native default resolves a provider declared only in the child's extension", { timeout: 30000 }, async t => {
	const f = await fixture(t, {}, false); const session = await f.parent();
	assert.equal(f.runtime.getModel("offline", "model"), undefined);
	const result = await f.invoke(session, { agent: "offline", task: "child-only provider", async: false });
	assert.match(JSON.stringify(result), /OFFLINE-CHILD-COMPLETE/);
	assert.equal(f.runtime.getModel("offline", "model"), undefined);
});

test("native detached child survives parent disposal, is recovered by a new parent and can be inspected and awaited", { timeout: 30000 }, async t => {
	const f = await fixture(t); const first = await f.parent();
	const launched = await f.invoke(first, { agent: "offline", task: "background-survival", async: true });
	const details = launched.details; cleanupRun(t, details);
	assert.ok(details.asyncId && details.asyncDir, JSON.stringify(launched));
	assert.ok(status(details.asyncDir)?.pid, "a real detached process must own the run");
	assert.equal(status(details.asyncDir).state, "running", "RPC must return control while the detached child is still active");
	assert.ok(!existsSync(join(f.cwd, "child-completed.txt")), "child must not have finished before parent disposal");
	const parentFile = first.sessionFile;
	await f.close(first);
	await until(() => status(details.asyncDir), s => s && s.state !== "running", "detached child must settle after parent disposal");
	assert.equal(status(details.asyncDir).state, "complete", JSON.stringify(status(details.asyncDir)));
	assert.equal(readFileSync(join(f.cwd, "child-completed.txt"), "utf8"), "detached-proof");
	const recovered = await f.parent(parentFile);
	const inspected = await f.invoke(recovered, { action: "status", id: details.asyncId });
	assert.match(inspected.content.map(c => c.text ?? "").join("\n"), /complete|OFFLINE-CHILD-COMPLETE/i);
	const waited = await f.invoke(recovered, { id: details.asyncId, timeoutMs: 1000 }, "bg_wait");
	assert.match(JSON.stringify(waited), /complete|result/i);
	assert.ok(existsSync(join(details.asyncDir, "status.json")));
});

test("native detached child can be cancelled without corrupting another run", { timeout: 30000 }, async t => {
	const f = await fixture(t); const session = await f.parent();
	const first = (await f.invoke(session, { agent: "offline", task: "slow-cancel", async: true })).details; cleanupRun(t, first);
		const second = (await f.invoke(session, { agent: "offline", task: "successful-peer", async: true })).details; cleanupRun(t, second);
	await f.invoke(session, { action: "stop", id: first.asyncId });
	const stopped = await until(() => status(first.asyncDir), s => s && s.state !== "running", "stopped child must settle");
	const completed = await until(() => status(second.asyncDir), s => s && s.state !== "running", "unrelated child must settle");
	assert.equal(stopped.state, "stopped", JSON.stringify(stopped));
	assert.equal(completed.state, "complete", JSON.stringify(completed));
});

test("native workflow tool executes a saved script, awaits a child, and persists its receipt", { timeout: 30000 }, async t => {
	const f = await fixture(t); const session = await f.parent();
	const script = join(f.cwd, "workflow.js");
	writeFileSync(script, 'const child = await runs.run("offline-step", {agent:"offline",task:"saved workflow child"}); return {output:child.output};');
	const result = await f.invoke(session, { workflow: script, async: false });
	assert.match(JSON.stringify(result), /OFFLINE-CHILD-COMPLETE/);
	assert.equal(readFileSync(join(f.cwd, "child-completed.txt"), "utf8"), "detached-proof");
	assert.ok(result.details.runId, "workflow must retain its native run identity");
});

test("native nested delegation executes a permitted leaf and enforces an inherited deny-all agent list", { timeout: 30000 }, async t => {
	const f = await fixture(t, { maxSubagentDepth: 2 });
	const extension = join(f.cwd, "nested-provider.mjs");
	writeFileSync(extension, `import {fauxProvider,fauxAssistantMessage,fauxToolCall} from ${JSON.stringify(aiEntry)};
		export default api=>{const fake=fauxProvider({provider:"nested",models:[{id:"model"}]});
		fake.setResponses([fauxAssistantMessage(fauxToolCall("subagent",{agent:"offline",task:"nested leaf",async:false}),{stopReason:"toolUse"}),ctx=>{const result=ctx.messages.find(m=>m.role==="toolResult"&&m.toolName==="subagent");return fauxAssistantMessage(result.isError?"NESTED-DENIED":"NESTED-COMPLETE:"+result.content.map(c=>c.text??"").join(" "));}]);api.registerProvider(fake.provider);};`);
	f.runtime.registerNativeProvider(fauxProvider({ provider: "nested", models: [{ id: "model" }] }).provider);
	const definition = join(f.cwd, ".generation", "agents", "nester.md");
	const agent = deny => `---\nname: nester\ndescription: Offline nested runtime fixture\nmodel: nested/model\ntools: subagent\nsubagentOnlyExtensions: ${extension}\n${deny ? "allowedAgents:\n" : ""}inheritProjectContext: false\ninheritSkills: false\n---\nDelegate the permitted leaf task.`;
	writeFileSync(definition, agent(false));
	const session = await f.parent();
	const permitted = await f.invoke(session, { agent: "nester", task: "nested parent", async: false });
	assert.match(JSON.stringify(permitted), /NESTED-COMPLETE/);
	assert.match(JSON.stringify(permitted), /OFFLINE-CHILD-COMPLETE/);
	writeFileSync(definition, agent(true));
	const denied = await f.invoke(session, { agent: "nester", task: "nested denied", async: false });
	assert.match(JSON.stringify(denied), /NESTED-DENIED/);
});

test("native detached runner survives its launching process exiting and is recovered from durable artifacts", { timeout: 30000 }, async t => {
	const f = await fixture(t);
	const report = join(f.cwd, "reports", "process-run.json");
	const launched = spawnSync(process.execPath, [fileURLToPath(new URL("./support/offline-parent-process.mjs", import.meta.url)), f.cwd, report], { env: process.env, encoding: "utf8", timeout: 15000 });
	assert.equal(launched.status, 0, launched.stderr);
	const details = JSON.parse(readFileSync(report, "utf8")); cleanupRun(t, details);
	assert.equal(status(details.asyncDir).state, "running", "launcher process must exit before its detached child finishes");
	const recovered = await f.parent(details.parentFile);
	const inspected = await f.invoke(recovered, { action: "status", id: details.asyncId });
	assert.match(JSON.stringify(inspected), /running|OFFLINE-CHILD-COMPLETE/);
	const completed = await until(() => status(details.asyncDir), value => value && value.state !== "running", "child must finish after launcher exit");
	assert.equal(completed.state, "complete", JSON.stringify(completed));
	assert.equal(readFileSync(join(f.cwd, "child-completed.txt"), "utf8"), "detached-proof");
});
