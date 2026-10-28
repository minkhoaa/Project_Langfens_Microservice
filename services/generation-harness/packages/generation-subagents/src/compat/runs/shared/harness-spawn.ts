import { readFileSync, realpathSync } from "node:fs";
import { dirname, join, resolve, sep } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

/** Adapted pinned host-SDK selection: one owned local root, no global/PATH retry. */
export async function loadHostHarnessCore(): Promise<typeof import("generation-harness-core")> {
	let directory = dirname(fileURLToPath(import.meta.url));
	for (;;) {
		try {
			const manifest = JSON.parse(readFileSync(join(directory, "package.json"), "utf8")) as { name?: string };
			if (manifest.name !== "generation-subagents") throw new Error("Invalid local subagent package identity");
			break;
		} catch (error) {
			if ((error as NodeJS.ErrnoException).code !== "ENOENT") throw error;
			const parent = dirname(directory);
			if (parent === directory) throw new Error("Local subagent package manifest not found");
			directory = parent;
		}
	}
	const expected = resolve(realpathSync(directory), "../generation-harness-core");
	const root = realpathSync(expected);
	if (root !== expected) throw new Error("Foreign local core package root");
	const manifest = JSON.parse(readFileSync(join(root, "package.json"), "utf8")) as { name?: string; version?: string };
	if (manifest.name !== "generation-harness-core" || manifest.version !== "1.4.0") throw new Error("Invalid local core manifest identity/version");
	const source = import.meta.url.endsWith(".ts");
	const entry = realpathSync(join(root, source ? "src/index.ts" : "dist/index.js"));
	if (!entry.startsWith(root + sep)) throw new Error("Foreign local core SDK entry");
	return import(pathToFileURL(entry).href);
}
