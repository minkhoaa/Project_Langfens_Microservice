import { formatUserAgent } from "generation-ai";

/** User-Agent used by harness-owned network requests. */
export function getGenerationUserAgent(version: string): string {
	return formatUserAgent({ userAgent: "detailed", version });
}
