import { promises as fs } from "node:fs";
import path from "node:path";
import { resolveRuntimePaths } from "generation-harness-core/runtime";

/** Generation's installed package scope is runtime-owned, never npm's global store. */
export async function resolveGlobalNpmRoot(options: {
	env?: NodeJS.ProcessEnv;
	platform?: NodeJS.Platform;
	timeoutMs?: number;
} = {}): Promise<string | null> {
	const runtime = resolveRuntimePaths({ runtimeDir: options.env?.GENERATION_HARNESS_RUNTIME_DIR });
	try { return await fs.realpath(path.join(runtime.agentDir, "npm", "node_modules")); }
	catch (error) {
		if (["ENOENT", "ENOTDIR"].includes((error as NodeJS.ErrnoException).code ?? "")) return null;
		throw error;
	}
}
