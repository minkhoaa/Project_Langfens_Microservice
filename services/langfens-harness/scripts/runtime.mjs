import { mkdirSync, realpathSync, symlinkSync, existsSync } from "node:fs";
import { dirname, join, resolve, sep } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

export const harnessRoot = realpathSync(fileURLToPath(new URL("..", import.meta.url)));
export const packageRoot = join(harnessRoot, "packages/langfens-harness-core");
export const cliPath = join(packageRoot, "dist/bundle/cli.js");

// This is a process/configuration boundary, not a sandbox for untrusted extensions/tools.
export function runtimeEnvironment(inherited = process.env) {
	const runtime = resolve(inherited.LANGFENS_HARNESS_RUNTIME_DIR || join(harnessRoot, ".runtime"));
	const home = join(runtime, "home");
	const agent = join(runtime, "agent");
	const packages = join(runtime, "packages");
	const workspace = join(runtime, "workspace");
	for (const dir of [home, agent, packages, workspace, join(runtime, "sessions"), join(runtime, "bin")]) {
		mkdirSync(dir, { recursive: true, mode: 0o700 });
	}
	// Pi's package manager intentionally keeps npm/git roots below agentDir.
	for (const name of ["npm", "git"]) {
		const target = join(packages, name);
		mkdirSync(target, { recursive: true, mode: 0o700 });
		const link = join(agent, name);
		if (!existsSync(link)) symlinkSync(target, link, process.platform === "win32" ? "junction" : "dir");
		if (realpathSync(link) !== realpathSync(target)) throw new Error(`Unexpected harness package root: ${link}`);
	}
	const env = { ...inherited };
	// Never inherit the invoking Pi's config, executable overrides, module preloads or session markers.
	for (const key of Object.keys(env)) {
		if (key.startsWith("PI_") || key.startsWith("XDG_") || ["NODE_PATH", "NODE_OPTIONS", "INIT_CWD"].includes(key)) delete env[key];
	}
	Object.assign(env, {
		LANGFENS_HARNESS_RUNTIME_DIR: runtime,
		LANGFENS_HARNESS_ISOLATED: "1",
		LANGFENS_HARNESS_WORKSPACE_DIR: workspace,
		HOME: home, USERPROFILE: home,
		XDG_CONFIG_HOME: join(home, ".config"), XDG_CACHE_HOME: join(home, ".cache"), XDG_DATA_HOME: join(home, ".local/share"),
		LANGFENS_HARNESS_AGENT_DIR: agent,
		LANGFENS_HARNESS_PACKAGE_DIR: packageRoot,
		LANGFENS_HARNESS_SESSION_DIR: join(runtime, "sessions"),
		LANGFENS_SUBAGENTS_CORE_ROOT: packageRoot,
		LANGFENS_HARNESS_OFFLINE: "1", LANGFENS_HARNESS_SKIP_VERSION_CHECK: "1", LANGFENS_HARNESS_TELEMETRY: "0",
		npm_config_prefix: join(packages, "npm"), npm_config_cache: join(packages, ".npm-cache"),
	});
	// Harness selection is always an absolute local Node entry, never a PATH shim.
	delete env.LANGFENS_SUBAGENTS_BINARY;
	env.PATH = [dirname(process.execPath), inherited.PATH || ""].join(process.platform === "win32" ? ";" : ":");
	return { env, runtime, workspace, packages };
}

export function runtimeLaunch(args = [], inherited = process.env) {
	const runtime = runtimeEnvironment(inherited);
	const source = args[0] === "--source";
	const forwarded = source ? args.slice(1) : args;
	return {
		...runtime,
		command: process.execPath,
		args: source
			? ["--import", pathToFileURL(join(packageRoot, "src/experimental/source-resolver.ts")).href, join(packageRoot, "src/cli.ts"), ...forwarded]
			: [cliPath, ...forwarded],
		// Preserve a nested child's cwd only inside this runtime, never the caller's host checkout.
		cwd: inherited.LANGFENS_HARNESS_ISOLATED === "1" &&
			(process.cwd() === runtime.runtime || process.cwd().startsWith(`${runtime.runtime}${sep}`))
			? process.cwd() : runtime.workspace,
	};
}
