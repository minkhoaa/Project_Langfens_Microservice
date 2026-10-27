import { existsSync, mkdirSync, readFileSync, realpathSync, statSync, symlinkSync } from "node:fs";
import { dirname, join, resolve, sep } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

export const harnessRoot = realpathSync(fileURLToPath(new URL("..", import.meta.url)));
export const packageRoot = join(harnessRoot, "packages/generation-harness-core");
export const cliPath = join(packageRoot, "dist/bundle/cli.js");

/** Selected code must belong to this workspace; a corrupt selection never triggers fallback. */
export function ownedCoreEntry(source = false) {
	const canonical = realpathSync(packageRoot);
	if (canonical !== packageRoot) throw new Error(`Local core ownership mismatch: ${packageRoot}`);
	let manifest;
	try { manifest = JSON.parse(readFileSync(join(canonical, "package.json"), "utf8")); }
	catch (cause) { throw new Error(`Invalid local core manifest at ${canonical}`, { cause }); }
	if (manifest?.name !== "generation-harness-core") throw new Error("Invalid local core manifest identity");
	const entry = source ? join(canonical, "src/cli.ts") : cliPath;
	const realEntry = realpathSync(entry);
	if (!realEntry.startsWith(canonical + sep)) throw new Error(`Foreign local core entry: ${entry}`);
	return realEntry;
}

/** Root application wiring loads the vendored extension without a core package dependency cycle. */
function ownedSubagentEntry(source) {
	const expected = join(harnessRoot, "packages/generation-subagents");
	const canonical = realpathSync(expected);
	if (canonical !== expected) throw new Error("Foreign local subagent package root");
	const manifest = JSON.parse(readFileSync(join(canonical, "package.json"), "utf8"));
	if (manifest.name !== "generation-subagents" || manifest.peerDependencies?.["generation-harness-core"] !== "1.4.0") {
		throw new Error("Invalid local subagent manifest");
	}
	const entry = realpathSync(join(canonical, source ? "src/index.ts" : "dist/index.js"));
	if (!entry.startsWith(canonical + sep)) throw new Error("Foreign local subagent entry");
	return entry;
}

// Configuration/executable isolation, not a sandbox for tools or explicitly loaded extensions.
export function runtimeEnvironment(inherited = process.env) {
	const runtime = resolve(inherited.GENERATION_HARNESS_RUNTIME_DIR || join(harnessRoot, ".runtime"));
	const home = join(runtime, "home"), agent = join(runtime, "agent");
	const packages = join(runtime, "packages"), workspace = join(runtime, "workspace");
	for (const path of [home, agent, packages, workspace, join(runtime, "sessions")]) {
		mkdirSync(path, { recursive: true, mode: 0o700 });
	}
	for (const name of ["npm", "git"]) {
		const target = join(packages, name), link = join(agent, name);
		mkdirSync(target, { recursive: true, mode: 0o700 });
		if (!existsSync(link)) symlinkSync(target, link, process.platform === "win32" ? "junction" : "dir");
		if (realpathSync(link) !== realpathSync(target)) throw new Error(`Unexpected harness package root: ${link}`);
	}
	const env = { ...inherited };
	for (const key of Object.keys(env)) {
		if (key.startsWith("PI_") || key.startsWith("XDG_") || ["NODE_PATH", "NODE_OPTIONS", "INIT_CWD", "GENERATION_SUBAGENTS_BINARY"].includes(key)) {
			delete env[key];
		}
	}
	Object.assign(env, {
		GENERATION_HARNESS_RUNTIME_DIR: runtime,
		GENERATION_HARNESS_ISOLATED: "1",
		GENERATION_HARNESS_WORKSPACE_DIR: workspace,
		HOME: home,
		USERPROFILE: home,
		XDG_CONFIG_HOME: join(home, ".config"),
		XDG_CACHE_HOME: join(home, ".cache"),
		XDG_DATA_HOME: join(home, ".local/share"),
		GENERATION_HARNESS_AGENT_DIR: agent,
		GENERATION_HARNESS_PACKAGE_DIR: packageRoot,
		GENERATION_HARNESS_SESSION_DIR: join(runtime, "sessions"),
		GENERATION_SUBAGENTS_CORE_ROOT: packageRoot,
		GENERATION_HARNESS_OFFLINE: "1",
		GENERATION_HARNESS_SKIP_VERSION_CHECK: "1",
		GENERATION_HARNESS_TELEMETRY: "0",
		npm_config_prefix: join(packages, "npm"),
		npm_config_cache: join(packages, ".npm-cache"),
	});
	env.PATH = [dirname(process.execPath), inherited.PATH || ""].join(process.platform === "win32" ? ";" : ":");
	return { env, runtime, workspace, packages };
}

export function runtimeLaunch(args = [], inherited = process.env) {
	const source = args[0] === "--source";
	const entry = ownedCoreEntry(source);
	const forwarded = [];
	let explicitCwd;
	const input = source ? args.slice(1) : args;
	for (let i = 0; i < input.length; i++) {
		if (input[i] === "--cwd") {
			if (!input[i + 1] || input[i + 1].startsWith("--")) throw new Error("--cwd requires a directory");
			explicitCwd = resolve(input[++i]);
		} else forwarded.push(input[i]);
	}
	if (!forwarded.includes("--no-extensions")) {
		const extension = ownedSubagentEntry(source);
		if (!forwarded.includes(extension)) forwarded.unshift("--extension", extension);
	}
	const runtime = runtimeEnvironment(inherited);
	const cwd = explicitCwd || (inherited.GENERATION_HARNESS_ISOLATED === "1" && inherited.GENERATION_HARNESS_WORKING_DIR) || runtime.workspace;
	if (!statSync(cwd).isDirectory()) throw new Error(`Harness cwd is not a directory: ${cwd}`);
	runtime.env.GENERATION_HARNESS_WORKING_DIR = cwd;
	runtime.env.GENERATION_HARNESS_WORKSPACE_DIR = cwd;
	return {
		...runtime,
		cwd,
		command: process.execPath,
		args: source
			? ["--import", pathToFileURL(join(packageRoot, "src/experimental/source-resolver.ts")).href, entry, ...forwarded]
			: [entry, ...forwarded],
	};
}
