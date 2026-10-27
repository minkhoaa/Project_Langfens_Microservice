import { formatUserAgent } from "langfens-ai";

/** pi's `User-Agent` for its own network requests; the same detailed form pi-ai sends to providers. */
export function getHarnessUserAgent(version: string): string {
	return formatUserAgent({ userAgent: "detailed", version });
}
