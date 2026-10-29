import { randomUUID } from "node:crypto";
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { extname, join, relative, resolve, sep } from "node:path";
import { SessionManager, type ExtensionAPI } from "generation-harness-core";
import { prepareDelegation, registerReadingDelegation } from "./delegation.ts";
import { checkedPath, exclusiveJson, grantDebug, policyError, readJson, type ChildScope, type SolveReceipt } from "./scopes.ts";
import { scopedBash } from "./sandbox.ts";
import { nextReadingConfiguration, readingPrompt } from "./workspace.mjs";

const domainTools = new Set(["get_question_spec", "validate_question", "validate_group", "validate_exam", "verify_evidence", "check_grading_parity", "inspect_delivery_projection"]);
const areas = new Set(["input", "inputs", "drafts", "reviews", "revisions", "final", "artifacts", "workflows", "children", ".history"]);

/** Native application policy. Domain validation is not an execution coordinator. */
export default function workspaceGuard(api: ExtensionAPI) {
  const assigned = process.env.GENERATION_HARNESS_READING_WORKSPACE;
  if (!assigned) return; // Development/legacy VS fixtures are unchanged.
  const run = resolve(assigned);
  let initializationError: string | undefined, disposeDelegation: (() => void) | undefined, pendingSwitch: string | undefined;
  try {
    if (readJson<{ workspace: string }>(run, ".history/run.json").workspace !== run) policyError("Workspace assignment mismatch");
  } catch (error) { initializationError = String(error); }

  function pathFor(raw: unknown, writing = false, mustExist = false) {
    if (initializationError) policyError(initializationError);
    const path = checkedPath(run, raw, mustExist, true);
    const parts = relative(run, path).split(sep).filter(Boolean), area = parts[0];
    if (parts.some((part, index) => part.startsWith(".") && !(index === 0 && part === ".history"))) policyError("Native configuration/hidden files are not authoring artifacts");
    if (parts.length && !areas.has(area)) policyError("Unknown authoring area");
    if (writing) {
      if (parts.length < 2 || ["input", "inputs", ".history"].includes(area)) policyError("Input snapshots, receipts and audit metadata are read-only");
      if (area === "reviews" && parts[1].startsWith("validation-")) policyError("Validation diagnostics are immutable to model tools");
      if (area === "children" && !["workspace", "outputs"].includes(parts[2])) policyError("Child inputs and scope metadata are immutable");
      if (![".md", ".txt", ".json", ".csv"].includes(extname(path))) policyError("Only exam artifacts and JSON workflow plans are editable");
    }
    return path;
  }
  const bash = scopedBash(api, run, pathFor);
  const pendingEdits = new Map<string, string>(), pendingDelegations = new Map<string, ChildScope[]>();
  const record = (directory: ".history" | "reviews", value: unknown) => exclusiveJson(run,
    `${directory}/${directory === "reviews" ? "validation-" : ""}${randomUUID()}.json`, value);
  const snapshot = (path: string, phase: string, toolCallId: string) => {
    pathFor(path);
    record(".history", { path: relative(run, path), phase, toolCallId, at: new Date().toISOString(), content: existsSync(path) ? readFileSync(path, "utf8") : null });
  };

  api.on("session_start", (_event, ctx) => {
    const allowed = new Set(["read", "bash", "edit", "write", ...domainTools, "subagent"]);
    try {
      if (initializationError || ctx.cwd !== run) policyError(initializationError ?? "Parent cwd must equal its assigned run");
      const bindingPath = ".history/parent-session.json";
      const sessionId = ctx.sessionManager.getSessionId();
      if (existsSync(join(run, bindingPath))) {
        if (readJson<{ sessionId: string }>(run, bindingPath).sessionId !== sessionId) policyError("A new session requires a new Reading folder; use /reading-new");
      } else exclusiveJson(run, bindingPath, { sessionId, workspace: run });
      disposeDelegation?.();
      disposeDelegation = registerReadingDelegation(api, ctx, join(run, ".generation/reading/child-guard.ts"));
      api.setActiveTools(api.getActiveTools().filter(name => allowed.has(name)));
    } catch (error) { initializationError = String(error); api.setActiveTools([]); throw error; }
  });
  api.on("session_shutdown", () => { disposeDelegation?.(); disposeDelegation = undefined; });
  api.on("before_agent_start", () => ({ systemPrompt: readingPrompt(run) }));
  api.on("tool_call", (event, ctx) => {
    try {
      if (initializationError) policyError(initializationError);
      if (event.toolName === "read" || event.toolName === "write" || event.toolName === "edit") {
        const writing = event.toolName !== "read", path = pathFor(event.input.path, writing, event.toolName !== "write");
        event.input.path = path;
        if (writing) {
          if ([...pendingEdits.values()].includes(path)) policyError("Concurrent revisions of the same artifact must be serialized");
          snapshot(path, "before", event.toolCallId); pendingEdits.set(event.toolCallId, path);
        }
      } else if (event.toolName === "bash") {
        event.input.command = bash(event.input.command); event.input.timeout = 5;
      } else if (event.toolName === "subagent") {
        pendingDelegations.set(event.toolCallId, prepareDelegation(run, ctx, event.input));
      } else if (!domainTools.has(event.toolName)) policyError("Tool is outside the Reading authoring environment");
    } catch (error) { return { block: true, reason: String(error) }; }
  });
  api.on("tool_result", event => {
    const path = pendingEdits.get(event.toolCallId);
    if (path) { pendingEdits.delete(event.toolCallId); snapshot(path, event.isError ? "error" : "after", event.toolCallId); }
    if (domainTools.has(event.toolName)) record("reviews", {
      toolName: event.toolName, toolCallId: event.toolCallId, isError: event.isError, content: event.content, details: event.details,
      next: "REVIEW_OR_HUMAN_ADJUDICATION", accepted: false, published: false,
    });
    const scopes = pendingDelegations.get(event.toolCallId);
    if (scopes) {
      pendingDelegations.delete(event.toolCallId);
      const attempts = scopes.map(scope => {
        const file = `.history/attempts/${scope.id}.json`;
        const receipt = existsSync(join(run, file)) ? readJson<SolveReceipt>(run, file) : undefined;
        return { id: scope.id, workspace: scope.root, cwd: scope.cwd, agent: scope.agent, profile: scope.profile,
          blindness: scope.profile === "debug" ? "NON_BLIND" : scope.profile === "strict-blind" ? "STRUCTURAL_ONLY" : "UNVERIFIED",
          frozen: !!receipt, independentBlindEvidence: receipt?.independentBlindEvidence ?? false,
          ...(scope.debugOf ? { debugOf: scope.debugOf } : {}), ...(scope.recheckOf ? { recheckOf: scope.recheckOf } : {}),
          ieltsQualityEstablished: false, accepted: false, published: false };
      });
      return { details: { ...(event.details && typeof event.details === "object" ? event.details : {}), reading: { attempts, next: "REVIEW_OR_HUMAN_ADJUDICATION" } },
        content: [...event.content, { type: "text", text: `Reading scope receipts: ${JSON.stringify(attempts)}` }] };
    }
  });
  // Only an operator slash command can issue a key grant, never a model tool call.
  api.registerCommand("reading-debug", { description: "Approve selected key snapshots for a fresh NON_BLIND debugger: JSON {attemptId,keys:[...]}.",
    handler: async (args, ctx) => {
      if (initializationError || ctx.cwd !== run) policyError("Debug approval is outside the current run");
      const id = grantDebug(run, ctx.sessionManager.getSessionId(), JSON.parse(args));
      ctx.ui.notify(`NON_BLIND debug grant: ${id}. Use blind-solver with options.reading.profile=debug and debugGrant=${id}. Original solve stays frozen.`, "info");
    } });
  api.registerCommand("reading-new", { description: "Create a new Reading workspace and empty native session without importing previous artifacts.",
    handler: async (args, ctx) => {
      if (args.trim() || initializationError || ctx.cwd !== run) policyError("Use /reading-new without arguments from the active Reading session");
      await ctx.waitForIdle();
      const next = nextReadingConfiguration(run, { ...process.env, GENERATION_HARNESS_AGENT_DIR: ctx.agentDir });
      const manager = SessionManager.create(next.workspace, join(next.workspace, ".sessions"));
      const file = manager.getSessionFile(), header = manager.getHeader();
      if (!file || !header) policyError("Native session manager did not allocate a fresh session header");
      // Persist the SDK-produced header, not an invented session format/history.
      writeFileSync(file!, JSON.stringify(header) + "\n", { flag: "wx", mode: 0o600 });
      const previous = new Map(Object.keys(next.env).map(key => [key, process.env[key]]));
      pendingSwitch = file;
      Object.assign(process.env, next.env);
      let switched = false;
      try {
        const result = await ctx.switchSession(file!, { withSession: async current => {
          current.ui.notify(`New Reading workspace: ${next.workspace}`, "info");
        } });
        switched = !result.cancelled;
        if (!switched) policyError("Fresh session transition was cancelled; original session remains active");
      } finally {
        pendingSwitch = undefined;
        if (!switched) for (const [key, value] of previous) { if (value === undefined) delete process.env[key]; else process.env[key] = value; }
      }
    } });
  api.on("user_bash", () => ({ result: { output: "READING_POLICY: Direct user shell is disabled; use guarded bash.", exitCode: 1, cancelled: false, truncated: false } }));
  api.on("session_before_switch", (event, ctx) => {
    if (!initializationError && ctx.cwd === run && pendingSwitch && event.reason === "resume" && event.targetSessionFile === pendingSwitch) return { cancel: false };
    if (event.reason === "new") ctx.ui.notify("Use /reading-new to create a new session AND workspace. Native /new cannot change cwd through the frozen public API.", "warning");
    return { cancel: true };
  });
  api.on("session_before_fork", () => ({ cancel: true }));
}
