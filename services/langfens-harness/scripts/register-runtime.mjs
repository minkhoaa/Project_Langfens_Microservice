// SDK boundary: node --import ./scripts/register-runtime.mjs your-local-sdk-entry.mjs
import { runtimeEnvironment } from "./runtime.mjs";
const { env, workspace } = runtimeEnvironment();
for (const key of Object.keys(process.env)) if (!(key in env)) delete process.env[key];
Object.assign(process.env, env);
process.chdir(workspace);
