import { dirname, join } from "node:path";
import { Type } from "typebox";
import type { ExtensionFactory } from "generation-harness-core";
import { discoverAgents } from "./agents/agents.ts";
import { executeSubagent } from "./runs/foreground/subagent-executor.ts";
import { loadHostHarnessCore } from "./runs/shared/harness-spawn.ts";
import type { SubagentExtensionOptions, SubagentProgress, SubagentRunResult } from "./types.ts";

export * from "./types.ts";
export { executeSubagent, discoverAgents, loadHostHarnessCore };

const task = Type.Object({ agent: Type.String({ minLength: 1 }), task: Type.String({ minLength: 1 }), model: Type.Optional(Type.String({ minLength: 1 })) }, { additionalProperties: false });
const parameters = Type.Union([task, Type.Object({ task: Type.Optional(Type.String()), chain: Type.Array(task, { minItems: 1 }) }, { additionalProperties: false })]);
interface ToolDetails { progress?: SubagentProgress; result?: SubagentRunResult }

/** Local extension registration adapted from the pinned source, exposing only single/ordered execution. */
export function createSubagentExtension(options: SubagentExtensionOptions = {}): ExtensionFactory {
	return api => {
		const active = new Map<AbortController, Promise<SubagentRunResult>>();
		const stopChildren = async () => {
			for (const controller of active.keys()) controller.abort();
			await Promise.allSettled([...active.values()]);
		};
		api.on("session_start", (_event, ctx) => { discoverAgents(ctx.cwd, ctx.agentDir, options.agents); });
		api.on("session_before_switch", async (_event, ctx) => { ctx.abort(); await stopChildren(); });
		api.on("session_shutdown", stopChildren);
		api.registerTool<typeof parameters, ToolDetails>({
			name: "subagent", label: "Subagent", description: "Delegate one task or an ordered chain to configured local Langfens agents with isolated sessions and optional model overrides.",
			parameters, executionMode: "sequential",
			async execute(_id, input, signal, onUpdate, ctx) {
				const controller = new AbortController();
				const combined = signal ? AbortSignal.any([signal, controller.signal]) : controller.signal;
				const pending = (async () => {
					await loadHostHarnessCore();
					const parentFile = ctx.sessionManager.getSessionFile();
					const sessionDir = join(parentFile ? dirname(parentFile) : join(ctx.agentDir, "sessions"), "children", ctx.sessionManager.getSessionId());
					return executeSubagent(input, {
						cwd: ctx.cwd, agentDir: ctx.agentDir, sessionDir, parentSessionId: ctx.sessionManager.getSessionId(),
						modelRuntime: ctx.modelRegistry.getRuntime(), parentModel: ctx.model,
						agents: discoverAgents(ctx.cwd, ctx.agentDir, options.agents), signal: combined,
						onProgress: progress => onUpdate?.({ content: [{ type: "text", text: progress.output || `${progress.agent}: ${progress.status}` }], details: { progress } }),
					});
				})();
				active.set(controller, pending);
				try {
					const result = await pending;
					const text = result.results.map(child => `${child.agent} (${child.model}, ${child.status})\n${child.output || child.error || ""}`).join("\n\n") || result.error || `Delegation ${result.status}.`;
					return { content: [{ type: "text", text }], details: { result }, isError: result.status !== "completed" };
				} catch (error) {
					const result: SubagentRunResult = { status: combined.aborted ? "cancelled" : "failed", results: [], error: error instanceof Error ? error.message : String(error) };
					return { content: [{ type: "text", text: result.error! }], details: { result }, isError: true };
				} finally { active.delete(controller); }
			},
		});
	};
}

export default createSubagentExtension();
