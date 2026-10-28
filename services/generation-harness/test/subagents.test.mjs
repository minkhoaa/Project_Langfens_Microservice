import "./offline.mjs";
import assert from "node:assert/strict";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import test from "node:test";
import {
	createAgentSession,
	DefaultResourceLoader,
	ModelRuntime,
	SessionManager,
	SettingsManager,
} from "generation-harness-core";
import {
	InMemoryCredentialStore,
	fauxAssistantMessage,
	fauxProvider,
	fauxToolCall,
} from "generation-ai";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");

async function fixture(t) {
	const entry = join(root, "packages/generation-subagents/dist/index.js");
	assert.ok(existsSync(entry), "local subagent execution implementation must exist");
	const api = await import(pathToFileURL(entry).href);
	const cwd = mkdtempSync(join(tmpdir(), "generation-child-"));
	t.after(() => rmSync(cwd, { recursive: true, force: true }));
	const modelRuntime = await ModelRuntime.create({
		credentials: new InMemoryCredentialStore(),
		modelsPath: null,
		refreshOnCreate: false,
	});
	const faux = fauxProvider({
		models: [{ id: "parent" }, { id: "agent" }, { id: "override" }],
	});
	modelRuntime.registerNativeProvider(faux.provider);
	return {
		api,
		cwd,
		faux,
		context: {
			cwd,
			agentDir: join(cwd, "agent"),
			sessionDir: join(cwd, "sessions"),
			parentSessionId: "parent-sentinel",
			modelRuntime,
			parentModel: faux.getModel("parent"),
			agents: [
				{
					name: "worker",
					systemPrompt: "Complete only the delegated task.",
					tools: ["read"],
				},
			],
		},
	};
}

test("single delegation uses a real local child session and file tool with usage and progress", async (t) => {
	const { api, cwd, faux, context } = await fixture(t);
	writeFileSync(join(cwd, "tiếng Việt file.txt"), "child local data");
	faux.setResponses([
		fauxAssistantMessage(fauxToolCall("read", { path: "tiếng Việt file.txt" }), { stopReason: "toolUse" }),
		(ctx) => {
			assert.match(ctx.messages.find((m) => m.role === "toolResult").content[0].text, /child local data/);
			return {
				...fauxAssistantMessage("read-complete"),
				usage: { input: 5, output: 3, cacheRead: 0, cacheWrite: 0, totalTokens: 8, cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 } },
			};
		},
	]);
	const events = [];
	const result = await api.executeSubagent(
		{ agent: "worker", task: "Read the file" },
		{ ...context, onProgress: (e) => events.push(e) },
	);
	assert.equal(result.status, "completed");
	assert.equal(result.results.length, 1);
	const child = result.results[0];
	assert.equal(child.output, "read-complete");
	assert.equal(child.model, "faux/parent");
	assert.notEqual(child.sessionId, "parent-sentinel");
	assert.ok(child.sessionFile.startsWith(context.sessionDir + "/"));
	assert.ok(existsSync(child.sessionFile));
	assert.ok(child.usage.totalTokens > 0);
	assert.equal(faux.state.callCount, 2);
	assert.ok(events.some((e) => e.status === "running"));
	assert.ok(events.some((e) => e.tool === "read"));
	assert.equal(events.at(-1).status, "completed");
	assert.match(readFileSync(child.sessionFile, "utf8"), /read-complete/);
});

test("ordered delegation propagates previous output and isolates histories with model override precedence", async (t) => {
	const { api, faux, context } = await fixture(t);
	context.agents[0].model = "faux/agent";
	faux.setResponses([
		(_ctx, _opts, _state, model) => {
			assert.equal(model.id, "override");
			return fauxAssistantMessage("FIRST-RESULT");
		},
		(ctx, _opts, _state, model) => {
			assert.equal(model.id, "agent");
			const users = ctx.messages.filter((m) => m.role === "user");
			assert.equal(users.length, 1);
			assert.deepEqual(users[0].content, [{ type: "text", text: "Second sees FIRST-RESULT, root original task" }]);
			return fauxAssistantMessage("SECOND-RESULT");
		},
	]);
	const result = await api.executeSubagent(
		{
			task: "original task",
			chain: [
				{ agent: "worker", task: "First task", model: "faux/override" },
				{ agent: "worker", task: "Second sees {previous}, root {task}" },
			],
		},
		context,
	);
	assert.equal(result.status, "completed", JSON.stringify(result));
	assert.deepEqual(result.results.map((r) => r.output), ["FIRST-RESULT", "SECOND-RESULT"]);
	assert.deepEqual(result.results.map((r) => r.model), ["faux/override", "faux/agent"]);
	assert.notEqual(result.results[0].sessionId, result.results[1].sessionId);
});

test("parallel children run concurrently and retain input order despite failure", async (t) => {
	const { api, faux, context } = await fixture(t);
	let started = 0;
	let release;
	const bothStarted = new Promise(resolve => { release = resolve; });
	const respond = async (ctx) => {
		const prompt = ctx.messages.find(m => m.role === "user").content[0].text;
		if (++started === 2) release();
		await bothStarted;
		return prompt === "second" ? fauxAssistantMessage("", { stopReason: "error", errorMessage: "second failed" }) : fauxAssistantMessage("result-" + prompt);
	};
	faux.setResponses([respond, respond]);
	const result = await api.executeSubagent({ tasks: [{ agent: "worker", task: "first" }, { agent: "worker", task: "second" }] }, context);
	assert.equal(started, 2);
	assert.equal(result.status, "failed");
	assert.equal(result.results.length, 2);
	assert.equal(result.results[0].output, "result-first");
	assert.equal(result.results[1].status, "failed");
	assert.match(result.results[1].error, /second failed/);
	assert.notEqual(result.results[0].sessionId, result.results[1].sessionId);
});

test("parallel task templates resolve the original request and report failing agent", async (t) => {
	const { api, faux, context } = await fixture(t);
	faux.setResponses([
		(ctx) => {
			assert.equal(ctx.messages.find(m => m.role === "user").content[0].text, "Handle source {task}");
			return fauxAssistantMessage("", { stopReason: "error", errorMessage: "fixture failed" });
		},
	]);
	const result = await api.executeSubagent({ task: "source {task}", tasks: [{ agent: "worker", task: "Handle {task}" }] }, context);
	assert.equal(result.status, "failed");
	assert.match(result.error, /worker/);
});

test("parallel launch failure retains its task slot without discarding successful peers", async (t) => {
	const { api, faux, context } = await fixture(t);
	context.agents.push({ name: "bad", subagentOnlyExtensions: [join(context.cwd, "missing.mjs")] });
	faux.setResponses([fauxAssistantMessage("success")]);
	const result = await api.executeSubagent({ tasks: [{ agent: "bad", task: "fails at launch" }, { agent: "worker", task: "succeeds" }] }, context);
	assert.equal(result.status, "failed");
	assert.equal(result.results.length, 2);
	assert.equal(result.results[0].agent, "bad");
	assert.equal(result.results[0].status, "failed");
	assert.equal(result.results[1].agent, "worker");
	assert.equal(result.results[1].output, "success");
});

test("parallel cancellation aborts active child and does not start queued tasks", async (t) => {
	const { api, faux, context } = await fixture(t);
	const controller = new AbortController();
	let started;
	const active = new Promise(resolve => { started = resolve; });
	let finish;
	const blocked = new Promise(resolve => { finish = resolve; });
	faux.setResponses([async () => { started(); await blocked; return fauxAssistantMessage("ignored"); }]);
	const pending = api.executeSubagent({ tasks: [{ agent: "worker", task: "first" }, { agent: "worker", task: "second" }], concurrency: 1 }, { ...context, signal: controller.signal });
	await active;
	controller.abort();
	finish();
	const result = await pending;
	assert.equal(result.status, "cancelled");
	assert.equal(faux.state.callCount, 1);
	assert.equal(result.results.length, 1);
	assert.equal(result.results[0].status, "cancelled");
});

test("child-only extension registers and executes an explicitly selected custom tool", async (t) => {
	const { api, cwd, faux, context } = await fixture(t);
	const extension = join(cwd, "child-tool.mjs");
	writeFileSync(extension, `export default api => api.registerTool({
		name: "fixture_tool", label: "Fixture", description: "Child fixture",
		parameters: { type: "object", properties: {}, additionalProperties: false },
		async execute() { return { content: [{ type: "text", text: "child-tool-result" }] }; }
	});`);
	context.agents[0].tools = ["fixture_tool"];
	context.agents[0].subagentOnlyExtensions = [extension];
	faux.setResponses([
		fauxAssistantMessage(fauxToolCall("fixture_tool", {}), { stopReason: "toolUse" }),
		(ctx) => {
			assert.match(ctx.messages.find((m) => m.role === "toolResult").content[0].text, /child-tool-result/);
			return fauxAssistantMessage("custom-complete");
		},
	]);
	const result = await api.executeSubagent({ agent: "worker", task: "use custom tool" }, context);
	assert.equal(result.status, "completed", JSON.stringify(result));
	assert.equal(result.results[0].output, "custom-complete");
});

test("a missing declared extension fails before model inference", async (t) => {
	const { api, cwd, faux, context } = await fixture(t);
	context.agents[0].subagentOnlyExtensions = [join(cwd, "missing-extension.mjs")];
	const result = await api.executeSubagent({ agent: "worker", task: "run" }, context);
	assert.equal(result.status, "failed");
	assert.match(result.error, /extension/i);
	assert.equal(faux.state.callCount, 0);
});

test("missing child tool fails before inference and shuts down loaded extensions", async (t) => {
	const { api, cwd, faux, context } = await fixture(t);
	const extension = join(cwd, "lifecycle.mjs");
	const marker = join(cwd, "shutdown-marker");
	writeFileSync(extension, `import { writeFileSync } from "node:fs";
		export default api => api.on("session_shutdown", () => writeFileSync(${JSON.stringify(marker)}, "closed"));`);
	context.agents[0].tools = ["not_registered"];
	context.agents[0].subagentOnlyExtensions = [extension];
	const result = await api.executeSubagent({ agent: "worker", task: "run" }, context);
	assert.equal(result.status, "failed");
	assert.match(result.error, /not_registered/);
	assert.equal(faux.state.callCount, 0);
	assert.equal(readFileSync(marker, "utf8"), "closed");
});

test("invalid sequence inputs fail before any inference, including invalid later model", async (t) => {
	const { api, faux, context } = await fixture(t);
	for (const input of [
		{ chain: [] },
		{ agent: "missing", task: "no" },
		{ chain: [{ agent: "worker", task: "valid" }, { agent: "worker", task: "invalid", model: "missing/model" }] },
	]) {
		await assert.rejects(api.executeSubagent(input, context), /agent|chain|model/i);
	}
	await assert.rejects(
		api.executeSubagent({ agent: "worker", task: "no" }, { ...context, agents: [...context.agents, ...context.agents] }),
		/duplicate/i,
	);
	assert.equal(faux.state.callCount, 0);
});

test("partial provider failure and empty terminal response cannot become successful child results", async (t) => {
	const { api, faux, context } = await fixture(t);
	faux.setResponses([
		fauxAssistantMessage("partial secret", { stopReason: "error", errorMessage: "fixture failure" }),
		fauxAssistantMessage(""),
	]);
	const failed = await api.executeSubagent(
		{ chain: [{ agent: "worker", task: "fail" }, { agent: "worker", task: "must not start" }] },
		context,
	);
	assert.equal(failed.status, "failed");
	assert.equal(failed.results.length, 1);
	assert.match(failed.results[0].error, /fixture failure/);
	assert.equal(faux.state.callCount, 1);

	const empty = await api.executeSubagent({ agent: "worker", task: "empty" }, context);
	assert.equal(empty.status, "failed");
	assert.match(empty.results[0].error, /empty|output/i);
});

test("parent subagent tool runs configured parallel tasks concurrently", async (t) => {
	const { api, faux, context } = await fixture(t);
	const settingsManager = SettingsManager.inMemory({ cacheWarming: "off", retry: { enabled: false }, compaction: { enabled: false } });
	const loader = new DefaultResourceLoader({ cwd: context.cwd, agentDir: context.agentDir, settingsManager, noExtensions: true, noSkills: true, noThemes: true, noPromptTemplates: true, noContextFiles: true, extensionFactories: [api.createSubagentExtension({ agents: context.agents, disabledFeatures: ["workflow-scripts"] })] });
	await loader.reload();
	const { session } = await createAgentSession({ cwd: context.cwd, agentDir: context.agentDir, modelRuntime: context.modelRuntime, model: context.parentModel, resourceLoader: loader, settingsManager, sessionManager: SessionManager.create(context.cwd, join(context.cwd, "parent-sessions")) });
	t.after(async () => { try { await session.extensionRunner.emit({ type: "session_shutdown", reason: "quit" }); } finally { session.dispose(); } });
	await session.bindExtensions({ mode: "rpc" });
	let starts = 0;
	let release;
	const gate = new Promise(resolve => { release = resolve; });
	const child = async (ctx) => {
		const prompt = ctx.messages.find(m => m.role === "user").content[0].text;
		if (prompt === "Delegate both") throw new Error("Parent did not launch parallel children");
		if (++starts === 2) release();
		await gate;
		return fauxAssistantMessage(`child-${prompt}`);
	};
	faux.setResponses([
		fauxAssistantMessage(fauxToolCall("subagent", { tasks: [{ agent: "worker", task: "one" }, { agent: "worker", task: "two" }] }), { stopReason: "toolUse" }),
		child, child,
		(ctx) => {
			const output = ctx.messages.find(m => m.role === "toolResult" && m.toolName === "subagent").content[0].text;
			assert.match(output, /child-one/);
			assert.match(output, /child-two/);
			return fauxAssistantMessage("PARENT-DONE");
		},
	]);
	await session.prompt("Delegate both");
	assert.equal(starts, 2);
	assert.equal(session.messages.at(-1).content[0].text, "PARENT-DONE");
});

test("registered extension delegates through the parent native tool loop and keeps SDK agentDir", async (t) => {
	const { api, faux, context } = await fixture(t);
	const settingsManager = SettingsManager.inMemory({
		cacheWarming: "off",
		retry: { enabled: false },
		compaction: { enabled: false },
	});
	const loader = new DefaultResourceLoader({
		cwd: context.cwd,
		agentDir: context.agentDir,
		settingsManager,
		noExtensions: true,
		noSkills: true,
		noThemes: true,
		noPromptTemplates: true,
		noContextFiles: true,
		extensionFactories: [api.createSubagentExtension({ agents: context.agents })],
	});
	await loader.reload();
	const parentManager = SessionManager.create(context.cwd, join(context.cwd, "parent-sessions"));
	const { session } = await createAgentSession({
		cwd: context.cwd,
		agentDir: context.agentDir,
		modelRuntime: context.modelRuntime,
		model: context.parentModel,
		resourceLoader: loader,
		settingsManager,
		sessionManager: parentManager,
	});
	t.after(async () => {
		try {
			await session.extensionRunner.emit({ type: "session_shutdown", reason: "quit" });
		} finally {
			session.dispose();
		}
	});
	await session.bindExtensions({ mode: "rpc" });

	faux.setResponses([
		fauxAssistantMessage(fauxToolCall("subagent", { agent: "worker", task: "child native task" }), { stopReason: "toolUse" }),
		(ctx) => {
			assert.deepEqual(ctx.messages.filter((m) => m.role === "user").at(-1).content, [{ type: "text", text: "child native task" }]);
			return fauxAssistantMessage("CHILD-NATIVE");
		},
		(ctx) => {
			assert.match(ctx.messages.find((m) => m.role === "toolResult" && m.toolName === "subagent").content[0].text, /CHILD-NATIVE/);
			return fauxAssistantMessage("PARENT-DONE");
		},
	]);

	const events = [];
	session.subscribe((e) => events.push(e));
	await session.prompt("Run subagent");

	assert.equal(session.messages.filter((m) => m.role === "assistant").length, 2);
	assert.ok(events.some((e) => e.type === "tool_execution_end" && e.toolName === "subagent"));
});
