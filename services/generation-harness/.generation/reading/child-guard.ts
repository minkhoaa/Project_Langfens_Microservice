import { randomUUID } from "node:crypto";
import { existsSync, readFileSync } from "node:fs";
import { isAbsolute, join, relative, resolve, sep } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "generation-harness-core";
import blindGuard from "./blind-guard.ts";
import { extractMessageText } from "./projection.ts";
import { checkedPath, digest, exclusiveJson, latestAnswer, loadChildScope, pathSpelling, policyError, readJson, type ChildScope, type SolveReceipt } from "./scopes.ts";
import { scopedBash } from "./sandbox.ts";
import { previousMarker } from "./delegation.ts";

/** Required child extension: real per-child cwd and least-privilege file scopes. */
export default function childGuard(api: ExtensionAPI) {
  const assigned = process.env.GENERATION_HARNESS_READING_WORKSPACE;
  if (!assigned) throw new Error("READING_POLICY: Child scope requires an assigned Reading run");
  const run = resolve(assigned);
  let scope: ChildScope | undefined, nativeSessionId = "", sealed = false;
  const pending = new Map<string, string>();
  const pathFor = (raw: unknown, writing = false, mustExist = false) => {
    if (!scope) policyError("Child scope has not been initialized");
    pathSpelling(raw);
    const base = !isAbsolute(raw) && !["inputs", "workspace", "outputs"].includes(raw.split("/")[0]) ? scope!.cwd : scope!.root;
    const path = checkedPath(scope!.root, resolve(base, raw), mustExist);
    const parts = relative(scope!.root, path).split(sep).filter(Boolean);
    if (parts.length && !["inputs", "workspace", "outputs"].includes(parts[0])) policyError("A child cannot read parent, metadata, keys or sibling folders");
    if (writing && (parts.length < 2 || !["workspace", "outputs"].includes(parts[0]))) policyError("Child writes belong only to its own workspace or outputs; inputs are read-only");
    return path;
  };
  let bash: ReturnType<typeof scopedBash> | undefined;
  const taskMatches = (text: string) => !!scope && (text === scope.task || (scope.previous && text.startsWith(scope.task + previousMarker)));
  const record = (value: unknown) => exclusiveJson(run, `.history/child-edits/${randomUUID()}.json`, { childId: scope!.id, ...value as object });
  function snapshot(path: string, phase: string, toolCallId: string) {
    pathFor(path);
    record({ phase, toolCallId, path: relative(scope!.root, path), content: existsSync(path) ? readFileSync(path, "utf8") : null });
  }
  function seal(ctx: ExtensionContext) {
    if (!scope || sealed) return;
    const branch = ctx.sessionManager.getBranch();
    const result = latestAnswer(branch);
    const user = branch.find(entry => entry.type === "message" && entry.message.role === "user");
    const observedTaskHash = digest(user?.type === "message" ? extractMessageText(user.message) : "");
    if (!result.completed) return;
    const receipt: SolveReceipt = { version: 1, id: scope.id, agent: scope.agent, profile: scope.profile, nativeSessionId,
      ...result, inputHashes: [observedTaskHash, ...scope.inputs.map(input => input.sha256)],
      ...(scope.debugOf ? { debugOf: scope.debugOf } : {}), ...(scope.recheckOf ? { recheckOf: scope.recheckOf } : {}),
      blindness: scope.profile === "debug" ? "NON_BLIND" : scope.profile === "strict-blind" ? "STRUCTURAL_ONLY" : "UNVERIFIED",
      independentBlindEvidence: scope.agent === "blind-solver" && scope.profile === "strict-blind",
      ieltsQualityEstablished: false, accepted: false, published: false };
    // Exclusive, immutable-to-model receipt freezes the original answer before any key grant.
    exclusiveJson(run, `.history/attempts/${scope.id}.json`, receipt);
    sealed = true;
  }
  api.on("session_start", (_event, ctx) => {
    scope = loadChildScope(run, ctx.cwd);
    nativeSessionId = ctx.sessionManager.getSessionId();
    const binding = `.history/bindings/${scope.id}.json`;
    if (existsSync(join(run, binding))) {
      if (readJson<{ nativeSessionId: string }>(run, binding).nativeSessionId !== nativeSessionId) policyError("A child scope cannot be reused by another session");
    } else {
      if (ctx.sessionManager.getBranch().some(entry => entry.type === "message")) policyError("Children must not inherit conversation history");
      exclusiveJson(run, binding, { nativeSessionId, profile: scope.profile, childId: scope.id });
    }
    if (scope.profile === "strict-blind") {
      blindGuard(api);
      api.setActiveTools(["get_question_spec"]);
    }
    bash = scopedBash(api, scope.root, pathFor, scope.cwd);
  });
  api.on("input", (event, ctx) => {
    let text = event.text.startsWith("Task: ") ? event.text.slice(6) : event.text;
    // Strip only the native output envelope bound to this exact approved path.
    // The frozen SDK adds it after the original task, even for strict solves.
    if (scope) {
      for (const delivery of [
        `Write your findings to exactly this path: ${scope.output}`,
        `Return the complete artifact in your final response.\nThe runtime will persist it to exactly this path: ${scope.output}\nDo not call contact_supervisor merely because no write-capable tool is available.`,
      ]) {
        const suffix = `\n\n---\n**Output:**\n${delivery}\nThis path is authoritative for this run.\nIgnore any other output filename or output path mentioned elsewhere, including output destinations in the system prompt or the task instructions.`;
        if (text.endsWith(suffix)) { text = text.slice(0, -suffix.length); break; }
      }
    }
    if (!scope || event.images?.length || ctx.sessionManager.getBranch().some(entry => entry.type === "message") || !taskMatches(text)) return { action: "handled" };
    return text === event.text ? { action: "continue" } : { action: "transform", text };
  });
  api.on("before_agent_start", (event, ctx) => {
    if (!scope || event.messageType !== "user" || !taskMatches(event.prompt)) { ctx.abort(); return; }
    const labels = scope.profile === "debug"
      ? "NON_BLIND debugging: compare the frozen original solve with the approved key and passage. Neither key nor solver is assumed correct. Propose a versioned correction, or UNCERTAIN for human adjudication. You are NOT independent blind evidence."
      : scope.profile === "strict-blind"
        ? "STRICT BLIND: solve only canonical student projection. No filesystem tools or keys. Structural isolation does not establish IELTS semantic quality."
        : "AUTHORING/TEST: natural-language and file inputs are allowed. Content blindness is UNVERIFIED; do not claim certified independent blind validation.";
    return { systemPrompt: `${event.systemPrompt}\n\n${labels}\nAssigned child workspace: ${scope.root}\nNative cwd: ${scope.cwd}. Plain filenames resolve here; inputs/, workspace/ and outputs/ prefixes resolve from the child root.\nRead only assigned inputs/, workspace/ and outputs/. Inputs are immutable snapshots; write only workspace/ or outputs/. Never access parent, sibling or other-session files.\nFinal output binding: ${scope.output}\nInput files: ${scope.inputs.map(input => join(scope!.root, "inputs", input.name)).join(", ") || "none; task text only"}\nNever publish or accept exams. Preserve ambiguity and diagnostics.` };
  });
  const contextGuard = (event: { messages: Array<{ role: string; content?: unknown }> }, ctx: { abort(): void }) => {
    const users = event.messages.filter(message => message.role === "user");
    if (!scope || users.length !== 1 || !taskMatches(extractMessageText(users[0]))) {
      for (const message of event.messages) if (message.role !== "system") message.content = [{ type: "text", text: "[READING_CHILD_CONTEXT_REJECTED]" }];
      ctx.abort();
    }
  };
  api.on("context", contextGuard); api.on("context_with_system", contextGuard);
  api.on("tool_call", event => {
    try {
      if (!scope || sealed) policyError("Child scope is uninitialized or already frozen");
      if (event.toolName === "read" || event.toolName === "write" || event.toolName === "edit") {
        const writing = event.toolName !== "read";
        const path = pathFor(event.input.path, writing, event.toolName !== "write");
        event.input.path = path;
        if (writing) {
          if ([...pending.values()].includes(path)) policyError("Serialize concurrent revisions to the same child artifact");
          snapshot(path, "before", event.toolCallId); pending.set(event.toolCallId, path);
        }
      } else if (event.toolName === "bash") {
        if (scope!.agent === "blind-solver" || !bash) policyError("Solver uses read/write/edit, not a shell");
        event.input.command = bash!(event.input.command); event.input.timeout = 5;
      } else if (!["get_question_spec", "validate_question", "validate_group", "validate_exam", "verify_evidence", "check_grading_parity", "inspect_delivery_projection"].includes(event.toolName)) policyError("Child tool is outside its role");
    } catch (error) { return { block: true, reason: String(error) }; }
  });
  api.on("tool_result", event => {
    const path = pending.get(event.toolCallId);
    if (path) { pending.delete(event.toolCallId); snapshot(path, event.isError ? "error" : "after", event.toolCallId); }
  });
  api.on("agent_settled", (_event, ctx) => seal(ctx));
  api.on("session_shutdown", (_event, ctx) => seal(ctx));
  api.on("session_before_switch", () => ({ cancel: true }));
  api.on("session_before_fork", () => ({ cancel: true }));
  api.on("user_bash", () => ({ result: { output: "READING_POLICY: Use guarded tools, not direct shell execution.", exitCode: 1, cancelled: false, truncated: false } }));
}
