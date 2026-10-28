#!/usr/bin/env node

import assert from "node:assert/strict";
import { spawn, execFileSync } from "node:child_process";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import readline from "node:readline";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(scriptDir, "..");
const codingAgentDir = join(repoRoot, "packages", "generation-harness-core");
const cliBundle = join(codingAgentDir, "dist", "bundle", "cli.js");

const smokeRuntime = mkdtempSync(join(tmpdir(), "generation-smoke-runtime-"));
const offlineUrl = pathToFileURL(join(repoRoot, "test", "offline.mjs")).href;
const smokeEnv = {
	...process.env,
	GENERATION_HARNESS_RUNTIME_DIR: smokeRuntime,
	GENERATION_HARNESS_OFFLINE: "1",
	GENERATION_HARNESS_TELEMETRY: "0",
	GENERATION_HARNESS_SKIP_VERSION_CHECK: "1",
};

try {

console.log("=== Running Minimal Runtime Smoke Tests ===");

// 1. Verify module exports
console.log("1. Verifying Core Module Exports...");

const agentCore = await import("generation-agent-core");
assert.equal(typeof agentCore.Agent, "function", "generation-agent-core must export Agent class");

const ai = await import("generation-ai");
assert.equal(typeof ai.createModels, "function", "generation-ai must export createModels");
assert.equal(typeof ai.createProvider, "function", "generation-ai must export createProvider");

const aiCompat = await import("generation-ai/compat");
assert.equal(typeof aiCompat.getModel, "function", "generation-ai/compat must export getModel");

const tui = await import("generation-tui");
assert.equal(typeof tui.ProcessTerminal, "function", "generation-tui must export ProcessTerminal");
assert.equal(typeof tui.TuiAltScreen, "function", "generation-tui must export TuiAltScreen");
assert.equal(typeof tui.TuiMainScreen, "function", "generation-tui must export TuiMainScreen");
assert.equal(typeof tui.Editor, "function", "generation-tui must export Editor");

const harnessCore = await import("generation-harness-core");
assert.equal(typeof harnessCore.createAgentSession, "function", "generation-harness-core must export createAgentSession");
assert.equal(typeof harnessCore.SessionManager.inMemory, "function", "generation-harness-core must export SessionManager.inMemory");
assert.equal(typeof harnessCore.ModelRuntime.create, "function", "generation-harness-core must export ModelRuntime.create");

const subagents = await import("generation-subagents");
assert.equal(typeof subagents.createSubagentExtension, "function", "generation-subagents must export createSubagentExtension");
assert.equal(typeof subagents.executeSubagent, "function", "generation-subagents must export executeSubagent");

// Verify public subpaths
const subpathAgent = await import("generation-harness-core/agent");
assert.equal(typeof subpathAgent.Agent, "function");
const subpathAi = await import("generation-harness-core/ai");
assert.equal(typeof subpathAi.createModels, "function");
const subpathSession = await import("generation-harness-core/session");
assert.equal(typeof subpathSession.createAgentSession, "function");
const subpathRpc = await import("generation-harness-core/rpc");
assert.equal(typeof subpathRpc.RpcClient, "function");
const subpathTools = await import("generation-harness-core/tools");
assert.deepEqual([...subpathTools.allToolNames].sort(), ["bash", "edit", "read", "write"]);
const subpathTui = await import("generation-harness-core/tui");
assert.equal(typeof subpathTui.ProcessTerminal, "function");
const subpathRuntime = await import("generation-harness-core/runtime");
assert.equal(typeof subpathRuntime.resolveRuntimePaths, "function");

console.log("   ✓ All core module exports and subpaths verified successfully.");

// 2. CLI invocation verification
console.log("2. Verifying CLI Binaries...");

const versionOutput = execFileSync(process.execPath, [cliBundle, "--version"], {
	cwd: repoRoot,
	env: smokeEnv,
	encoding: "utf8",
	timeout: 15_000,
}).trim();
assert.equal(versionOutput, "1.4.0", `CLI --version expected 1.4.0, got: ${versionOutput}`);
console.log(`   ✓ CLI version: ${versionOutput}`);

const helpOutput = execFileSync(process.execPath, [cliBundle, "--help"], {
	cwd: repoRoot,
	env: smokeEnv,
	encoding: "utf8",
	timeout: 15_000,
});
assert.ok(helpOutput.includes("--mode <mode>"), "CLI --help must describe --mode option");
assert.ok(helpOutput.includes("--model <pattern>"), "CLI --help must describe --model option");
console.log("   ✓ CLI help options verified.");

// 3. RPC protocol verification
console.log("3. Verifying Headless RPC Mode...");

await new Promise((resolvePromise, rejectPromise) => {
	const rpcProcess = spawn(
		process.execPath,
		["--import", offlineUrl, cliBundle, "--mode", "rpc", "--no-session", "--no-tools", "--offline"],
		{
			cwd: repoRoot,
			stdio: ["pipe", "pipe", "pipe"],
			env: smokeEnv,
		},
	);

	const timer = setTimeout(() => {
		rpcProcess.kill();
		rejectPromise(new Error("RPC smoke test timed out after 15 seconds"));
	}, 15_000);

	const rl = readline.createInterface({ input: rpcProcess.stdout });

	rl.on("line", (line) => {
		try {
			const parsed = JSON.parse(line);
			if (parsed.type === "response" && parsed.id === "smoke-state") {
				assert.equal(parsed.command, "get_state");
				assert.equal(parsed.success, true);
				assert.ok(parsed.data?.sessionId, "Expected valid session state with sessionId");

				// Send second command
				rpcProcess.stdin.write(JSON.stringify({ id: "smoke-commands", type: "get_commands" }) + "\n");
			} else if (parsed.type === "response" && parsed.id === "smoke-commands") {
				assert.equal(parsed.command, "get_commands");
				assert.equal(parsed.success, true);
				assert.ok(Array.isArray(parsed.data?.commands), "Expected commands array");

				// Clean exit
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

	rpcProcess.stderr.on("data", () => {
		// Ignore benign warning output
	});

	rpcProcess.on("error", (err) => {
		clearTimeout(timer);
		rejectPromise(err);
	});

	// Send initial command
	rpcProcess.stdin.write(JSON.stringify({ id: "smoke-state", type: "get_state" }) + "\n");
});

console.log("   ✓ RPC commands (get_state, get_commands) handled successfully.");

// 4. Launcher verification
console.log("4. Verifying Launcher Scripts...");

const launcherVersion = execFileSync(process.execPath, [join(repoRoot, "scripts", "run.mjs"), "--version"], {
	cwd: repoRoot,
	env: smokeEnv,
	encoding: "utf8",
	timeout: 15_000,
}).trim();
assert.equal(launcherVersion, "1.4.0");

const launcherHelp = execFileSync(process.execPath, [join(repoRoot, "scripts", "run.mjs"), "--help"], {
	cwd: repoRoot,
	env: smokeEnv,
	encoding: "utf8",
	timeout: 15_000,
});
assert.match(launcherHelp, /generation-harness/);
assert.doesNotMatch(launcherHelp, /@(?:earendil-works|mariozechner)\/pi-|~\/\.pi\b/);

console.log("=== All Smoke Tests Passed! ===");
} finally {
	rmSync(smokeRuntime, { recursive: true, force: true });
}
