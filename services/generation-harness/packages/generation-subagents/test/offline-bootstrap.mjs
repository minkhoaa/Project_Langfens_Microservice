import "../../../test/offline.mjs";
import { mkdtempSync, mkdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

// Install isolation before importing any SDK or upstream test module. Node
// children inherit the network guard, not another bootstrap that changes scope.
const root = mkdtempSync(join(tmpdir(), "generation-subagents-offline-"));
for (const directory of ["home", "agent", "sessions"]) mkdirSync(join(root, directory));
Object.assign(process.env, {
	HOME: join(root, "home"), USERPROFILE: join(root, "home"), XDG_CONFIG_HOME: join(root, "home", "config"),
	GENERATION_SUBAGENTS_TEMP_ROOT: join(root, "tmp"),
});
for (const key of Object.keys(process.env)) if (key.startsWith("PI_")) delete process.env[key];
const guard = new URL("../../../test/offline.mjs", import.meta.url).href;
process.env.NODE_OPTIONS = `--import=${guard}`;
process.once("exit", () => rmSync(root, { recursive: true, force: true }));
