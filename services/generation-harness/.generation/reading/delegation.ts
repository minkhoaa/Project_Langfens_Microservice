import { readFileSync } from "node:fs";
import { extname, join, relative } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "generation-harness-core";
import { registerWorkflowResource } from "generation-subagents/workflow-resources";
import { registerRequiredChildExtensions } from "generation-subagents/required-child-extensions";
import { registerSubagentCapabilityCeiling } from "generation-subagents/capability-ceiling";
import { checkedPath, fields, object, policyError, prepareChild, specialistNames, taskRequest, validateRequest, type ChildScope, type TaskRequest } from "./scopes.ts";

export const previousMarker = "\n\nAuthorized previous stage output:\n";
export const readingPlanName = "reading.plan";
type NativeItem = { key: string; agent: string; task: string; cwd: string; output: string; previous: boolean; model?: string };

/** Fixed resource expansion only; the existing Subagents runtime executes it. */
export function registerReadingDelegation(api: ExtensionAPI, ctx: ExtensionContext, childGuardPath: string) {
  const sessionId = ctx.sessionManager.getSessionId();
  const required = registerRequiredChildExtensions({ sessionId, extensions: [{ id: "reading-child-scope", path: childGuardPath }], requireForAllRunners: true });
  const ceiling = registerSubagentCapabilityCeiling({ sessionId, source: "reading-workspace", ceiling: {
    allowedAgents: [...specialistNames], allowedTools: ["read", "write", "edit", "bash", "get_question_spec", "validate_question", "validate_group", "validate_exam", "verify_evidence", "check_grading_parity", "inspect_delivery_projection"],
  } });
  const resource = registerWorkflowResource({ sessionId, definition: { name: readingPlanName, version: 1, resolve(args) {
    try {
      fields(args, ["stages"], "prepared plan");
      if (!Array.isArray(args.stages) || !args.stages.length || args.stages.length > 16) policyError("Invalid prepared plan");
      const lines = ["const stages = [];", "function checked(rows) { if (rows.some(row => !row.ok)) throw new Error('Reading workflow child failed; inspect native child diagnostics.'); return rows; }"];
      for (const [index, stage] of (args.stages as unknown[][]).entries()) {
        if (!Array.isArray(stage) || !stage.length || stage.length > 8) policyError("Invalid prepared stage");
        const items = (stage as NativeItem[]).map(item => {
          const task = JSON.stringify(item.task) + (item.previous ? ` + ${JSON.stringify(previousMarker)} + stages[${index - 1}].map(row => row.output).join('\\n\\n')` : "");
          return `{...${JSON.stringify({ key: item.key, agent: item.agent, cwd: item.cwd, output: item.output, ...(item.model ? { model: item.model } : {}), context: "fresh", async: false, worktree: false, agentScope: "project", share: false, artifacts: false, acceptance: false })}, task: ${task}}`;
        });
        lines.push(`stages.push(checked(await runs.all([${items.join(",")}])));`);
      }
      lines.push("return { ok: true, stages };");
      return { script: lines.join("\n") }; // No runs.host authority is issued.
    } catch (error) { return { error: String(error) }; }
  } } });
  return () => { resource.dispose(); ceiling.dispose(); required.dispose(); };
}

export function prepareDelegation(run: string, ctx: ExtensionContext, input: Record<string, unknown>) {
  const parentSessionId = ctx.sessionManager.getSessionId();
  let stages: TaskRequest[][];
  const single = input.workflow === undefined;
  if (single) {
    stages = [[taskRequest(input)]];
    if (stages[0][0].previous) policyError("previous is only supported after a workflow stage");
  } else {
    fields(input, ["workflow", "args"], "workflow");
    if (input.workflow === "parallel") {
      const args = object(input.args, "parallel args"); fields(args, ["tasks"], "parallel args");
      if (!Array.isArray(args.tasks) || !args.tasks.length || args.tasks.length > 8) policyError("Parallel requires 1–8 specialist tasks (native bound)");
      stages = [(args.tasks as unknown[]).map(taskRequest)];
    } else {
      let raw: unknown;
      if (typeof input.workflow === "string" && input.workflow.includes("/")) {
        const path = checkedPath(run, input.workflow);
        if (!relative(run, path).replaceAll("\\", "/").startsWith("workflows/") || extname(path) !== ".json" || input.args !== undefined) policyError("Only JSON plans in workflows/ are supported; raw scripts have unguarded child launch/host-gate controls in the frozen SDK");
        raw = JSON.parse(readFileSync(checkedPath(run, path, true), "utf8"));
      } else if (input.workflow === readingPlanName) raw = input.args;
      else policyError("Use parallel or reading.plan; arbitrary scripts and host-command resources cannot be safely authorized by current public hooks");
      const plan = object(raw, "Reading plan"); fields(plan, ["steps"], "Reading plan");
      if (!Array.isArray(plan.steps) || !plan.steps.length || plan.steps.length > 16) policyError("A plan needs 1–16 stages");
      stages = (plan.steps as unknown[]).map(step => {
        const value = object(step, "plan step");
        if (Object.hasOwn(value, "parallel")) {
          fields(value, ["parallel"], "parallel step");
          if (!Array.isArray(value.parallel) || !value.parallel.length || value.parallel.length > 8) policyError("Invalid parallel stage");
          return (value.parallel as unknown[]).map(taskRequest);
        }
        return [taskRequest(value)];
      });
    }
  }
  if (stages.flat().length > 32) policyError("A Reading plan permits at most 32 child launches");
  const grants = new Set<string>();
  stages.forEach((stage, index) => stage.forEach(request => {
    if (request.previous && index === 0) policyError("The first stage has no previous output");
    if (request.debugGrant) { if (grants.has(request.debugGrant)) policyError("Debug grants are single-use"); grants.add(request.debugGrant); }
    validateRequest(run, parentSessionId, request);
  })); // All-or-nothing authorization before preparing or executing any child.
  const prepared = stages.map(stage => stage.map(request => prepareChild(run, parentSessionId, request)));
  const scopes: ChildScope[] = prepared.flat().map(item => item.scope);
  for (const key of Object.keys(input)) delete input[key];
  const controls = { context: "fresh", agentScope: "project", share: false, artifacts: false, acceptance: false, sessionDir: join(run, ".sessions") };
  if (single) Object.assign(input, prepared[0][0].launch, { async: false, worktree: false, options: controls });
  else {
    const args = { stages: prepared.map((stage, i) => stage.map((item, j) => ({ ...item.launch, key: `stage-${i + 1}-${j + 1}`, previous: item.scope.previous }))) };
    if (Buffer.byteLength(JSON.stringify(args), "utf8") > 16 * 1024) policyError("Prepared workflow exceeds the native 16 KiB args limit; use input files or smaller batches");
    Object.assign(input, { workflow: readingPlanName, args, cwd: run, async: false, worktree: false, options: controls });
  }
  return scopes;
}
