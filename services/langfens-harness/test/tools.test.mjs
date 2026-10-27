import "./offline.mjs";
import assert from "node:assert/strict";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test from "node:test";
import { createCodingTools } from "../packages/langfens-harness-core/src/core/tools/index.ts";
import { DEFAULT_MAX_LINES } from "../packages/langfens-harness-core/src/core/tools/truncate.ts";

async function execute(tool, args) {
	return tool.execute(`test-${tool.name}`, args);
}

test("four existing core factories preserve real file and shell behavior", async (t) => {
	const cwd = mkdtempSync(join(tmpdir(), "langfens-tools-"));
	t.after(() => rmSync(cwd, { recursive: true, force: true }));

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

	const shellResult = await execute(bash, { command: "printf 'shell-ok\\n'" });
	assert.equal(shellResult.isError ?? false, false);
	assert.match(shellResult.content.map((item) => item.text ?? "").join(""), /shell-ok/);
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
