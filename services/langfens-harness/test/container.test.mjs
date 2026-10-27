import "./offline.mjs";
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test from "node:test";
import { harnessRoot } from "../scripts/runtime.mjs";

// Deliberately separate from npm test: requires a previously built local image.
const image = process.env.LANGFENS_HARNESS_TEST_IMAGE || "langfens-harness:isolation-smoke";
const docker = process.env.LANGFENS_HARNESS_DOCKER || "/usr/bin/docker";
const run = (args, options = {}) => execFileSync(docker, ["run", "--rm", "--network", "none", ...args], {
	encoding: "utf8", timeout: 20000, ...options,
});

test("container starts without host mounts, global Pi or network", () => {
	assert.equal(run([image, "--version"]).trim(), "1.4.0");
	const output = run(["-i", image], { input: '{"id":"check","type":"get_state"}\n' });
	const response = output.split("\n").filter(Boolean).map(line => JSON.parse(line)).find(item => item.id === "check");
	assert.equal(response.success, true);
	assert.equal(response.data.isStreaming, false);
	assert.equal(response.data.messageCount, 0);
	// npm ci/prune in the image must not change any dependency metadata.
	assert.equal(run(["--entrypoint", "node", image, "-e", "process.stdout.write(require('fs').readFileSync('/app/package-lock.json'))"]),
		readFileSync(join(harnessRoot, "package-lock.json"), "utf8"));
	const probe = `
		const assert = require('node:assert/strict');
		const fs = require('node:fs');
		assert.equal(process.getuid(), 1000);
		assert.equal(process.env.PI_PACKAGE_DIR, '/app/packages/coding-agent');
		assert.equal(process.env.PI_SUBAGENTS_PI_CODING_AGENT_PACKAGE_ROOT, process.env.PI_PACKAGE_DIR);
		assert.equal(process.env.HOME, '/var/lib/langfens-harness/home');
		assert.equal(process.env.PI_CODING_AGENT_DIR, '/var/lib/langfens-harness/agent');
		assert.equal(process.env.PI_CODING_AGENT_SESSION_DIR, '/var/lib/langfens-harness/sessions');
		assert.equal(process.cwd(), '/var/lib/langfens-harness/workspace');
		assert.equal(fs.existsSync(process.env.HOME + '/.pi/agent/auth.json'), false);
		assert.equal(fs.realpathSync('/app/node_modules/.bin/pi'), '/app/packages/coding-agent/bin/pi.mjs');
		assert.ok(require.resolve('jiti').startsWith('/app/node_modules/'));
		console.log('container-isolated');
	`;
	assert.match(run(["--entrypoint", "node", image, "--import", "/app/scripts/register-runtime.mjs", "-e", probe]), /container-isolated/);
});

test("container TUI starts and exits in a PTY with no host configuration/dependency mounts", { timeout: 20000 }, () => {
	const dir = mkdtempSync(join(tmpdir(), "langfens-container-tui-"));
	try {
		const output = execFileSync("/usr/bin/python3", [join(harnessRoot, "test/tui-startup.py"), "--container", docker, image], {
			env: { ...process.env, LANGFENS_HARNESS_RUNTIME_DIR: dir, TERM: "xterm-256color" },
			encoding: "utf8", timeout: 15000,
		});
		assert.match(output, /TUI startup OK/);
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});
