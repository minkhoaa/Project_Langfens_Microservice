import { applyThinkingSuffix } from "../../../runs/shared/child-tool-plan.ts";
import { validateAgentDefinitions } from "../../agents/agents.ts";
import { emptyUsage } from "../../shared/output.ts";
import type { AgentDefinition, ChildTask, SubagentExecutionContext, SubagentInput, SubagentRunResult } from "../../types.ts";
import { createDefaultChildSessionFactory } from "../shared/child-session.ts";
import { loadHostHarnessCore } from "../shared/harness-spawn.ts";
import { runSync } from "./execution.ts";

/** Narrow adapter of the pinned single/ordered path, not a new agent or workflow engine. */
export async function executeSubagent(input: SubagentInput, context: SubagentExecutionContext): Promise<SubagentRunResult> {
	if (!input || typeof input !== "object") throw new Error("Subagent input must name an agent or nonempty chain");
	const chained = "chain" in input;
	const parallel = "tasks" in input;
	const allowed = chained ? ["chain", "task"] : parallel ? ["tasks", "task", "concurrency"] : ["agent", "task", "model"];
	for (const key of Object.keys(input)) if (!allowed.includes(key)) throw new Error(`Unsupported subagent option: ${key}`);
	if (parallel && input.concurrency !== undefined && (!Number.isInteger(input.concurrency) || input.concurrency < 1)) throw new Error("Concurrency must be a positive integer");
	const steps: ChildTask[] = chained ? input.chain : parallel ? input.tasks : [input];
	if (!Array.isArray(steps) || !steps.length) throw new Error("Subagent chain must not be empty");
	const agents = validateAgentDefinitions(context.agents);
	const core = await loadHostHarnessCore();
	const prepared: Array<{ step: ChildTask; agent: AgentDefinition; model: string }> = [];
	for (const step of steps) {
		if (!step || typeof step.agent !== "string" || typeof step.task !== "string" || !step.task.trim()) throw new Error("Each child requires an agent and nonempty task");
		for (const key of Object.keys(step)) if (!["agent", "task", "model"].includes(key)) throw new Error(`Unsupported child option: ${key}`);
		if (step.model !== undefined && (typeof step.model !== "string" || !step.model.trim())) throw new Error("Invalid child model override");
		const agent = agents.find(candidate => candidate.name === step.agent.trim());
		if (!agent) throw new Error(`Unknown agent '${step.agent}'. Configure a Langfens agent definition first.`);
		if ((chained || parallel) && step.task.includes("{task}") && typeof input.task !== "string") throw new Error("Child task references {task} without an original task");
		const selection = step.model ?? agent.model ?? (context.parentModel ? `${context.parentModel.provider}/${context.parentModel.id}` : undefined);
		const model = applyThinkingSuffix(selection, agent.thinking);
		if (!model) throw new Error("No configured child/parent model is available");
		// Keep eager validation for the original extension-free SDK contract, but
		// a child-local provider can resolve its model only after native loading.
		const hasExtensions = agent.extensions?.length || agent.subagentOnlyExtensions?.length || agent.tools?.some(tool => tool.includes("/") || /\.[cm]?[jt]s$/.test(tool));
		if (!hasExtensions) {
			const resolved = core.resolveCliModel({ cliModel: model, modelRuntime: context.modelRuntime });
			if (resolved.error) throw new Error(`Invalid child model: ${resolved.error}`);
		}
		prepared.push({ step, agent, model });
	}
	const result: SubagentRunResult = { status: "completed", results: [] };
	const factory = createDefaultChildSessionFactory(context);
	let previousOutput = "";
	try {
		if (parallel) {
			let next = 0;
			const results: Array<Awaited<ReturnType<typeof runSync>> | undefined> = new Array(prepared.length);
			const errors: string[] = [];
			const worker = async () => {
				while (!context.signal?.aborted) {
					const index = next++;
					if (index >= prepared.length) return;
					const { step, agent, model } = prepared[index];
					const resolvedTask = step.task.replace(/\{task\}/g, () => input.task ?? "");
					try { results[index] = await runSync(agent, resolvedTask, model, index, context, factory); }
					catch (error) {
						const message = error instanceof Error ? error.message : String(error);
						errors.push(`Child ${index}: ${message}`);
						results[index] = { agent: agent.name, model, output: "", usage: emptyUsage(), status: context.signal?.aborted ? "cancelled" : "failed", error: message };
					}
				}
			};
			await Promise.all(Array.from({ length: Math.min(input.concurrency ?? 4, prepared.length) }, () => worker()));
			result.results = results.filter((value): value is NonNullable<typeof value> => value !== undefined);
			if (context.signal?.aborted) result.status = "cancelled";
			else if (errors.length || result.results.some(child => child.status !== "completed")) result.status = "failed";
			const failures = result.results.filter(child => child.status === "failed").map(child => `${child.agent}: ${child.error ?? "failed"}`);
			if (failures.length) result.error = failures.join("; ");
			return result;
		}
		for (let index = 0; index < prepared.length; index++) {
			if (context.signal?.aborted) { result.status = "cancelled"; break; }
			const { step, agent, model } = prepared[index];
			const task = chained ? step.task.replace(/\{(previous|task)\}/g, (_match, key) => key === "previous" ? previousOutput : input.task ?? "") : step.task;
			if (!task.trim()) throw new Error("Resolved child task is empty");
			const singleResult = await runSync(agent, task, model, index, context, factory);
			result.results.push(singleResult);
			if (singleResult.status !== "completed") { result.status = singleResult.status; break; }
			previousOutput = singleResult.output;
		}
	} catch (error) {
		result.status = context.signal?.aborted ? "cancelled" : "failed";
		result.error = error instanceof Error ? error.message : String(error);
	} finally {
		try { await factory.dispose(); }
		catch (error) { result.status = "failed"; result.error = `Child cleanup failed: ${String(error)}`; }
	}
	return result;
}
