import type { AssistantMessage, Usage } from "langfens-harness-core/ai";

/** Adapted pinned output extraction; removed acceptance-report and CLI-footer special cases. */
export function getFinalOutput(messages: readonly { role: string }[]): string {
	for (let i = messages.length - 1; i >= 0; i--) {
		const message = messages[i] as AssistantMessage;
		if (message.role !== "assistant") continue;
		if (message.errorMessage || message.stopReason === "error" || message.stopReason === "aborted") continue;
		return message.content.filter(part => part.type === "text").map(part => part.text).join("\n");
	}
	return "";
}

/** Native usage representation; the pinned executor used flat cost/turn fields. */
export function emptyUsage(): Usage {
	return { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, totalTokens: 0,
		cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 } };
}
