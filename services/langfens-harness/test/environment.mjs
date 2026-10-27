import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { runtimeEnvironment } from "../scripts/runtime.mjs";

// Preload before static SDK imports, including theme/config module initialization.
const runtime = mkdtempSync(join(tmpdir(), "langfens-test-environment-"));
const extension = process.env.PI_SUBAGENTS_EXTENSION;
const { env } = runtimeEnvironment({ PATH: process.env.PATH, LANGFENS_HARNESS_RUNTIME_DIR: runtime });
for (const key of Object.keys(process.env)) delete process.env[key];
Object.assign(process.env, env);
if (extension) process.env.PI_SUBAGENTS_EXTENSION = extension;
process.on("exit", () => rmSync(runtime, { recursive: true, force: true }));
