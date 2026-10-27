import "./offline.mjs";
import { test } from "node:test";
import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
import path from "node:path";

const root = path.resolve("packages/generation-harness-core");
const entries = ["agent", "ai", "runtime", "session", "rpc", "tools", "tui"];

test("native core public subpaths resolve to real implementations", async () => {
	for (const subpath of entries) {
		const url = import.meta.resolve(`generation-harness-core/${subpath}`);
		assert.ok(url.startsWith(pathToFileURL(root + path.sep).href), `${subpath} outside core package: ${url}`);
		const api = await import(url);
		assert.ok(Object.keys(api).length > 0, `${subpath} has no native exports`);
	}
	const tools = await import("generation-harness-core/tools");
	assert.deepEqual([...tools.allToolNames].sort(), ["bash", "edit", "read", "write"]);
	assert.deepEqual(Object.keys(tools.createAllToolDefinitions(process.cwd())).sort(), ["bash", "edit", "read", "write"]);
});
