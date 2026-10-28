import "./offline.mjs";
import assert from "node:assert/strict";
import { spawn, spawnSync } from "node:child_process";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { delimiter, join } from "node:path";
import readline from "node:readline";
import { pathToFileURL } from "node:url";
import test from "node:test";
import { RpcClient } from "generation-harness-core/rpc";
import { buildSystemPrompt } from "../packages/generation-harness-core/src/core/system-prompt.ts";
import { getReadmePath } from "../packages/generation-harness-core/src/config.ts";
import { withPersonalizedCatalog } from "../packages/generation-harness-core/src/core/remote-catalog-provider.ts";
import { cliPath, harnessRoot, runtimeLaunch } from "../scripts/runtime.mjs";

test("launcher keeps system PATH commands available while invoking owned Node absolutely", (t) => {
	const cwd = mkdtempSync(join(tmpdir(), "generation-launcher-path-"));
	t.after(() => rmSync(cwd, { recursive: true, force: true }));
	const poison = join(cwd, "poison");
	mkdirSync(poison);
	writeFileSync(join(poison, "node"), "#!/bin/sh\necho HOST_NODE_USED >&2\nexit 99\n", { mode: 0o755 });
	writeFileSync(join(poison, "pi"), "#!/bin/sh\necho HOST_PI_USED >&2\nexit 99\n", { mode: 0o755 });
	const launch = runtimeLaunch(["--help"], {
		...process.env,
		GENERATION_HARNESS_RUNTIME_DIR: join(cwd, "runtime"),
		PATH: `${poison}${delimiter}${process.env.PATH}`,
	});
	assert.equal(launch.command, process.execPath);
	assert.equal(launch.env.PATH, `${poison}${delimiter}${process.env.PATH}`);
	const result = spawnSync(launch.command, launch.args, { cwd: launch.cwd, env: launch.env, encoding: "utf8" });
	assert.equal(result.status, 0, result.stderr);
	assert.match(result.stdout, /Usage|generation harness/i);
	assert.doesNotMatch(result.stderr, /HOST_NODE_USED|HOST_PI_USED/);
});

test("RpcClient uses its owned absolute entry and Node executable from a foreign cwd", async (t) => {
	const cwd = mkdtempSync(join(tmpdir(), "generation-rpc-client-"));
	t.after(() => rmSync(cwd, { recursive: true, force: true }));
	const poison = join(cwd, "poison");
	mkdirSync(poison);
	writeFileSync(join(poison, "node"), "#!/bin/sh\necho HOST_NODE_USED >&2\nexit 99\n", { mode: 0o755 });
	writeFileSync(join(poison, "pi"), "#!/bin/sh\necho HOST_PI_USED >&2\nexit 99\n", { mode: 0o755 });
	writeFileSync(join(cwd, "system-command-target"), "ok");
	const client = new RpcClient({
		cwd,
		env: {
			GENERATION_HARNESS_RUNTIME_DIR: join(cwd, "runtime"),
			PATH: `${poison}${delimiter}${process.env.PATH}`,
			PI_OFFLINE: "0",
			PI_CODING_AGENT_DIR: join(cwd, "host-pi"),
		},
		args: ["--no-session", "--no-tools", "--offline"],
	});
	t.after(() => client.stop());
	await client.start();
	const state = await client.getState();
	assert.ok(state.sessionId);
	const shellResult = await client.bash("ls -1 system-command-target");
	assert.equal(shellResult.exitCode, 0);
	assert.match(shellResult.output, /system-command-target/);
	assert.doesNotMatch(client.getStderr(), /HOST_NODE_USED|HOST_PI_USED/);
	assert.equal(existsSync(join(cwd, "host-pi")), false);
});

test("headless RPC mode responds to protocol commands with valid JSON", async (t) => {
	const cwd = mkdtempSync(join(tmpdir(), "generation-rpc-"));
	t.after(() => rmSync(cwd, { recursive: true, force: true }));
	const offlineUrl = pathToFileURL(join(harnessRoot, "test/offline.mjs")).href;
	const runtimeDir = join(cwd, "runtime");
	mkdirSync(runtimeDir, { recursive: true });

	await new Promise((resolvePromise, rejectPromise) => {
		const rpcProcess = spawn(
			process.execPath,
			["--import", offlineUrl, cliPath, "--mode", "rpc", "--no-session", "--no-tools", "--offline"],
			{
				cwd,
				stdio: ["pipe", "pipe", "pipe"],
				env: {
					...process.env,
					GENERATION_HARNESS_RUNTIME_DIR: runtimeDir,
					GENERATION_HARNESS_OFFLINE: "1",
					GENERATION_HARNESS_TELEMETRY: "0",
					GENERATION_HARNESS_SKIP_VERSION_CHECK: "1",
				},
			},
		);

		const timer = setTimeout(() => {
			rpcProcess.kill();
			rejectPromise(new Error("RPC test timed out"));
		}, 15000);

		const rl = readline.createInterface({ input: rpcProcess.stdout });
		let receivedState = false;

		rl.on("line", (line) => {
			try {
				const parsed = JSON.parse(line);
				if (parsed.type === "response" && parsed.id === "test-state") {
					assert.equal(parsed.command, "get_state");
					assert.equal(parsed.success, true);
					assert.ok(parsed.data?.sessionId);
					receivedState = true;
					rpcProcess.stdin.write(JSON.stringify({ id: "test-commands", type: "get_commands" }) + "\n");
				} else if (parsed.type === "response" && parsed.id === "test-commands") {
					assert.equal(parsed.command, "get_commands");
					assert.equal(parsed.success, true);
					assert.ok(Array.isArray(parsed.data?.commands));
					clearTimeout(timer);
					rpcProcess.stdin.end();
					resolvePromise();
				}
			} catch (e) {
				clearTimeout(timer);
				rpcProcess.kill();
				rejectPromise(e);
			}
		});

		rpcProcess.on("error", (err) => {
			clearTimeout(timer);
			rejectPromise(err);
		});

		rpcProcess.stdin.write(JSON.stringify({ id: "test-state", type: "get_state" }) + "\n");
	});
});

test("withPersonalizedCatalog preserves model type contract (chat-only for getModels, all for getAllModels)", async () => {
	const mockChatModel = {
		id: "chat-model-1",
		name: "Chat Model 1",
		type: "chat",
		api: "openai-completions",
		provider: "faux-provider",
	};
	const mockImageModel = {
		id: "image-model-1",
		name: "Image Model 1",
		type: "image",
		api: "openrouter-images",
		provider: "faux-provider",
	};
	const mockClassifierModel = {
		id: "classifier-model-1",
		name: "Classifier Model 1",
		type: "classifier",
		api: "typesafe-system-one",
		provider: "faux-provider",
	};

	const baseProvider = {
		id: "faux-provider",
		name: "Faux Provider",
		getModels: () => [mockChatModel],
		getAllModels: () => [mockChatModel, mockImageModel, mockClassifierModel],
	};

	const personalizedProvider = withPersonalizedCatalog(baseProvider, async () => [
		mockChatModel,
		mockImageModel,
		mockClassifierModel,
	]);

	// Simulate refresh with stored mixed models
	let published = false;
	await personalizedProvider.refreshModels({
		signal: new AbortController().signal,
		allowNetwork: false,
		stored: {
			checkedAt: Date.now(),
			models: [mockChatModel, mockImageModel, mockClassifierModel],
		},
		publish: async ({ update }) => {
			update();
			published = true;
			return true;
		},
	});

	assert.equal(published, true);
	// getModels must return only chat models
	const chatModels = personalizedProvider.getModels();
	assert.equal(chatModels.length, 1);
	assert.equal(chatModels[0].id, "chat-model-1");

	// getAllModels must return all models including image and classifier
	const allModels = personalizedProvider.getAllModels();
	assert.equal(allModels.length, 3);
	assert.deepEqual(
		allModels.map((m) => m.id),
		["chat-model-1", "image-model-1", "classifier-model-1"],
	);
});

test("system prompt asserts Langfens identity and excludes stale Pi docs and global paths", () => {
	const prompt = buildSystemPrompt({
		cwd: "/test/project",
		selectedTools: ["read", "bash", "edit", "write"],
	});

	// Preamble asserts Langfens Harness
	assert.match(prompt, /operating inside Langfens Harness/);
	assert.doesNotMatch(prompt, /operating inside pi/);

	// Docs section contains only valid README and no stale pi docs
	assert.match(prompt, /Harness documentation/);
	assert.ok(existsSync(getReadmePath()), "README referenced by system prompt must exist on disk");
	assert.doesNotMatch(prompt, /Pi documentation/);
	assert.doesNotMatch(prompt, /docs\/extensions\.md/);
	assert.doesNotMatch(prompt, /examples\/extensions/);
	assert.doesNotMatch(prompt, /~\/\.pi/);
});

test("getReadmePath resolves to an existing harness README containing provider configuration", () => {
	const readmePath = getReadmePath();
	assert.ok(existsSync(readmePath), `getReadmePath() does not exist on disk: ${readmePath}`);
	const content = readFileSync(readmePath, "utf8");
	assert.match(content, /Provider & Model Configuration/);
});

test("print mode reports missing credentials guidance and exits with code 1 when credentials are absent", async (t) => {
	const cwd = mkdtempSync(join(tmpdir(), "generation-missing-credentials-print-"));
	t.after(() => rmSync(cwd, { recursive: true, force: true }));
	const offlineUrl = pathToFileURL(join(harnessRoot, "test/offline.mjs")).href;
	const runtimeDir = join(cwd, "runtime");
	mkdirSync(runtimeDir, { recursive: true });

	const result = spawnSync(
		process.execPath,
		["--import", offlineUrl, cliPath, "-p", "/exit", "--provider", "anthropic", "--model", "claude-fable-5", "--offline", "--no-tools", "--no-session"],
		{
			cwd,
			encoding: "utf8",
			timeout: 15000,
			env: {
				...process.env,
				GENERATION_HARNESS_RUNTIME_DIR: runtimeDir,
				GENERATION_HARNESS_OFFLINE: "1",
				GENERATION_HARNESS_TELEMETRY: "0",
				GENERATION_HARNESS_SKIP_VERSION_CHECK: "1",
			},
		},
	);

	assert.equal(result.status, 1, `Expected exit status 1 due to missing credentials, got ${result.status}\nstdout: ${result.stdout}\nstderr: ${result.stderr}`);
	const output = `${result.stdout}\n${result.stderr}`;
	assert.match(output, /No API key found for anthropic/i);
	assert.match(output, /Provider & Model Configuration/i);
	assert.ok(existsSync(getReadmePath()), "README referenced by auth guidance must exist");
	assert.doesNotMatch(result.stderr, /\[NetworkBlocked\]/);
	assert.doesNotMatch(result.stderr, /UnhandledPromiseRejection|FATAL/);
});

test("process-level clean exit shuts down owned TUI runtime resources on /exit", async (t) => {
	const cwd = mkdtempSync(join(tmpdir(), "generation-clean-exit-tui-"));
	t.after(() => rmSync(cwd, { recursive: true, force: true }));

	const offlineUrl = pathToFileURL(join(harnessRoot, "test/offline.mjs")).href;
	const vtUrl = pathToFileURL(join(harnessRoot, "packages/tui/test/virtual-terminal.ts")).href;
	const coreUrl = pathToFileURL(join(harnessRoot, "packages/generation-harness-core/dist/index.js")).href;
	const aiUrl = pathToFileURL(join(harnessRoot, "packages/ai/dist/index.js")).href;
	const scriptPath = join(cwd, "run-tui-exit.mjs");

	const childScript = `
import "${offlineUrl}";
import { VirtualTerminal } from "${vtUrl}";
import {
  AgentSessionRuntime,
  createAgentSession,
  DefaultResourceLoader,
  InteractiveMode,
  ModelRuntime,
  SessionManager,
  SettingsManager,
} from "${coreUrl}";
import { InMemoryCredentialStore, fauxProvider } from "${aiUrl}";
import fs from "node:fs";
import path from "node:path";

const runDir = "${cwd}";
const agentDir = path.join(runDir, "agent");
const sessionDir = path.join(runDir, "sessions");
fs.mkdirSync(agentDir, { recursive: true });
fs.mkdirSync(sessionDir, { recursive: true });

const modelRuntime = await ModelRuntime.create({
  credentials: new InMemoryCredentialStore(),
  modelsPath: null,
  refreshOnCreate: false,
});
const faux = fauxProvider({ models: [{ id: "model-a" }] });
modelRuntime.registerNativeProvider(faux.provider);

const settingsManager = SettingsManager.inMemory({
  cacheWarming: "off",
  retry: { enabled: false },
  compaction: { enabled: false },
});

const createRuntime = async ({ cwd: currentCwd, sessionManager }) => {
  const loader = new DefaultResourceLoader({
    cwd: currentCwd,
    agentDir,
    settingsManager,
    noExtensions: true,
    noSkills: true,
    noThemes: true,
    noPromptTemplates: true,
    noContextFiles: true,
  });
  await loader.reload();
  const currentModel = faux.getModel("model-a");
  const created = await createAgentSession({
    cwd: currentCwd,
    agentDir,
    modelRuntime,
    model: currentModel,
    resourceLoader: loader,
    settingsManager,
    sessionManager,
  });
  return {
    ...created,
    services: { cwd: currentCwd, agentDir, settingsManager, modelRuntime, resourceLoader: loader, diagnostics: [] },
    diagnostics: [],
  };
};

const sessionManager = SessionManager.create(runDir, sessionDir);
const initialResult = await createRuntime({ cwd: runDir, sessionManager });
const runtime = new AgentSessionRuntime(
  initialResult.session,
  initialResult.services,
  createRuntime,
  initialResult.diagnostics,
);

const terminal = new VirtualTerminal(100, 30);
const tui = new InteractiveMode(runtime, {
  terminal,
  tuiMode: "regular",
});

await tui.init();
const runPromise = tui.run();

for (const ch of "/exit") {
  terminal.sendInput(ch);
}
terminal.sendInput("\\r");

await runPromise;
`;

	writeFileSync(scriptPath, childScript, "utf8");

	const result = spawnSync(process.execPath, [scriptPath], {
		cwd: harnessRoot,
		encoding: "utf8",
		timeout: 15000,
		env: {
			...process.env,
			GENERATION_HARNESS_RUNTIME_DIR: join(cwd, "runtime"),
			GENERATION_HARNESS_OFFLINE: "1",
			GENERATION_HARNESS_TELEMETRY: "0",
			GENERATION_HARNESS_SKIP_VERSION_CHECK: "1",
		},
	});

	assert.equal(result.status, 0, result.stderr);
	assert.doesNotMatch(result.stderr, /UnhandledPromiseRejection|FATAL/);
});
