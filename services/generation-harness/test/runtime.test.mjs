import "./offline.mjs";
import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import readline from "node:readline";
import test from "node:test";
import { RpcClient } from "generation-harness-core/rpc";
import { cliPath, harnessRoot } from "../scripts/runtime.mjs";

test("headless RPC mode responds to protocol commands with valid JSON", async (t) => {
	const cwd = mkdtempSync(join(tmpdir(), "generation-rpc-"));
	t.after(() => rmSync(cwd, { recursive: true, force: true }));

	await new Promise((resolvePromise, rejectPromise) => {
		const rpcProcess = spawn(
			process.execPath,
			[cliPath, "--mode", "rpc", "--no-session", "--no-tools", "--offline"],
			{
				cwd,
				stdio: ["pipe", "pipe", "pipe"],
				env: {
					...process.env,
					GENERATION_HARNESS_OFFLINE: "1",
					GENERATION_HARNESS_TELEMETRY: "0",
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
