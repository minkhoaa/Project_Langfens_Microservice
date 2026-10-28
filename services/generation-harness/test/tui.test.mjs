import "./offline.mjs";
import assert from "node:assert/strict";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import test from "node:test";
import { fileURLToPath, pathToFileURL } from "node:url";
import {
	AgentSessionRuntime,
	createAgentSession,
	createInteractiveTui,
	DefaultResourceLoader,
	InteractiveMode,
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
import { TuiAltScreen, TuiMainScreen } from "generation-tui";
import { VirtualTerminal } from "../packages/tui/test/virtual-terminal.ts";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");

async function createFixture(t, options = {}) {
	const cwd = mkdtempSync(join(tmpdir(), "generation-tui-test-"));
	t.after(() => rmSync(cwd, { recursive: true, force: true }));
	const agentDir = join(cwd, "agent");
	const sessionDir = join(cwd, "sessions");
	mkdirSync(agentDir, { recursive: true });
	mkdirSync(sessionDir, { recursive: true });

	const modelRuntime = await ModelRuntime.create({
		credentials: new InMemoryCredentialStore(),
		modelsPath: null,
		refreshOnCreate: false,
	});
	const faux = fauxProvider({
		models: [{ id: "model-a" }, { id: "model-b" }],
	});
	modelRuntime.registerNativeProvider(faux.provider);

	const settingsManager = SettingsManager.inMemory({
		cacheWarming: "off",
		retry: { enabled: false },
		compaction: { enabled: false },
		quietStartup: false,
		tuiMode: options.tuiMode ?? "regular",
	});

	const extensionFactories = options.extensionFactories ?? [];

	const createRuntime = async ({ cwd: currentCwd, sessionManager }) => {
		const loader = new DefaultResourceLoader({
			cwd: currentCwd,
			agentDir,
			settingsManager,
			noExtensions: extensionFactories.length === 0,
			noSkills: true,
			noThemes: true,
			noPromptTemplates: true,
			noContextFiles: true,
			extensionFactories,
		});
		await loader.reload();
		const currentModel = faux.getModel(options.initialModel ?? "model-a");
		const created = await createAgentSession({
			cwd: currentCwd,
			agentDir,
			modelRuntime,
			model: currentModel,
			resourceLoader: loader,
			settingsManager,
			sessionManager,
		});
		if (extensionFactories.length > 0) {
			await created.session.bindExtensions({ mode: "interactive" });
		}
		const services = {
			cwd: currentCwd,
			agentDir,
			settingsManager,
			modelRuntime,
			resourceLoader: loader,
			diagnostics: [],
		};
		return {
			...created,
			services,
			diagnostics: [],
		};
	};

	const sessionManager = SessionManager.create(cwd, sessionDir);
	const initialResult = await createRuntime({ cwd, sessionManager });
	const runtime = new AgentSessionRuntime(
		initialResult.session,
		initialResult.services,
		createRuntime,
		initialResult.diagnostics,
	);
	t.after(() => runtime.dispose());

	const terminal = new VirtualTerminal(options.columns ?? 100, options.rows ?? 30);
	let exitCode = null;

	const tui = new InteractiveMode(runtime, {
		terminal,
		tuiMode: options.tuiMode ?? "regular",
		verbose: options.verbose ?? true,
		exitHandler: (code) => {
			exitCode = code;
		},
		...options.tuiOptions,
	});

	t.after(() => tui.stop());

	const typeText = async (text) => {
		for (const ch of text) {
			terminal.sendInput(ch);
		}
		terminal.sendInput("\r");
		await terminal.waitForRender();
	};

	return {
		cwd,
		agentDir,
		sessionDir,
		modelRuntime,
		faux,
		runtime,
		terminal,
		tui,
		typeText,
		getExitCode: () => exitCode,
		getViewportText: () => terminal.getViewport().join("\n"),
		getScrollBufferText: () => terminal.getScrollBuffer().join("\n"),
	};
}

test("original TUI lifecycle, header rendering, and clean exit via /exit", async (t) => {
	const { tui, terminal, typeText, getViewportText, getExitCode } = await createFixture(t);

	await tui.init();
	await terminal.waitForRender();

	const screen = getViewportText();
	assert.match(screen, /Langfens Harness/);
	assert.match(screen, /v1\.4\.0/);
	assert.match(screen, /to interrupt/);
	assert.match(screen, /to exit/);
	assert.match(screen, /model-a/);

	await typeText("/exit");
	assert.equal(getExitCode(), 0);
});

test("inline (regular) vs fullscreen screen layout rendering and renderer types", async (t) => {
	// 1. Regular / inline mode: TuiMainScreen
	const regular = await createFixture(t, { tuiMode: "regular" });
	await regular.tui.init();
	await regular.terminal.waitForRender();

	assert.equal(regular.tui.renderer instanceof TuiMainScreen, true);
	assert.equal(regular.tui.renderer.mode, "regular");
	assert.equal(Object.getPrototypeOf(regular.tui.ui), TuiMainScreen.prototype);
	assert.match(regular.getViewportText(), /Langfens Harness/);

	// 2. Fullscreen mode: TuiAltScreen
	const fullscreen = await createFixture(t, { tuiMode: "fullscreen" });
	await fullscreen.tui.init();
	await fullscreen.terminal.waitForRender();

	assert.equal(fullscreen.tui.renderer instanceof TuiAltScreen, true);
	assert.equal(fullscreen.tui.renderer.mode, "fullscreen");
	assert.equal(Object.getPrototypeOf(fullscreen.tui.ui), TuiAltScreen.prototype);
	assert.match(fullscreen.getViewportText(), /Langfens Harness/);
});

test("normal typed prompt through terminal.sendInput into running InteractiveMode.run", async (t) => {
	const { tui, runtime, faux, terminal, typeText, getScrollBufferText, getExitCode } = await createFixture(t);

	let receivedUserText = "";
	faux.setResponses([
		(context) => {
			const lastMsg = context.messages.findLast((m) => m.role === "user");
			receivedUserText =
				lastMsg && typeof lastMsg.content === "string"
					? lastMsg.content
					: lastMsg?.content?.[0]?.text ?? "";
			return fauxAssistantMessage("Hello from typed prompt turn!");
		},
	]);

	await tui.init();
	await terminal.waitForRender();
	const runPromise = tui.run();

	const waitForTurn = (timeoutMs = 5000) =>
		new Promise((resolvePromise, reject) => {
			const timer = setTimeout(() => reject(new Error("Turn timed out")), timeoutMs);
			const unsub = runtime.session.subscribe((event) => {
				if (event.type === "agent_settled") {
					unsub();
					clearTimeout(timer);
					resolvePromise();
				}
			});
		});

	const turnDone = waitForTurn();
	await typeText("Typed question for model");
	await turnDone;
	await terminal.waitForRender();

	assert.equal(receivedUserText, "Typed question for model");
	const buffer = getScrollBufferText();
	assert.match(buffer, /Typed question for model/);
	assert.match(buffer, /Hello from typed prompt turn!/);

	await typeText("/exit");
	await runPromise;
	assert.equal(getExitCode(), 0);
});

test("multiline editing, newline insertion, and cursor navigation via terminal events", async (t) => {
	const { tui, terminal } = await createFixture(t);

	await tui.init();
	await terminal.waitForRender();

	// Type line 1, insert newline via \n, type line 2
	for (const ch of "line1") terminal.sendInput(ch);
	terminal.sendInput("\n");
	for (const ch of "line2") terminal.sendInput(ch);

	assert.equal(tui.defaultEditor.getText(), "line1\nline2");

	// Navigate up with cursorUp (\x1b[A) and insert text
	terminal.sendInput("\x1b[A");
	for (const ch of "-edit") terminal.sendInput(ch);

	assert.equal(tui.defaultEditor.getText(), "line1-edit\nline2");

	// Backspace (\x7f) deletes last character 't'
	terminal.sendInput("\x7f");
	assert.equal(tui.defaultEditor.getText(), "line1-edi\nline2");
});

test("prompt execution, stream output and turn usage stats", async (t) => {
	const { tui, runtime, faux, terminal, getScrollBufferText } = await createFixture(t);

	faux.setResponses([
		{
			...fauxAssistantMessage("Hello from faithful original TUI!"),
			usage: {
				input: 15,
				output: 7,
				cacheRead: 0,
				cacheWrite: 0,
				totalTokens: 22,
				cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 },
			},
		},
	]);

	await tui.init();
	await terminal.waitForRender();

	await runtime.session.prompt("Hi there");
	await terminal.waitForRender();

	const buffer = getScrollBufferText();
	assert.match(buffer, /Hi there/);
	assert.match(buffer, /Hello from faithful original TUI!/);
});

test("startup images are forwarded with initial prompt", async (t) => {
	const image = {
		type: "image",
		data: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==",
		mimeType: "image/png",
	};

	let received;
	const { tui, faux, terminal, typeText } = await createFixture(t, {
		tuiOptions: {
			initialMessage: "describe this image",
			initialImages: [image],
		},
	});

	faux.setResponses([
		(context) => {
			received = context.messages.findLast((message) => message.role === "user");
			return fauxAssistantMessage("I see a 1x1 image.");
		},
	]);

	const runPromise = tui.run();

	// Wait with timeout for initial prompt to be received
	const start = Date.now();
	while (!received && Date.now() - start < 3000) {
		await new Promise((r) => setTimeout(r, 20));
	}

	assert.ok(received, "Faux provider should receive the initial message with image");
	assert.equal(received.content[0].text, "describe this image");
	assert.equal(received.content[1].type, "image");
	assert.equal(received.content[1].data, image.data);

	await typeText("/exit");
	await runPromise;
});

test("conversation history preservation across multiple turns", async (t) => {
	const { tui, runtime, faux, terminal, getScrollBufferText } = await createFixture(t);

	faux.setResponses([
		fauxAssistantMessage("First answer from assistant"),
		fauxAssistantMessage("Second answer from assistant"),
	]);

	await tui.init();
	await terminal.waitForRender();

	await runtime.session.prompt("First question");
	await terminal.waitForRender();

	await runtime.session.prompt("Second question");
	await terminal.waitForRender();

	const buffer = getScrollBufferText();
	assert.match(buffer, /First question/);
	assert.match(buffer, /First answer from assistant/);
	assert.match(buffer, /Second question/);
	assert.match(buffer, /Second answer from assistant/);
});

test("model command opens overlay and selector navigation switches models", async (t) => {
	const { tui, runtime, terminal } = await createFixture(t);
	assert.equal(runtime.session.model?.id, "model-a");

	await tui.init();
	await terminal.waitForRender();

	// Type /model without argument to open interactive model selector overlay
	for (const ch of "/model") terminal.sendInput(ch);
	terminal.sendInput("\r");
	await terminal.waitForRender();

	// Verify model selector overlay is displayed on screen
	const overlayScreen = terminal.getViewport().join("\n");
	assert.match(overlayScreen, /model-a/);
	assert.match(overlayScreen, /model-b/);
	assert.match(overlayScreen, /Enter to select/);

	// Navigate to model-b using arrowDown (\x1b[B) and select via Enter (\r)
	terminal.sendInput("\x1b[B");
	await terminal.waitForRender();
	terminal.sendInput("\r");
	await terminal.waitForRender();

	assert.equal(runtime.session.model?.id, "model-b");
});

test("read, bash, edit, write tool progress visibility, disk mutations, and expanded output", async (t) => {
	const { tui, runtime, faux, cwd, terminal, getScrollBufferText } = await createFixture(t);
	writeFileSync(join(cwd, "test-file.txt"), "original line\n");

	faux.setResponses([
		fauxAssistantMessage(
			fauxToolCall("write", { path: "created.txt", content: "new content\n" }),
			{ stopReason: "toolUse" },
		),
		fauxAssistantMessage("File created."),
		fauxAssistantMessage(
			fauxToolCall("read", { path: "test-file.txt" }),
			{ stopReason: "toolUse" },
		),
		fauxAssistantMessage("File read."),
		fauxAssistantMessage(
			fauxToolCall("edit", {
				path: "test-file.txt",
				edits: [{ oldText: "original", newText: "modified" }],
			}),
			{ stopReason: "toolUse" },
		),
		fauxAssistantMessage("File edited."),
		fauxAssistantMessage(
			fauxToolCall("bash", { command: "echo test-shell" }),
			{ stopReason: "toolUse" },
		),
		fauxAssistantMessage("Shell executed."),
	]);

	await tui.init();
	await terminal.waitForRender();

	await runtime.session.prompt("Create file");
	await runtime.session.prompt("Read file");
	await runtime.session.prompt("Edit file");
	await runtime.session.prompt("Run bash");
	await terminal.waitForRender();

	// 1. Assert real file mutations on disk
	const createdOnDisk = readFileSync(join(cwd, "created.txt"), "utf8");
	assert.equal(createdOnDisk, "new content\n");
	const editedOnDisk = readFileSync(join(cwd, "test-file.txt"), "utf8");
	assert.equal(editedOnDisk, "modified line\n");

	// 2. Assert tool invocation identities rendered in scroll buffer
	const buffer = getScrollBufferText();
	assert.match(buffer, /created\.txt/);
	assert.match(buffer, /test-file\.txt/);
	assert.match(buffer, /echo test-shell/);

	// 3. Toggle tool detail expansion via Ctrl+O (\x0f)
	terminal.sendInput("\x0f");
	await terminal.waitForRender();

	const expandedBuffer = getScrollBufferText();
	assert.match(expandedBuffer, /test-shell/);
});

test("subagent execution progress, native child result, and parent completion", async (t) => {
	const subagentEntry = join(root, "packages/generation-subagents/dist/index.js");
	assert.ok(existsSync(subagentEntry), "local subagent implementation must exist");
	const subagentApi = await import(pathToFileURL(subagentEntry).href);

	const { tui, runtime, faux, terminal, getScrollBufferText } = await createFixture(t, {
		extensionFactories: [
			subagentApi.createSubagentExtension({
				agents: [{ name: "worker", systemPrompt: "Worker prompt", tools: ["read"] }],
			}),
		],
	});

	faux.setResponses([
		fauxAssistantMessage(
			fauxToolCall("subagent", { agent: "worker", task: "Do child work" }),
			{ stopReason: "toolUse" },
		),
		fauxAssistantMessage("Child task completed successfully."),
		fauxAssistantMessage("Parent finished after child delegation."),
	]);

	await tui.init();
	await terminal.waitForRender();

	await runtime.session.prompt("Delegate to worker");
	await terminal.waitForRender();

	// 1. Verify native child result in session toolResult message
	const toolResultMsg = runtime.session.messages.find((m) => m.role === "toolResult");
	assert.ok(toolResultMsg, "Tool result message must be present");
	assert.match(toolResultMsg.content[0].text, /worker \(faux\/model-a, completed\)/);
	assert.match(toolResultMsg.content[0].text, /Child task completed successfully\./);

	// 2. Verify completed parent output in session assistant message
	const lastAssistantMsg = runtime.session.messages.findLast((m) => m.role === "assistant");
	assert.ok(lastAssistantMsg, "Last assistant message must be present");
	assert.match(lastAssistantMsg.content[0].text, /Parent finished after child delegation\./);

	// 3. Expand tool cards via Ctrl+O (\x0f) and verify rendered transcript
	terminal.sendInput("\x0f");
	await terminal.waitForRender();

	const buffer = getScrollBufferText();
	assert.match(buffer, /worker/);
	assert.match(buffer, /Child task completed successfully\./);
	assert.match(buffer, /Parent finished after child delegation\./);
});

test("session stats display via /session and /stats asserts known numeric usage", async (t) => {
	const { tui, runtime, faux, typeText, terminal, getScrollBufferText } = await createFixture(t);

	faux.setResponses([
		{
			...fauxAssistantMessage("First answer"),
			usage: {
				input: 20,
				output: 10,
				cacheRead: 0,
				cacheWrite: 0,
				totalTokens: 30,
				cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 },
			},
		},
	]);

	await tui.init();
	await terminal.waitForRender();

	await runtime.session.prompt("Prompt 1");
	await terminal.waitForRender();

	await typeText("/stats");
	await terminal.waitForRender();

	const usage = runtime.session.getContextUsage();
	assert.ok(usage && usage.tokens > 0, "Context usage tokens must be positive");
	const buffer = getScrollBufferText();
	assert.match(buffer, /Tokens/);
	assert.match(buffer, /Input:\s*[\d,]+/);
	assert.match(buffer, /Output:\s*[\d,]+/);
	assert.match(buffer, /Total:\s*[\d,]+/);
});

test("session reset via /reset clears context and starts fresh session", async (t) => {
	const { tui, runtime, faux, typeText, terminal } = await createFixture(t);

	faux.setResponses([
		fauxAssistantMessage("Response prior to reset"),
		fauxAssistantMessage("Response following reset"),
	]);

	await tui.init();
	await terminal.waitForRender();

	await runtime.session.prompt("Initial prompt");
	await terminal.waitForRender();

	assert.equal(runtime.session.messages.length, 3);

	await typeText("/reset");
	await terminal.waitForRender();

	assert.equal(runtime.session.messages.length, 0);

	await runtime.session.prompt("Post-reset prompt");
	await terminal.waitForRender();

	assert.equal(runtime.session.messages.length, 3);
});

test("offline TUI lifecycle and command operations work without credentials", async (t) => {
	const { tui, terminal, typeText, getExitCode } = await createFixture(t);

	await tui.init();
	await terminal.waitForRender();

	await typeText("/reset");
	await typeText("/exit");
	assert.equal(getExitCode(), 0);
});
