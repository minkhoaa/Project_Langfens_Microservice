import type { Model } from "generation-harness-core/ai";
import { validateAgentDefinitions } from "../../agents/agents.ts";
import type { AgentDefinition, ChildTask, SubagentExecutionContext, SubagentInput, SubagentRunResult } from "../../types.ts";
import { createDefaultChildSessionFactory } from "../shared/child-session.ts";
import { loadHostHarnessCore } from "../shared/harness-spawn.ts";
import { runSync } from "./execution.ts";

/** Narrow adapter of the pinned single/ordered path, not a new agent or workflow engine. */
export async function executeSubagent(input: SubagentInput, context: SubagentExecutionContext): Promise<SubagentRunResult> {
	if (!input || typeof input !== "object") throw new Error("Subagent input must name an agent or nonempty chain");
	const chained = "chain" in input;
	const allowed = chained ? ["chain", "task"] : ["agent", "task", "model"];
	for (const key of Object.keys(input)) if (!allowed.includes(key)) throw new Error(`Unsupported subagent option: ${key}`);
	const steps: ChildTask[] = chained ? input.chain : [input];
	if (!Array.isArray(steps) || !steps.length) throw new Error("Subagent chain must not be empty");
	const agents = validateAgentDefinitions(context.agents);
	const core = await loadHostHarnessCore();
	const prepared: Array<{ step: ChildTask; agent: AgentDefinition; model: Model<any> }> = [];
	for (const step of steps) {
		if (!step || typeof step.agent !== "string" || typeof step.task !== "string" || !step.task.trim()) throw new Error("Each child requires an agent and nonempty task");
		for (const key of Object.keys(step)) if (!["agent", "task", "model"].includes(key)) throw new Error(`Unsupported child option: ${key}`);
		if (step.model !== undefined && (typeof step.model !== "string" || !step.model.trim())) throw new Error("Invalid child model override");
		const agent = agents.find(candidate => candidate.name === step.agent.trim());
		if (!agent) throw new Error(`Unknown agent '${step.agent}'. Configure a Langfens agent definition first.`);
		if (chained && step.task.includes("{task}") && typeof input.task !== "string") throw new Error("Chain task references {task} without an original task");
		const selection = step.model ?? agent.model;
		const resolved = selection ? core.resolveCliModel({ cliModel: selection, modelRuntime: context.modelRuntime }) : undefined;
		if (resolved?.error) throw new Error(`Invalid child model: ${resolved.error}`);
		const model = resolved?.model ?? context.parentModel;
		if (!model || !context.modelRuntime.getModel(model.provider, model.id)) throw new Error("No configured child/parent model is available");
		prepared.push({ step, agent, model });
	}
	const result: SubagentRunResult = { status: "completed", results: [] };
	const factory = createDefaultChildSessionFactory(context);
	let previousOutput = "";
	try {
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
