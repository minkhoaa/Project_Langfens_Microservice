import type { Model } from "langfens-harness-core/ai";
import type { AgentDefinition, ChildResult, SubagentExecutionContext } from "../../types.ts";
import { emptyUsage, getFinalOutput } from "../../shared/output.ts";
import type { createDefaultChildSessionFactory } from "../shared/child-session.ts";
import { loadHostHarnessCore } from "../shared/harness-spawn.ts";

/** Pinned foreground lifecycle reduced to its native local-session execution path. */
export async function runSync(
	agent: AgentDefinition, task: string, model: Model<any>, index: number,
	context: SubagentExecutionContext, factory: ReturnType<typeof createDefaultChildSessionFactory>,
): Promise<ChildResult> {
	const child = await factory.create(agent, model);
	const session = child.session;
	const core = await loadHostHarnessCore();
	const result: ChildResult = {
		agent: agent.name, model: `${model.provider}/${model.id}`, sessionId: session.sessionId,
		sessionFile: session.sessionFile, output: "", usage: emptyUsage(), status: "completed",
	};
	let aborting: Promise<void> | undefined;
	const abortChild = () => {
		aborting ??= session.abort().catch(error => { result.error = `Child abort failed: ${String(error)}`; });
	};
	context.signal?.addEventListener("abort", abortChild, { once: true });
	const emit = (extra: Partial<import("../../types.ts").SubagentProgress> = {}) => context.onProgress?.({
		index, agent: agent.name, model: result.model, sessionId: result.sessionId, status: "running", ...extra,
	});
	const unsubscribe = session.subscribe(event => {
		if (event.type === "tool_execution_start") emit({ tool: event.toolName });
		if (event.type === "message_update" && event.assistantMessageEvent.type === "text_delta") {
			emit({ output: event.assistantMessageEvent.delta });
		}
	});
	try {
		emit();
		if (context.signal?.aborted) abortChild();
		else await session.prompt(task);
		const last = [...session.messages].reverse().find(message => message.role === "assistant");
		result.output = getFinalOutput(session.messages);
		if (context.signal?.aborted || (last?.role === "assistant" && last.stopReason === "aborted")) {
			result.status = "cancelled";
			result.error ??= "Subagent stopped.";
		} else if (last?.role !== "assistant" || last.stopReason === "error" || last.errorMessage || !result.output.trim()) {
			result.status = "failed";
			result.error ??= last?.role === "assistant" && last.errorMessage || "Subagent returned empty terminal output.";
		}
	} catch (error) {
		result.status = context.signal?.aborted ? "cancelled" : "failed";
		result.error = error instanceof Error ? error.message : String(error);
	} finally {
		context.signal?.removeEventListener("abort", abortChild);
		unsubscribe();
		await aborting;
		for (const entry of session.sessionManager.getEntries()) {
			const usage = entry.type === "message"
				? (entry.message.role === "assistant" || entry.message.role === "toolResult" ? entry.message.usage : undefined)
				: (entry.type === "usage" || entry.type === "compaction" || entry.type === "branch_summary" ? entry.usage : undefined);
			if (usage) result.usage = core.combineUsage(result.usage, usage);
		}
		await child.dispose();
	}
	emit({ status: result.status, output: result.output, usage: result.usage, error: result.error });
	return result;
}
