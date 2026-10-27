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
	t.after(() => session.dispose());
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
