import "./offline.mjs";
import { test } from "node:test";
import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import { pathToFileURL } from "node:url";
import path from "node:path";

const root = path.resolve("packages/generation-harness-core");
const repoRoot = path.resolve(".");
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

test("pruned legacy UI remnants, bun release files, and native binary prebuilds are absent", () => {
	const prunedPaths = [
		"packages/generation-harness-core/src/modes/interactive/session-share.ts",
		"packages/generation-harness-core/src/modes/interactive/bug-report.ts",
		"packages/generation-harness-core/src/core/bug-report.ts",
		"packages/generation-harness-core/src/core/bug-report-upload.ts",
		"packages/generation-harness-core/src/core/radius.ts",
		"packages/generation-harness-core/src/bun",
		"packages/ai/src/bun-oauth.ts",
		"packages/ai/test/radius-oauth.test.ts",
		"packages/ai/test/radius-provider.test.ts",
		"packages/tui/native/darwin/prebuilds",
		"packages/tui/native/darwin/build.sh",
		"packages/tui/native/linux/prebuilds",
		"packages/tui/native/linux/build.sh",
		"packages/tui/native/win32/prebuilds",
		"packages/tui/native/win32/build.mjs",
	];
	for (const relativePath of prunedPaths) {
		assert.equal(
			existsSync(path.join(repoRoot, relativePath)),
			false,
			`Pruned file or directory must not exist: ${relativePath}`,
		);
	}
});

test("root package defines required harness scripts and ESM configuration", () => {
	const pkg = JSON.parse(readFileSync(path.join(repoRoot, "package.json"), "utf8"));
	assert.equal(pkg.type, "module");
	for (const requiredScript of ["build", "dev", "start:tui", "start:rpc", "typecheck", "test"]) {
		assert.ok(pkg.scripts?.[requiredScript], `package.json missing required script: ${requiredScript}`);
	}
});
