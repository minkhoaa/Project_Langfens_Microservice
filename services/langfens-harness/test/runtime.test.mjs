import "./offline.mjs";
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";
import { runtimeEnvironment } from "../scripts/runtime.mjs";
import { Agent } from "@earendil-works/pi-agent-core";
import { createFauxCore, fauxAssistantMessage, fauxProvider, fauxToolCall, InMemoryCredentialStore } from "@earendil-works/pi-ai";
import { builtinProviders, getAllBuiltinModels, getBuiltinProviders } from "@earendil-works/pi-ai/providers/all";
import { CodemodeSandbox } from "@earendil-works/pi-codemode";
import {
	createAgentSession,
	createReadTool,
	DefaultResourceLoader,
	discoverAndLoadExtensions,
	getMarkdownTheme,
	initTheme,
	ModelRuntime,
	RpcClient,
	SessionManager,
	SettingsManager,
} from "@earendil-works/pi-coding-agent";
import { Markdown, Text, visibleWidth } from "@earendil-works/pi-tui";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const offlineImport = `--import=${new URL("./offline.mjs", import.meta.url).href}`;

function scratch(t) {
	const dir = mkdtempSync(join(tmpdir(), "langfens-runtime-"));
	t.after(() => rmSync(dir, { recursive: true, force: true }));
	return dir;
}

function childEnv(dir) {
	// Do not pass operator credentials, settings, or automatically installed extensions to children.
	return {
		...runtimeEnvironment({ LANGFENS_HARNESS_RUNTIME_DIR: dir, PATH: "/usr/bin:/bin" }).env,
		NODE_OPTIONS: offlineImport,
		TERM: "xterm-256color",
		CI: "1",
	};
}

test("all built-in model catalogs and provider factories load without requests", () => {
	assert.equal(getBuiltinProviders().length, 42);
	assert.equal(builtinProviders().length, 42);
	for (const provider of getBuiltinProviders()) {
		assert.ok(getAllBuiltinModels(provider).length > 0, provider);
	}
});

test("agent executes a real read tool and a second turn using Pi's built-in faux stream", async (t) => {
	const cwd = scratch(t);
	writeFileSync(join(cwd, "sample.txt"), "local-runtime-data\n");
	const faux = createFauxCore({});
	faux.setResponses([
		fauxAssistantMessage(fauxToolCall("read", { path: "sample.txt" }), { stopReason: "toolUse" }),
		(context) => {
			const result = context.messages.find((message) => message.role === "toolResult");
			assert.ok(result);
			assert.match(result.content[0].text, /local-runtime-data/);
			return fauxAssistantMessage("offline-ok");
		},
	]);
	const events = [];
	const agent = new Agent({
		initialState: { model: faux.getModel(), systemPrompt: "Offline runtime smoke test", tools: [createReadTool(cwd)] },
		streamFn: faux.streamSimple,
	});
	agent.subscribe((event) => events.push(event.type));
	await agent.prompt("Read sample.txt");
	assert.equal(faux.state.callCount, 2);
	assert.equal(agent.state.messages.at(-1).content[0].text, "offline-ok");
	assert.equal(agent.state.isStreaming, false);
	assert.ok(events.includes("tool_execution_end"));
	assert.equal(events.filter((event) => event === "turn_end").length, 2);
});

test("SDK session persists, restores, branches, edits context, and compacts without inference", async (t) => {
	const cwd = scratch(t);
	const manager = SessionManager.create(cwd, join(cwd, "sessions"));
	const settings = SettingsManager.inMemory({ cacheWarming: "off", compaction: { enabled: false }, retry: { enabled: false } });
	const loader = new DefaultResourceLoader({
		cwd, agentDir: join(cwd, "agent"), settingsManager: settings,
		noExtensions: true, noSkills: true, noPromptTemplates: true, noThemes: true, noContextFiles: true,
	});
	await loader.reload();
	const runtime = await ModelRuntime.create({ credentials: new InMemoryCredentialStore(), modelsPath: null, refreshOnCreate: false });
	const faux = fauxProvider();
	runtime.registerNativeProvider(faux.provider);
	faux.setResponses([fauxAssistantMessage("session-ok")]);
	const { session } = await createAgentSession({
		cwd, agentDir: join(cwd, "agent"), modelRuntime: runtime, model: faux.getModel(),
		resourceLoader: loader, sessionManager: manager, settingsManager: settings, noTools: "all",
	});
	t.after(() => session.dispose());
	await session.bindExtensions({ mode: "rpc" });
	const events = [];
	session.subscribe((event) => events.push(event.type));
	await session.prompt("offline session");
	assert.equal(session.getLastAssistantText(), "session-ok");
	assert.ok(events.includes("agent_settled"));
	const saved = SessionManager.open(manager.getSessionFile());
	assert.deepEqual(saved.buildSessionContext().messages, manager.buildSessionContext().messages);
	const user = saved.getBranch().find((entry) => entry.type === "message" && entry.message.role === "user");
	assert.ok(user);
	saved.appendContextEdit(user.id, { content: "edited offline context" });
	assert.equal(saved.buildSessionContext().messages.find((message) => message.role === "user").content, "edited offline context");
	saved.branch(user.id);
	assert.notEqual(saved.buildSessionContext().messages.find((message) => message.role === "user").content, "edited offline context");
	saved.appendCustomEntry("smoke-state", { ok: true });
	saved.appendCompaction("offline summary", null, 100);
	assert.ok(saved.buildSessionContext().messages.some((message) => message.role === "compactionSummary"));
	assert.equal(faux.state.callCount, 1);
});

test("TUI components and bundled themes still render", () => {
	initTheme("dark");
	const text = new Text("Langfens tiếng Việt", 0, 0);
	assert.ok(text.render(40).length > 0);
	const markdown = new Markdown("# Langfens\n\n**Offline** runtime", 0, 0, getMarkdownTheme());
	for (const line of markdown.render(40)) assert.ok(visibleWidth(line) <= 40);
	initTheme("light");
	assert.ok(markdown.render(40).length > 0);
});

test("QuickJS WASM and worker entry execute offline", async () => {
	const sandbox = new CodemodeSandbox({ timeoutMs: 10000 });
	try {
		const result = await sandbox.execute("store('checked', true); return 6 * 7;");
		assert.equal(result.ok, true, JSON.stringify(result));
		assert.equal(result.value, 42);
		assert.equal(result.storeWrites.set.checked, true);
	} finally {
		await sandbox.close();
	}
});

for (const entry of ["dist/cli.js", "dist/bundle/cli.js"]) {
	test(`${entry}: CLI and RPC state/session/export commands work without prompts`, { timeout: 20000 }, async (t) => {
		const cwd = scratch(t);
		const env = childEnv(cwd);
		const cliPath = join(root, "packages/coding-agent", entry);
		assert.equal(execFileSync(process.execPath, [cliPath, "--version"], { cwd, env, encoding: "utf8" }).trim(), "1.4.0");
		assert.match(execFileSync(process.execPath, [cliPath, "--help"], { cwd, env, encoding: "utf8" }), /--mode/);
		const manager = SessionManager.create(cwd, join(cwd, "sessions"));
		manager.appendMessage({ role: "user", content: "Stored locally, never submitted to a provider", timestamp: Date.now() });
		const client = new RpcClient({
			cliPath, cwd, env,
			args: ["--offline", "--session", manager.getSessionFile(), "--no-extensions", "--no-skills", "--no-prompt-templates", "--no-themes"],
		});
		t.after(() => client.stop());
		await client.start();
		assert.equal((await client.getState()).isStreaming, false);
		await client.setSessionName("offline-rpc");
		assert.equal((await client.getState()).sessionName, "offline-rpc");
		assert.equal((await client.getMessages()).filter((message) => message.role === "user").length, 1);
		assert.ok(Array.isArray((await client.getEntries()).entries));
		assert.ok(Array.isArray((await client.getTree()).tree));
		assert.ok(Array.isArray(await client.getCommands()));
		const output = join(cwd, "session.html");
		await client.exportHtml(output);
		assert.match(readFileSync(output, "utf8"), /<!DOCTYPE html>/i);
		assert.deepEqual(await client.newSession(), { cancelled: false });
	});
}

test("existing pi-subagents extension loads through the host aliases (optional, no install)", {
	skip: !process.env.PI_SUBAGENTS_EXTENSION && "Set PI_SUBAGENTS_EXTENSION to an already installed extension entry",
	timeout: 30000,
}, async (t) => {
	const cwd = scratch(t);
	const loaded = await discoverAndLoadExtensions([resolve(process.env.PI_SUBAGENTS_EXTENSION)], cwd, join(cwd, "agent"));
	t.after(() => loaded.runtime.invalidate());
	assert.deepEqual(loaded.errors, []);
	assert.equal(loaded.extensions.length, 1);
	assert.ok(loaded.extensions[0].tools.has("subagent"));
	assert.ok(loaded.extensions[0].commands.has("subagents-doctor"));
	assert.ok(loaded.extensions[0].handlers.has("session_start"));
	assert.ok(loaded.extensions[0].handlers.has("session_shutdown"));
	for (const entry of ["dist/cli.js", "dist/bundle/cli.js"]) {
		const childDir = scratch(t);
		const client = new RpcClient({
			cliPath: join(root, "packages/coding-agent", entry), cwd: childDir, env: childEnv(childDir),
			args: ["--offline", "--no-session", "--no-extensions", "--extension", resolve(process.env.PI_SUBAGENTS_EXTENSION), "--no-skills", "--no-prompt-templates", "--no-themes"],
		});
		try {
			await client.start();
			assert.ok((await client.getCommands()).some((command) => command.name === "subagents-doctor"), entry);
			assert.equal((await client.getState()).isStreaming, false);
			assert.doesNotMatch(client.getStderr(), /Failed to load extension|Extension error/i);
		} finally {
			await client.stop();
		}
	}
});
