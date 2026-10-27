import "./offline.mjs";
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, realpathSync, rmSync, writeFileSync } from "node:fs";
import { createRequire } from "node:module";
import { tmpdir } from "node:os";
import { dirname, join, resolve, sep } from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";
import { RpcClient } from "generation-harness-core/rpc";
import { cliPath, harnessRoot, packageRoot, runtimeLaunch } from "../scripts/runtime.mjs";

const offline = new URL("./offline.mjs", import.meta.url).href;

function scratch(t) {
	const dir = mkdtempSync(join(tmpdir(), "generation-isolation-"));
	t.after(() => rmSync(dir, { recursive: true, force: true }));
	return dir;
}

function put(path, value, mode) {
	mkdirSync(dirname(path), { recursive: true });
	writeFileSync(path, value, { mode });
}

function launchFor(t) {
	const dir = scratch(t);
	const host = join(dir, "host");
	const poisonBin = join(host, "bin");
	put(join(poisonBin, "pi"), "#!/bin/sh\necho HOST_PI_USED >&2\nexit 99\n", 0o755);
	put(join(poisonBin, "node"), "#!/bin/sh\necho HOST_NODE_USED >&2\nexit 99\n", 0o755);
	put(join(host, "preload.mjs"), 'throw new Error("HOST_PRELOAD_LOADED");');
	put(join(host, ".pi/agent/settings.json"), JSON.stringify({ defaultProvider: "host-sentinel", extensions: ["./extensions/poison.js"] }));
	put(join(host, ".pi/agent/extensions/poison.js"), 'throw new Error("HOST_EXTENSION_LOADED");');
	put(join(host, ".pi/agent/auth.json"), JSON.stringify({ openai: { type: "api_key", key: "HOST_AUTH_SENTINEL" } }));
	put(join(host, ".pi/agent/skills/poison/SKILL.md"), "---\nname: host-poison\ndescription: Host sentinel\n---\nHOST_SKILL");
	put(join(host, ".agents/skills/poison/SKILL.md"), "---\nname: host-agents-poison\ndescription: Host sentinel\n---\nHOST_SKILL");
	put(join(dir, "runtime/AGENTS.md"), "HOST_ANCESTOR_CONTEXT");
	put(join(dir, "runtime/.agents/skills/poison/SKILL.md"), "---\nname: host-ancestor-poison\ndescription: Host ancestor sentinel\n---\nHOST_SKILL");

	const inherited = {
		HOME: host,
		USERPROFILE: host,
		PATH: poisonBin,
		NODE_PATH: join(host, "node_modules"),
		NODE_OPTIONS: `--import=${join(host, "preload.mjs")}`,
		GENERATION_HARNESS_PACKAGE_DIR: host,
		GENERATION_HARNESS_AGENT_DIR: join(host, ".generation/agent"),
		GENERATION_HARNESS_SESSION_DIR: host,
		GENERATION_SUBAGENTS_CORE_ROOT: host,
		GENERATION_SUBAGENTS_BINARY: join(poisonBin, "pi"),
		GENERATION_HARNESS_RUNTIME_DIR: join(dir, "runtime"),
	};

	const launch = runtimeLaunch([], inherited);
	launch.env.NODE_OPTIONS = `--import=${offline}`;
	return { ...launch, inherited, host };
}

test("workspace and dependency resolution stays inside the harness, never npm global", () => {
	const lock = JSON.parse(readFileSync(join(harnessRoot, "package-lock.json"), "utf8"));
	const inside = (path) => assert.ok(realpathSync(path).startsWith(harnessRoot + sep), path);
	for (const name of readdirSync(join(harnessRoot, "packages"))) {
		const manifestPath = join(harnessRoot, "packages", name, "package.json");
		const manifest = JSON.parse(readFileSync(manifestPath, "utf8"));
		const require = createRequire(manifestPath);
		inside(fileURLToPath(import.meta.resolve(manifest.name)));
		assert.equal(lock.packages[`node_modules/${manifest.name}`].link, true);
		for (const dep of Object.keys(manifest.dependencies || {})) {
			let resolved;
			try { resolved = require.resolve(dep); }
			catch { resolved = fileURLToPath(import.meta.resolve(dep)); }
			inside(resolved);
		}
	}
	for (const [path, entry] of Object.entries(lock.packages)) {
		if (entry.link) assert.ok(entry.resolved.startsWith("packages/"), path);
		assert.doesNotMatch(entry.resolved || "", /(?:file:|\/home\/|\.pi\/agent)/);
	}
});

test("launcher replaces hostile host configuration/preloads and runs with no global Pi in PATH", (t) => {
	const launch = launchFor(t);
	const output = execFileSync(process.execPath, [join(harnessRoot, "scripts/run.mjs"), "--version"], {
		cwd: launch.host,
		env: { ...launch.inherited, NODE_OPTIONS: "" },
		encoding: "utf8",
		timeout: 15000,
	});
	assert.equal(output.trim(), "1.4.0");
	assert.equal(launch.command, process.execPath);
	assert.equal(launch.args[0], cliPath);
	assert.equal(launch.env.GENERATION_HARNESS_PACKAGE_DIR, packageRoot);
	assert.equal(launch.env.GENERATION_SUBAGENTS_CORE_ROOT, packageRoot);
	assert.equal(runtimeLaunch([], launch.inherited).env.NODE_OPTIONS, undefined);
	assert.equal(launch.env.NODE_PATH, undefined);

	const localBin = join(packageRoot, "bin/generation-harness.mjs");
	assert.equal(realpathSync(join(harnessRoot, "node_modules/.bin/generation-harness")), localBin);
	assert.equal(execFileSync(process.execPath, [localBin, "--version"], { env: launch.env, encoding: "utf8" }).trim(), "1.4.0");
	assert.equal(launch.env.GENERATION_SUBAGENTS_BINARY, undefined);
	assert.equal(realpathSync(join(launch.runtime, "agent/npm")), join(launch.runtime, "packages/npm"));
	assert.equal(existsSync(join(launch.runtime, "bin/pi")), false);
	assert.equal(existsSync(join(harnessRoot, "node_modules/.bin/pi")), false);
});
