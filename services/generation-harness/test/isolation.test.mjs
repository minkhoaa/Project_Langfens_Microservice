import "./offline.mjs";
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, realpathSync, rmSync, writeFileSync } from "node:fs";
import { createRequire } from "node:module";
import { tmpdir } from "node:os";
import { dirname, join, resolve, sep } from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";
import { createServer } from "node:http";
import http from "node:http";
import https from "node:https";
import net from "node:net";
import tls from "node:tls";
import { RpcClient } from "generation-harness-core/rpc";
import { resolveApiKey, setFixtureApiKey, clearFixtureApiKeys } from "../packages/ai/test/oauth.ts";
import { ModelRuntime } from "generation-harness-core";
import { validateMcpServerConfig } from "../packages/generation-harness-core/src/core/mcp-servers.ts";
import { InMemoryCredentialStore } from "generation-ai";
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

test("MCP configuration rejects unsupported client metadata without network access", () => {
	const result = validateMcpServerConfig("remote", {
		url: "https://mcp.example.test/",
		oauth: { clientRegistration: "cimd" },
	});
	assert.equal(typeof result, "string");
	assert.match(result, /Client ID Metadata Documents are unsupported/);
});

test("catalog refresh with network enabled never calls an upstream catalog host", async () => {
	const originalOffline = process.env.GENERATION_HARNESS_OFFLINE;
	const originalFetch = globalThis.fetch;
	delete process.env.GENERATION_HARNESS_OFFLINE;
	const urls = [];
	globalThis.fetch = async (input) => {
		const url = String(input);
		urls.push(url);
		throw new Error(`blocked test network request: ${url}`);
	};
	try {
		const runtime = await ModelRuntime.create({
			credentials: new InMemoryCredentialStore(),
			modelsPath: null,
			allowModelNetwork: true,
			refreshOnCreate: true,
		});
		assert.ok(runtime.getAllModels().length > 0, "native static model catalog remains available");
		assert.equal(urls.some((url) => /pi\\.dev/i.test(url)), false);
	} finally {
		globalThis.fetch = originalFetch;
		if (originalOffline === undefined) delete process.env.GENERATION_HARNESS_OFFLINE;
		else process.env.GENERATION_HARNESS_OFFLINE = originalOffline;
	}
});

test("workspace and dependency resolution stays inside the harness, never npm global", async () => {
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

	// Verify extension loader aliases resolve strictly within harness packages
	const { getAliases } = await import("../packages/generation-harness-core/dist/core/extensions/loader.js");
	const aliases = getAliases();
	for (const [name, targetPath] of Object.entries(aliases)) {
		inside(targetPath);
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

test("test network guard blocks external network while allowing loopback, and never reads global auth", async (t) => {
	// 1. Poison global auth file in temporary home
	const dir = scratch(t);
	const fakeHome = join(dir, "home");
	const poisonAuth = join(fakeHome, ".pi/agent/auth.json");
	put(poisonAuth, JSON.stringify({
		openai: { type: "api_key", key: "POISON_OPENAI_KEY" },
		anthropic: { type: "api_key", key: "POISON_ANTHROPIC_KEY" },
		"openai-codex": { type: "api_key", key: "POISON_CODEX_KEY" },
	}));

	const origHome = process.env.HOME;
	const origUserProfile = process.env.USERPROFILE;
	process.env.HOME = fakeHome;
	process.env.USERPROFILE = fakeHome;
	t.after(() => {
		if (origHome !== undefined) process.env.HOME = origHome;
		else delete process.env.HOME;
		if (origUserProfile !== undefined) process.env.USERPROFILE = origUserProfile;
		else delete process.env.USERPROFILE;
		clearFixtureApiKeys();
	});

	// Verify resolveApiKey returns undefined and does not read poisoned auth
	const resolvedOpenAI = await resolveApiKey("openai");
	const resolvedAnthropic = await resolveApiKey("anthropic");
	const resolvedCodex = await resolveApiKey("openai-codex");
	assert.equal(resolvedOpenAI, undefined);
	assert.equal(resolvedAnthropic, undefined);
	assert.equal(resolvedCodex, undefined);

	// Verify explicit in-memory fixture works
	setFixtureApiKey("mock-provider", "fixture-key");
	assert.equal(await resolveApiKey("mock-provider"), "fixture-key");
	clearFixtureApiKeys();
	assert.equal(await resolveApiKey("mock-provider"), undefined);

	// 2. Verify external fetch, http, https, net.connect and tls.connect are blocked with remote sentinels
	await assert.rejects(
		async () => {
			await fetch("https://sentinel.invalid/models");
		},
		{
			message: /\[NetworkBlocked\] External fetch to sentinel\.invalid is prohibited in offline test execution\./,
		},
	);

	assert.throws(
		() => {
			http.request("http://sentinel.invalid/api");
		},
		{
			message: /\[NetworkBlocked\] External HTTP request to sentinel\.invalid is prohibited in offline test execution\./,
		},
	);

	assert.throws(
		() => {
			https.request("https://sentinel.invalid/api");
		},
		{
			message: /\[NetworkBlocked\] External HTTPS request to sentinel\.invalid is prohibited in offline test execution\./,
		},
	);

	assert.throws(
		() => {
			net.connect([{ host: "sentinel.invalid", port: 80 }]);
		},
		{
			message: /\[NetworkBlocked\] External TCP connection to sentinel\.invalid:80 is prohibited in offline test execution\./,
		},
	);

	assert.throws(
		() => {
			tls.connect({ host: "sentinel.invalid", port: 443 });
		},
		{
			message: /\[NetworkBlocked\] External TLS connection to sentinel\.invalid:443 is prohibited in offline test execution\./,
		},
	);

	// Regression: tls.connect(port[, host][, options]) with omitted host and options object
	assert.throws(
		() => {
			tls.connect(443, { host: "blocked.invalid" });
		},
		{
			message: /\[NetworkBlocked\] External TLS connection to blocked.invalid:443 is prohibited in offline test execution\./,
		},
	);
	assert.throws(
		() => {
			tls.connect(443, { hostname: "blocked.invalid" });
		},
		{
			message: /\[NetworkBlocked\] External TLS connection to blocked.invalid:443 is prohibited in offline test execution\./,
		},
	);

	// 3. Verify loopback fetch succeeds against a local HTTP server
	const server = createServer((req, res) => {
		res.writeHead(200, { "content-type": "application/json" });
		res.end(JSON.stringify({ status: "loopback-ok" }));
	});

	await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
	t.after(() => server.close());

	const port = server.address().port;
	const response = await fetch(`http://127.0.0.1:${port}/test`);
	assert.equal(response.status, 200);
	const data = await response.json();
	assert.equal(data.status, "loopback-ok");

	// 4. Test subprocess disposable runtime root selection
	const customRuntime = join(dir, "disposable-runtime");
	const client = new RpcClient({
		cwd: dir,
		env: {
			GENERATION_HARNESS_RUNTIME_DIR: customRuntime,
			PATH: process.env.PATH,
		},
		args: ["--no-session", "--no-tools", "--offline"],
	});
	t.after(() => client.stop());
	await client.start();
	const state = await client.getState();
	assert.ok(state.sessionId);
	assert.equal(existsSync(join(customRuntime, "agent")), true);
	assert.equal(existsSync(join(customRuntime, "home")), true);
});
