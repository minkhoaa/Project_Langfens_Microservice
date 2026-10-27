import { existsSync, readFileSync, realpathSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

/** Resolve code ownership from this module, never from environment/global packages. */
export function getCorePackageRoot(): string {
	let directory = dirname(fileURLToPath(import.meta.url));
	for (;;) {
		const manifest = join(directory, "package.json");
		if (existsSync(manifest)) {
			const pkg = JSON.parse(readFileSync(manifest, "utf8")) as { name?: string };
			if (pkg.name !== "generation-harness-core") throw new Error(`Invalid local core manifest: ${manifest}`);
			return realpathSync(directory);
		}
		const parent = dirname(directory);
		if (parent === directory) throw new Error("Local generation-harness-core manifest not found");
		directory = parent;
	}
}

export interface RuntimePaths {
	root: string;
	home: string;
	agentDir: string;
	sessionsDir: string;
	workspaceDir: string;
	cwd: string;
}

/** Pure path selection: constructing an SDK session must not chdir or mutate process.env. */
export function resolveRuntimePaths(options: { runtimeDir?: string; cwd?: string } = {}): RuntimePaths {
	const root = resolve(options.runtimeDir ?? process.env.GENERATION_HARNESS_RUNTIME_DIR ?? join(getCorePackageRoot(), "../..", ".runtime"));
	const explicitRoot = options.runtimeDir !== undefined;
	const workspaceDir = join(root, "workspace");
	return {
		root,
		home: join(root, "home"),
		agentDir: resolve(!explicitRoot && process.env.GENERATION_HARNESS_AGENT_DIR || join(root, "agent")),
		sessionsDir: resolve(!explicitRoot && process.env.GENERATION_HARNESS_SESSION_DIR || join(root, "sessions")),
		workspaceDir,
		cwd: resolve(options.cwd ?? (!explicitRoot && process.env.GENERATION_HARNESS_WORKSPACE_DIR || workspaceDir)),
	};
}
