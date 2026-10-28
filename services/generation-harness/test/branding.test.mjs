import "./offline.mjs";
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { existsSync, mkdtempSync, readFileSync, readdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";
import { runtimeLaunch } from "../scripts/runtime.mjs";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");

test("workspace installation exposes generation packages and the local harness command", () => {
	const manifests = readdirSync(join(root, "packages"))
		.filter((name) => existsSync(join(root, "packages", name, "package.json")))
		.map((name) => JSON.parse(readFileSync(join(root, "packages", name, "package.json"), "utf8")));

	assert.ok(manifests.some((pkg) => pkg.name === "generation-harness-core"));
	assert.ok(manifests.some((pkg) => pkg.name === "generation-subagents"));
	assert.ok(manifests.every((pkg) => pkg.name.startsWith("generation-")));

	const core = manifests.find((pkg) => pkg.name === "generation-harness-core");
	assert.deepEqual(core.bin, { "generation-harness": "bin/generation-harness.mjs" });
	assert.equal(core.generationConfig.configDir, ".generation");
});

test("local CLI identifies itself without global executable or configuration", (t) => {
	const cwd = mkdtempSync(join(tmpdir(), "generation-branding-"));
	t.after(() => rmSync(cwd, { recursive: true, force: true }));
	const launch = runtimeLaunch(["--source", "--help"], {
		...process.env,
		GENERATION_HARNESS_RUNTIME_DIR: join(cwd, "runtime"),
	});
	const help = execFileSync(launch.command, launch.args, {
		cwd: launch.cwd,
		env: launch.env,
		encoding: "utf8",
		timeout: 20000,
	});
	assert.match(help, /generation-harness/);
	assert.doesNotMatch(help, /@(?:earendil-works|mariozechner)\/pi-|~\/\.pi\b/);
	assert.equal(launch.env.GENERATION_HARNESS_AGENT_DIR, join(launch.runtime, "agent"));
	assert.ok(Object.keys(launch.env).every((key) => !key.startsWith("PI_")));
});
