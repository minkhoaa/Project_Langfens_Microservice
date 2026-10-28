import type { ProviderEnv } from "../types.ts";

/** Resolve provider configuration from a scoped override, then the Node process environment. */
export function getProviderEnvValue(name: string, env?: ProviderEnv): string | undefined {
	return env?.[name] || process.env[name] || undefined;
}
