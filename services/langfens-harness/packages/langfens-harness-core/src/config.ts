import { existsSync, readFileSync } from "fs";
import { createRequire } from "module";
import { basename, dirname, join, resolve, sep } from "path";
import { fileURLToPath } from "url";
import { getCorePackageRoot, resolveRuntimePaths } from "./runtime-paths.ts";
import { normalizePath } from "./utils/paths.ts";
import { stripBom } from "./utils/text.ts";

// =============================================================================
// Package Detection
// =============================================================================

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

/**
 * Detect if we're running as a Bun compiled binary.
 * Bun binaries have import.meta.url containing "$bunfs", "~BUN", or "%7EBUN" (Bun's virtual filesystem path)
 */
export const isBunBinary =
	import.meta.url.includes("$bunfs") || import.meta.url.includes("~BUN") || import.meta.url.includes("%7EBUN");

/** Detect if Bun is the runtime (compiled binary or bun run) */
export const isBunRuntime = !!process.versions.bun;

/** Detect the esbuild-bundled Node.js distribution. */
declare const LANGFENS_HARNESS_BUNDLED_NODE: boolean;
export const isBundledNode = typeof LANGFENS_HARNESS_BUNDLED_NODE !== "undefined" && LANGFENS_HARNESS_BUNDLED_NODE;

// =============================================================================
// Install Method Detection
// =============================================================================

export type InstallMethod = "bun-binary" | "npm" | "pnpm" | "yarn" | "bun" | "unknown";

export interface SelfUpdateCommand {
 command: string;
 args: string[];
 display: string;
 steps?: SelfUpdateCommand[];
}
export type SelfUpdatePackageTarget = string | { packageName: string; installSpec?: string };

/** This subsystem is owned by its source checkout and npm lockfile. */
export function detectInstallMethod(): InstallMethod { return "unknown"; }
export function getSelfUpdateCommand(
 _packageName: string, _npmCommand?: string[], _target?: SelfUpdatePackageTarget,
): SelfUpdateCommand | undefined { return undefined; }
export function getSelfUpdateUnavailableInstruction(
 _packageName: string, _npmCommand?: string[], _target?: SelfUpdatePackageTarget,
): string { return "Update the Langfens Harness source checkout and reinstall its pinned npm lockfile."; }
export function getUpdateInstruction(packageName: string): string {
 return getSelfUpdateUnavailableInstruction(packageName);
}

// =============================================================================
// Package Asset Paths (shipped with executable)
// =============================================================================

/**
 * Get the base directory for resolving package assets (themes, package.json, README.md, CHANGELOG.md).
 * - For Bun binary: returns the directory containing the executable
 * - For Node.js: returns the package root containing package.json
 * - Ignores Bun binary metadata copied into dist/ when the package root is available
 */
export function findNodePackageDir(startDir: string): string {
	let dir = startDir;
	while (dir !== dirname(dir)) {
		if (existsSync(join(dir, "package.json"))) {
			const parent = dirname(dir);
			// build:binary places Bun's metadata inside dist/. Node still needs the
			// package root so its dist-relative asset paths do not become dist/dist/.
			if (basename(dir) === "dist" && existsSync(join(parent, "package.json"))) {
				return parent;
			}
			return dir;
		}
		dir = dirname(dir);
	}
	return startDir;
}

export function getPackageDir(): string {
	return getCorePackageRoot();
}

/**
 * Get path to built-in themes directory (shipped with package)
 * - For Bun binary: theme/ next to executable
 * - For Node.js (dist/): dist/modes/interactive/theme/
 * - For source (src/): src/modes/interactive/theme/
 */
export function getThemesDir(): string {
	if (isBunBinary) {
		return join(getPackageDir(), "theme");
	}
	// Theme is in modes/interactive/theme/ relative to src/ or dist/
	const packageDir = getPackageDir();
	const srcOrDist = existsSync(join(packageDir, "src")) ? "src" : "dist";
	return join(packageDir, srcOrDist, "modes", "interactive", "theme");
}

/**
 * Get path to HTML export template directory (shipped with package)
 * - For Bun binary: export-html/ next to executable
 * - For Node.js (dist/): dist/core/export-html/
 * - For source (src/): src/core/export-html/
 */
export function getExportTemplateDir(): string {
	if (isBunBinary) {
		return join(getPackageDir(), "export-html");
	}
	const packageDir = getPackageDir();
	const srcOrDist = existsSync(join(packageDir, "src")) ? "src" : "dist";
	return join(packageDir, srcOrDist, "core", "export-html");
}

/** Get path to package.json */
export function getPackageJsonPath(): string {
	return join(getPackageDir(), "package.json");
}

/** Get path to README.md */
export function getReadmePath(): string {
	return resolve(join(getPackageDir(), "README.md"));
}

/** Get path to docs directory */
export function getDocsPath(): string {
	return resolve(join(getPackageDir(), "docs"));
}

/** Get path to examples directory */
export function getExamplesPath(): string {
	return resolve(join(getPackageDir(), "examples"));
}

/** Get path to CHANGELOG.md */
export function getChangelogPath(): string {
	return resolve(join(getPackageDir(), "CHANGELOG.md"));
}

/**
 * Get path to built-in interactive assets directory.
 * - For Bun binary: assets/ next to executable
 * - For Node.js (dist/): dist/modes/interactive/assets/
 * - For source (src/): src/modes/interactive/assets/
 */
export function getInteractiveAssetsDir(): string {
	if (isBunBinary) {
		return join(getPackageDir(), "assets");
	}
	const packageDir = getPackageDir();
	const srcOrDist = existsSync(join(packageDir, "src")) ? "src" : "dist";
	return join(packageDir, srcOrDist, "modes", "interactive", "assets");
}

/** Get path to a bundled interactive asset */
export function getBundledInteractiveAssetPath(name: string): string {
	return join(getInteractiveAssetsDir(), name);
}

let quickJSWasmPath: string | undefined;

/** Called by the Bun entry with the path of the QuickJS wasm file embedded in the compiled executable. */
export function setEmbeddedQuickJSWasmPath(path: string): void {
	quickJSWasmPath = path;
}

/**
 * Get path to `quickjs-wasi/quickjs.wasm`, the VM that runs codemode scripts. Resolved once so the
 * compiled module cached per path keeps working after an update removes this install (#10439).
 */
export function getQuickJSWasmPath(): string {
	quickJSWasmPath ??= createRequire(import.meta.url).resolve("quickjs-wasi/quickjs.wasm");
	return quickJSWasmPath;
}

/** Resolve the codemode worker entry for a release runtime. */
export function resolveCodemodeWorkerSpecifier(
	runtime: "bun-binary" | "bundled-node" | "unbundled",
	moduleUrl: string,
): string | URL | undefined {
	// Bun embeds explicit source entrypoints, but on Windows Bun 1.3 cannot map an absolute
	// B:\~BUN URL back to one. A relative string with the original source extension works on
	// every Bun platform.
	if (runtime === "bun-binary") return "./src/extensions/codemode/worker.ts";
	if (runtime === "bundled-node") return new URL("./codemode-worker.js", moduleUrl);
	return undefined;
}

let codemodeWorkerDataUrl: URL | undefined;

/**
 * Get the codemode worker entry, or undefined to use the worker that ships next to pi-codemode.
 * The Bun and Node release builds both pass the worker as an extra entrypoint.
 */
export function getCodemodeWorkerSpecifier(): string | URL | undefined {
	const runtime = isBunBinary ? "bun-binary" : isBundledNode ? "bundled-node" : "unbundled";
	const specifier = resolveCodemodeWorkerSpecifier(runtime, import.meta.url);
	if (runtime !== "bundled-node" || !(specifier instanceof URL)) return specifier;
	// Spawn workers from an in-memory copy. An update replaces or deletes the file while this
	// process keeps running (#10439). The bundle build keeps the worker free of relative imports
	// and import.meta, so it runs from a data: URL.
	codemodeWorkerDataUrl ??= new URL(`data:text/javascript;base64,${readFileSync(specifier).toString("base64")}`);
	return codemodeWorkerDataUrl;
}

export type InstallChange = { kind: "updated"; version: string } | { kind: "removed" };

/**
 * Detect that the package this process runs from changed on disk, for example after `pi update`
 * in another terminal. Code loaded on demand can then be missing or from another version.
 *
 * Checks the package.json read at startup. Resolving it again would walk up past a deleted install
 * and could find an unrelated package.json, such as one in the home directory.
 */
export function detectInstallChange(packageJsonPath = startupPackageJsonPath): InstallChange | undefined {
	// The Bun binary embeds its code, so replacing the executable does not affect this process.
	if (isBunBinary || !packageJsonPath) return undefined;
	let installed: PackageJson;
	try {
		installed = JSON.parse(stripBom(readFileSync(packageJsonPath, "utf-8"))) as PackageJson;
	} catch (error) {
		return (error as NodeJS.ErrnoException).code === "ENOENT" ? { kind: "removed" } : undefined;
	}
	return installed.version && installed.version !== VERSION
		? { kind: "updated", version: installed.version }
		: undefined;
}

// =============================================================================
// App Config (from package.json langfensConfig)
// =============================================================================

interface PackageJson {
	name?: string;
	version?: string;
	langfensConfig?: {
		name?: string;
		configDir?: string;
	};
}

let pkg: PackageJson = {};
/** The package.json this process started from, if one existed. */
let startupPackageJsonPath: string | undefined;
try {
	const packageJsonPath = getPackageJsonPath();
	pkg = JSON.parse(stripBom(readFileSync(packageJsonPath, "utf-8"))) as PackageJson;
	startupPackageJsonPath = packageJsonPath;
} catch (e: unknown) {
	const err = e as NodeJS.ErrnoException;
	if (err.code !== "ENOENT") throw e;
}

const langfensConfigName: string | undefined = pkg.langfensConfig?.name;
export const PACKAGE_NAME: string = pkg.name || "langfens-harness-core";
export const APP_NAME: string = "langfens-harness";
export const APP_TITLE: string = "Langfens Harness";
export const CONFIG_DIR_NAME: string = pkg.langfensConfig?.configDir || ".langfens";
export const VERSION: string = pkg.version || "0.0.0";

// e.g., LANGFENS_HARNESS_AGENT_DIR or TAU_CODING_AGENT_DIR
export const ENV_AGENT_DIR = "LANGFENS_HARNESS_AGENT_DIR";
export const ENV_SESSION_DIR = "LANGFENS_HARNESS_SESSION_DIR";

export function expandTildePath(path: string): string {
	return normalizePath(path);
}


/** Get the share viewer URL for a gist ID. */
export function getShareViewerUrl(gistId: string): string {
	throw new Error("Session sharing is not supported by Langfens Harness.");
}

// =============================================================================
// User Config Paths (~/.langfens/agent/*)
// =============================================================================

/** Get the agent config directory (e.g., ~/.langfens/agent/) */
export function getAgentDir(): string {
	const envDir = process.env[ENV_AGENT_DIR];
	if (envDir) {
		return expandTildePath(envDir);
	}
	return resolveRuntimePaths().agentDir;
}

/** Bound ancestor discovery in standalone processes; ordinary SDK behavior is unchanged. */
export function getStandaloneDiscoveryRoot(cwd: string): string | undefined {
	const workspace = process.env.LANGFENS_HARNESS_WORKSPACE_DIR;
	const root = workspace ? resolve(workspace) : resolve(cwd);
	const current = resolve(cwd);
	return current === root || current.startsWith(`${root}${sep}`) ? root : current;
}

/** Get path to user's custom themes directory */
export function getCustomThemesDir(): string {
	return join(getAgentDir(), "themes");
}

/** Get path to models.json */
export function getModelsPath(): string {
	return join(getAgentDir(), "models.json");
}

/** Get path to auth.json */
export function getAuthPath(): string {
	return join(getAgentDir(), "auth.json");
}

/** Get path to settings.json */
export function getSettingsPath(): string {
	return join(getAgentDir(), "settings.json");
}

/** Get path to tools directory */
export function getToolsDir(): string {
	return join(getAgentDir(), "tools");
}

/** Get path to managed binaries directory (fd, rg) */
export function getBinDir(): string {
	return join(getAgentDir(), "bin");
}

/** Get path to prompt templates directory */
export function getPromptsDir(): string {
	return join(getAgentDir(), "prompts");
}

/** Get path to sessions directory */
export function getSessionsDir(agentDir: string = getAgentDir()): string {
	return resolve(agentDir) === resolve(getAgentDir())
		? resolveRuntimePaths().sessionsDir
		: join(agentDir, "sessions");
}

/** Get path to debug log file */
export function getDebugLogPath(): string {
	return join(getAgentDir(), `${APP_NAME}-debug.log`);
}
