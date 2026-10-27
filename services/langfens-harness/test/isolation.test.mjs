import "./offline.mjs";
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, realpathSync, rmSync, writeFileSync } from "node:fs";
import { createRequire } from "node:module";
import { tmpdir } from "node:os";
import { dirname, join, resolve, sep } from "node:path";
import test from "node:test";
import { fileURLToPath, pathToFileURL } from "node:url";
import { RpcClient } from "langfens-harness-core";
import { cliPath, harnessRoot, packageRoot, runtimeLaunch } from "../scripts/runtime.mjs";

const offline = new URL("./offline.mjs", import.meta.url).href;
function scratch(t) {
	const dir = mkdtempSync(join(tmpdir(), "langfens-isolation-"));
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
		HOME: host, USERPROFILE: host, PATH: poisonBin,
		NODE_PATH: join(host, "node_modules"), NODE_OPTIONS: `--import=${join(host, "preload.mjs")}`,
		LANGFENS_HARNESS_PACKAGE_DIR: host, LANGFENS_HARNESS_AGENT_DIR: join(host, ".pi/agent"),
		LANGFENS_HARNESS_SESSION_DIR: host, LANGFENS_SUBAGENTS_CORE_ROOT: host,
		LANGFENS_SUBAGENTS_BINARY: join(poisonBin, "pi"),
		LANGFENS_HARNESS_RUNTIME_DIR: join(dir, "runtime"),
	};
	const launch = runtimeLaunch([], inherited);
	// Guard every directly spawned runtime, not just the test runner. The production
	// launcher intentionally discards NODE_OPTIONS, so test it only with --version below.
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
		// Node reads NODE_OPTIONS before any JS launcher can sanitize it. Clear it at
		// this outer OS boundary; hostile preloads are separately removed by runtimeLaunch.
		cwd: launch.host, env: { ...launch.inherited, NODE_OPTIONS: "" }, encoding: "utf8", timeout: 15000,
	});
	assert.equal(output.trim(), "1.4.0");
	assert.equal(launch.command, process.execPath);
	assert.equal(launch.args[0], cliPath);
	assert.equal(launch.env.LANGFENS_HARNESS_PACKAGE_DIR, packageRoot);
	assert.equal(launch.env.LANGFENS_SUBAGENTS_CORE_ROOT, packageRoot);
	assert.equal(runtimeLaunch([], launch.inherited).env.NODE_OPTIONS, undefined);
	assert.equal(launch.env.NODE_PATH, undefined);
	const localBin = join(packageRoot, "bin/langfens-harness.mjs");
	assert.equal(realpathSync(join(harnessRoot, "node_modules/.bin/langfens-harness")), localBin);
	assert.equal(execFileSync(process.execPath, [localBin, "--version"], { env: launch.env, encoding: "utf8" }).trim(), "1.4.0");
	assert.equal(launch.env.LANGFENS_SUBAGENTS_BINARY, undefined);
	assert.equal(realpathSync(join(launch.runtime, "agent/npm")), join(launch.runtime, "packages/npm"));
	assert.equal(existsSync(join(launch.runtime, "bin/pi")), false);
	assert.equal(existsSync(join(harnessRoot, "node_modules/.bin/pi")), false);
});

test("SDK config/auth paths and default discovery ignore fake host settings, skills and extensions", (t) => {
	const launch = launchFor(t);
	const probe = `
		import assert from 'node:assert/strict';
		import { existsSync } from 'node:fs';
		import { DefaultResourceLoader, SessionManager, SettingsManager } from ${JSON.stringify(pathToFileURL(join(packageRoot, "dist/index.js")).href)};
		import { getAgentDir, getAuthPath, getPackageDir, getModelsPath, getSettingsPath } from ${JSON.stringify(pathToFileURL(join(packageRoot, "dist/config.js")).href)};
		import { DefaultPackageManager } from ${JSON.stringify(pathToFileURL(join(packageRoot, "dist/core/package-manager.js")).href)};
		assert.equal(getAgentDir(), process.env.LANGFENS_HARNESS_AGENT_DIR);
		assert.equal(getPackageDir(), process.env.LANGFENS_HARNESS_PACKAGE_DIR);
		assert.ok([getAuthPath(), getModelsPath(), getSettingsPath()].every(p => p.startsWith(getAgentDir() + '/')));
		assert.equal(existsSync(getAuthPath()), false);
		const session = SessionManager.create(process.cwd());
		assert.ok(session.getSessionFile().startsWith(process.env.LANGFENS_HARNESS_SESSION_DIR + '/'));
		session.appendMessage({role: 'user', content: 'Stored offline, never sent', timestamp: Date.now()});
		assert.equal(existsSync(session.getSessionFile()), true);
		const settings = SettingsManager.create(process.cwd(), getAgentDir());
		assert.deepEqual(settings.getGlobalSettings(), {});
		const packages = new DefaultPackageManager({cwd: process.cwd(), agentDir: getAgentDir(), settingsManager: settings});
		packages.getLegacyGlobalNpmInstallPath = () => { throw new Error('HOST_NPM_FALLBACK'); };
		assert.equal(packages.getNpmInstallPath({name: 'isolation-sentinel'}, 'user'), getAgentDir() + '/npm/node_modules/isolation-sentinel');
		const loader = new DefaultResourceLoader({ cwd: process.cwd(), agentDir: getAgentDir(), settingsManager: settings });
		await loader.reload();
		assert.deepEqual(loader.getSkills().skills, []);
		assert.deepEqual(loader.getAgentsFiles().agentsFiles, []);
		assert.deepEqual(loader.getExtensions().extensions, []);
		assert.deepEqual(loader.getExtensions().errors, []);
		console.log('discovery-isolated');
	`;
	assert.equal(execFileSync(process.execPath, ["--input-type=module", "-e", probe], {
		cwd: launch.cwd, env: launch.env, encoding: "utf8", timeout: 20000,
	}).trim(), "discovery-isolated");
});

for (const entry of ["dist/cli.js", "dist/bundle/cli.js"]) {
	test(`${entry}: real RPC child uses absolute local Node and CLI, even with poisoned PATH`, { timeout: 20000 }, async (t) => {
		const launch = launchFor(t);
		const snapshot = join(launch.runtime, "child.json");
		const extension = join(launch.runtime, "inspect.mjs");
		put(extension, `
			import { writeFileSync } from 'node:fs';
			import { getAgentDir } from 'langfens-harness-core';
			export default function(pi) {
				pi.on('session_start', () => writeFileSync(${JSON.stringify(snapshot)}, JSON.stringify({
					execPath: process.execPath, argv: process.argv, cwd: process.cwd(), agent: getAgentDir(),
					home: process.env.HOME, package: process.env.LANGFENS_HARNESS_PACKAGE_DIR,
					childPackage: process.env.LANGFENS_SUBAGENTS_CORE_ROOT
				})));
			}
		`);
		const localCli = join(packageRoot, entry);
		const client = new RpcClient({ cliPath: localCli, cwd: launch.cwd, env: launch.env,
			args: ["--offline", "--no-session", "--no-extensions", "--extension", extension] });
		t.after(() => client.stop());
		await client.start();
		assert.equal((await client.getState()).isStreaming, false);
		const child = JSON.parse(readFileSync(snapshot, "utf8"));
		assert.equal(child.execPath, process.execPath);
		assert.equal(child.argv[1], localCli);
		assert.equal(child.cwd, launch.workspace);
		assert.equal(child.agent, launch.env.LANGFENS_HARNESS_AGENT_DIR);
		assert.equal(child.home, launch.env.HOME);
		assert.equal(child.package, packageRoot);
		assert.equal(child.childPackage, packageRoot);
		assert.doesNotMatch(client.getStderr(), /HOST_|Extension error|Failed to load/);
	});
}

test("source entrypoint resolves workspace source and starts offline", { timeout: 20000 }, (t) => {
	const launch = launchFor(t);
	const source = runtimeLaunch(["--source", "--help"], launch.inherited);
	assert.match(execFileSync(source.command, source.args, {
		cwd: source.cwd, env: { ...source.env, NODE_OPTIONS: `--import=${offline}` }, encoding: "utf8",
	}), /--mode/);
});



test("TUI reaches interactive startup in a real PTY without provider calls", {
	skip: process.platform === "win32" && "PTY smoke uses Python's Unix pty module", timeout: 30000,
}, (t) => {
	const launch = launchFor(t);
	const script = join(harnessRoot, "test/tui-startup.py");
	const python = ["/usr/bin/python3", "/usr/local/bin/python3"].find(existsSync);
	assert.ok(python, "Python3 is required for the offline PTY smoke");
	for (const entry of ["dist/cli.js", "dist/bundle/cli.js"]) {
		const output = execFileSync(python, [script, process.execPath, join(packageRoot, entry)], {
			cwd: launch.cwd, env: { ...launch.env, TERM: "xterm-256color" }, encoding: "utf8", timeout: 14000,
		});
		assert.match(output, /TUI startup OK/);
	}
});
