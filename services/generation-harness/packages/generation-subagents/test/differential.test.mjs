import assert from "node:assert/strict";
import { mkdtempSync, mkdirSync, writeFileSync, readFileSync, rmSync, existsSync, symlinkSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { execFileSync } from "node:child_process";
import test from "node:test";
import { createJiti } from "jiti";
import * as core from "generation-harness-core";
import { InMemoryCredentialStore, fauxProvider, fauxAssistantMessage, fauxToolCall } from "generation-ai";
import * as adaptedChild from "../dist/runs/shared/child-session.js";
import * as adaptedParallel from "../dist/runs/shared/parallel-utils.js";
import * as adaptedWorkflow from "../dist/workflows/scripted-workflow.js";

const pinned = "312082429bda07714fe0fe7729fe8d4935de4c5a";
const checkout = process.env.GENERATION_SUBAGENTS_UPSTREAM_CHECKOUT;
assert.ok(checkout, "Set GENERATION_SUBAGENTS_UPSTREAM_CHECKOUT to an isolated checkout of the pinned upstream; this command never downloads or installs it.");
assert.equal(execFileSync("git", ["-C", checkout, "rev-parse", "HEAD"], { encoding: "utf8" }).trim(), pinned);
const harness = resolve(dirname(fileURLToPath(import.meta.url)), "../../..");
const modules = join(checkout, "node_modules");
const linked = !existsSync(modules);
if (linked) symlinkSync(join(harness, "node_modules"), modules, "dir");
process.once("exit", () => { if (linked) rmSync(modules); });
const alias = {};
for (const [from, to] of [["@earendil-works/pi-coding-agent", "generation-harness-core"], ["@earendil-works/pi-agent-core", "generation-agent-core"], ["@earendil-works/pi-ai/compat", "generation-ai/compat"], ["@earendil-works/pi-ai", "generation-ai"], ["@earendil-works/pi-tui", "generation-tui"]]) alias[from] = fileURLToPath(import.meta.resolve(to));
const jiti = createJiti(import.meta.url, { moduleCache: false, tryNative: false, alias });
const originalChild = await jiti.import(join(checkout, "src/runs/shared/child-session.ts"));
const originalParallel = await jiti.import(join(checkout, "src/runs/shared/parallel-utils.ts"));
const originalWorkflow = await jiti.import(join(checkout, "src/workflows/scripted-workflow.ts"));
const runtime = () => core.ModelRuntime.create({ credentials: new InMemoryCredentialStore(), modelsPath: null, refreshOnCreate: false });

async function childScenario(implementation, suffix, root, extension = "mjs") {
	const cwd = join(root, suffix); mkdirSync(cwd);
	const agentDir = join(cwd, "agent");
	const previous = process.env.PI_CODING_AGENT_DIR; process.env.PI_CODING_AGENT_DIR = agentDir;
	const parent = await runtime(); const faux = fauxProvider({ models: [{ id: "thinker", reasoning: true }] }); parent.registerNativeProvider(faux.provider);
	const pi = { ...core, ModelRuntime: { create: runtime } };
	const factory = implementation.createDefaultChildSessionFactory({ loadPiCodingAgent: async () => pi, agentDir });
	const file = join(cwd, `state.${extension}`);
	writeFileSync(file, `${extension === "ts" ? "enum Initial { Zero=0 };let counter=Initial.Zero;" : "let counter=0;"}export default api=>{const value=++counter;api.registerTool({name:"fixture",label:"Fixture",description:"fixture",parameters:{type:"object",properties:{}},execute:async()=>({content:[{type:"text",text:String(value)}],details:undefined})});};`);
	const result = { output: [], thinking: [], parentProviders: [], errors: [] };
	try {
		for (let index = 0; index < 2; index++) {
			faux.setResponses([fauxAssistantMessage(fauxToolCall("fixture", {}), { stopReason: "toolUse" }), ctx => fauxAssistantMessage(ctx.messages.find(m => m.role === "toolResult").content[0].text)]);
			const child = await factory.create({ cwd, parentProviderRegistry: parent, storage: { kind: "dir", sessionDir: join(cwd, "sessions") }, model: "faux/thinker:high", tools: ["fixture"], extensionPaths: [file], hooks: [], ambientExtensions: false, noSkills: true, noContextFiles: true, runtime: { fanoutChild: false, depth: 1, fast: false, waitTool: { enabled: true } }, onExtensionError: error => result.errors.push(String(error.error)) });
			await child.prompt("use fixture");
			result.output.push(child.messages.filter(m => m.role === "assistant").at(-1).content[0].text);
			const entries = readFileSync(child.sessionFile, "utf8").trim().split("\n").map(JSON.parse);
			result.thinking.push(entries.find(e => e.type === "thinking_level_change").thinkingLevel);
			await child.dispose();
		}
		result.parentProviders = [...parent.getRegisteredProviderIds()]; return result;
	} finally { await factory.dispose(); if (previous === undefined) delete process.env.PI_CODING_AGENT_DIR; else process.env.PI_CODING_AGENT_DIR = previous; }
}
for (const extension of ["ts", "mjs"]) test(`pinned differential: native ${extension} extension state, tools, thinking, and lifecycle`, async t => {
	const root = mkdtempSync(join(tmpdir(), "generation-differential-")); t.after(() => rmSync(root, { recursive: true, force: true }));
	const baseline = await childScenario(originalChild, "reference", root, extension);
	const actual = await childScenario(adaptedChild, "adapted", root, extension);
	assert.deepEqual(actual, baseline);
	assert.deepEqual(actual.output, extension === "ts" ? ["1", "1"] : ["1", "2"]);
	assert.deepEqual(actual.thinking, ["high", "high"]);
	assert.deepEqual(actual.errors, []);
});

test("pinned differential: concurrent scheduling preserves task identity and semaphore behavior", async () => {
	async function scenario(implementation) {
		let active = 0; let maximum = 0;
		const semaphore = new implementation.Semaphore(2);
		const outputs = await implementation.mapConcurrent([0, 1, 2, 3], 4, async (value, index) => { active++; maximum = Math.max(maximum, active); await new Promise(resolve => setTimeout(resolve, 5 * (4 - value))); active--; return { index, output: `task-${value}` }; }, semaphore);
		return { maximum, outputs, formatted: implementation.aggregateParallelOutputs(outputs.map(r => ({ agent: `agent-${r.index}`, taskIndex: r.index, output: r.output, exitCode: r.index === 1 ? 1 : 0 }))) };
	}
	assert.deepEqual(await scenario(adaptedParallel), await scenario(originalParallel));
});

test("pinned differential: workflow VM execution, stable child keys, and frozen inputs", async () => {
	async function scenario(implementation) {
		const launched = [];
		const result = await implementation.runWorkflowScript({
			script: 'const children = await runs.all([{key:"first",agent:"worker",task:args.task},{key:"second",agent:"worker",task:"other"}]); return {output:children.map(child=>child.output),frozen:Object.isFrozen(args)};',
			args: { task: "offline" },
			async launch(key, params) { launched.push({ key, task: params.task }); return { key, ok: true, output: params.task, artifactPaths: [] }; },
			async status(key) { return { key, ok: true, output: "done", artifactPaths: [] }; },
		});
		return { launched, value: result.value };
	}
	assert.deepEqual(await scenario(adaptedWorkflow), await scenario(originalWorkflow));
});
