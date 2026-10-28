import type { StreamFn } from "generation-agent-core";

export function agentStreamOptions(streamFn: StreamFn): { streamFunction: StreamFn; streamFn: StreamFn } {
	return { streamFunction: streamFn, streamFn };
}
