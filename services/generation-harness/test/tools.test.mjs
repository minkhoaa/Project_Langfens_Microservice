import "./offline.mjs";
import assert from "node:assert/strict";
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import test from "node:test";
import { createCodingTools, createAllToolDefinitions, allToolNames } from "generation-harness-core/tools";
import { DEFAULT_MAX_LINES } from "../packages/generation-harness-core/src/core/tools/truncate.ts";

async function execute(tool, args) {
	return tool.execute(`test-${tool.name}`, args);
}

test("four core factories preserve real file and shell behavior", async (t) => {
	const cwd = mkdtempSync(join(tmpdir(), "generation-tools-"));
	t.after(() => rmSync(cwd, { recursive: true, force: true }));

	assert.deepEqual([...allToolNames].sort(), ["bash", "edit", "read", "write"]);
	const definitions = createAllToolDefinitions(cwd);
	assert.deepEqual(Object.keys(definitions).sort(), ["bash", "edit", "read", "write"]);

	const tools = createCodingTools(cwd);
	assert.deepEqual(tools.map((tool) => tool.name), ["read", "bash", "edit", "write"]);
	const [read, bash, edit, write] = tools;

	await execute(write, { path: "tiếng Việt file.txt", content: "before\r\n" });
	assert.equal((await execute(read, { path: "tiếng Việt file.txt" })).content[0].text, "before\r\n");
	await execute(edit, {
		path: "tiếng Việt file.txt",
		edits: [{ oldText: "before", newText: "after" }],
	});
	assert.equal(readFileSync(join(cwd, "tiếng Việt file.txt"), "utf8"), "after\r\n");
	assert.equal((await execute(read, { path: "tiếng Việt file.txt" })).content[0].text, "after\r\n");

	const poison = join(cwd, "poison");
	mkdirSync(poison);
	writeFileSync(join(poison, "node"), "#!/bin/sh\necho HOST_NODE_USED >&2\nexit 99\n", { mode: 0o755 });
	writeFileSync(join(poison, "pi"), "#!/bin/sh\necho HOST_PI_USED >&2\nexit 99\n", { mode: 0o755 });
	const originalPath = process.env.PATH;
	process.env.PATH = `${poison}:${originalPath ?? ""}`;
	let shellResult;
	try {
		shellResult = await execute(bash, { command: "ls -1 'tiếng Việt file.txt'" });
	} finally {
		if (originalPath === undefined) delete process.env.PATH;
		else process.env.PATH = originalPath;
	}
	assert.equal(shellResult.isError ?? false, false, JSON.stringify(shellResult));
	assert.match(shellResult.content.map((item) => item.text ?? "").join(""), /tiếng Việt file\.txt/);
	assert.doesNotMatch(shellResult.content.map((item) => item.text ?? "").join(""), /HOST_NODE_USED/);
	const failedShellResult = await execute(bash, { command: "exit 7" });
	assert.equal(failedShellResult.isError, true);
	assert.equal(failedShellResult.structuredContent.exit_code, 7);

	await execute(write, { path: "lines.txt", content: "one\ntwo\nthree\nfour" });
	assert.equal((await execute(read, { path: "lines.txt", offset: 2, limit: 2 })).content[0].text, "two\nthree\n\n[1 more lines in file. Use offset=4 to continue.]");
	await execute(write, { path: "long.txt", content: Array.from({ length: DEFAULT_MAX_LINES + 2 }, (_, i) => `line-${i + 1}`).join("\n") });
	const truncated = await execute(read, { path: "long.txt" });
	assert.match(truncated.content[0].text, /Showing lines 1-2000 of 2002/);
	assert.equal(truncated.details.truncation.truncated, true);
	await assert.rejects(execute(read, { path: "missing.txt" }), /ENOENT|not found/i);

	// A valid local PNG exercises the existing image-processing branch without network access.
	writeFileSync(join(cwd, "pixel.png"), Buffer.from("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==", "base64"));
	const imageResult = await execute(read, { path: "pixel.png" });
	assert.ok(imageResult.content.some((item) => item.type === "image"));
});

test("session registers strictly 4 core tools by default, subagent adds exactly 1, auxiliary integrations are opt-in", async (t) => {
	const cwd = mkdtempSync(join(tmpdir(), "generation-session-tools-"));
	t.after(() => rmSync(cwd, { recursive: true, force: true }));

	const harnessRoot = join(dirname(fileURLToPath(import.meta.url)), "..");
	const { createAgentSession, DefaultResourceLoader, ModelRuntime, SettingsManager } = await import("generation-harness-core");
	const { auxiliaryExtensions } = await import("../packages/generation-harness-core/dist/extensions/index.js");

	const modelRuntime = await ModelRuntime.create({
		modelsPath: null,
		refreshOnCreate: false,
	});

	// 1. Default session without auxiliary extensions
	const defaultLoader = new DefaultResourceLoader({
		cwd,
		agentDir: join(cwd, "agent"),
		settingsManager: SettingsManager.create(cwd, join(cwd, "agent")),
		noExtensions: true,
	});
	await defaultLoader.reload();

	const { session: defaultSession } = await createAgentSession({
		cwd,
		agentDir: join(cwd, "agent"),
		modelRuntime,
		resourceLoader: defaultLoader,
	});
	t.after(() => defaultSession.dispose());
	await defaultSession.bindExtensions({ mode: "rpc" });

	const defaultTools = defaultSession.getAllTools().map((tool) => tool.name).sort();
	assert.deepEqual(defaultTools, ["bash", "edit", "read", "write"]);
	assert.deepEqual(defaultSession.getActiveToolNames().sort(), ["bash", "edit", "read", "write"]);

	// 2. Default runtime launcher loads generation-subagents, registering strictly the 4 core tools + subagent
	const subagentsEntry = join(harnessRoot, "packages/generation-subagents/dist/index.js");
	const subagentApi = await import(pathToFileURL(subagentsEntry).href);
	const subagentLoader = new DefaultResourceLoader({
		cwd,
		agentDir: join(cwd, "agent"),
		settingsManager: SettingsManager.create(cwd, join(cwd, "agent")),
		extensionFactories: [subagentApi.createSubagentExtension({ agents: [] })],
	});
	await subagentLoader.reload();

	const { session: subagentSession } = await createAgentSession({
		cwd,
		agentDir: join(cwd, "agent"),
		modelRuntime,
		resourceLoader: subagentLoader,
	});
	t.after(() => subagentSession.dispose());
	await subagentSession.bindExtensions({ mode: "rpc" });

	const subagentTools = subagentSession.getAllTools().map((tool) => tool.name).sort();
	assert.deepEqual(subagentTools, ["bash", "edit", "read", "subagent", "write"]);
	assert.equal(subagentTools.includes("codemode"), false);
	assert.equal(subagentTools.includes("tool_search"), false);

	// 3. Opt-in auxiliary extensions register codemode and tool-search
	const auxLoader = new DefaultResourceLoader({
		cwd,
		agentDir: join(cwd, "agent"),
		settingsManager: SettingsManager.create(cwd, join(cwd, "agent")),
		extensionFactories: auxiliaryExtensions,
	});
	await auxLoader.reload();

	const { session: auxSession } = await createAgentSession({
		cwd,
		agentDir: join(cwd, "agent"),
		modelRuntime,
		resourceLoader: auxLoader,
	});
	t.after(() => auxSession.dispose());
	await auxSession.bindExtensions({ mode: "rpc" });

	const auxTools = auxSession.getAllTools().map((tool) => tool.name).sort();
	assert.ok(auxTools.includes("codemode"));
	assert.ok(auxTools.includes("tool_search"));
});
