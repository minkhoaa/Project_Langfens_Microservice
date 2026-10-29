import type { ExtensionAPI } from "generation-harness-core";
import { families, report, spec, type Kind } from "./contracts.ts";
import { extractMessageText, stableJson, validateBlindTaskInput } from "./projection.ts";

const redacted = () => ({
  content: [{ type: "text" as const, text: "[BLIND_TOOL_RESULT_REDACTED]" }],
  details: { redacted: true },
  isError: true,
});

// The blind child has exactly one public, deterministic tool. Accept its actual
// static specification, not arbitrary data that merely lacks known key names.
function isPublicSpecResult(content: unknown, details: unknown): boolean {
  if (!details || typeof details !== "object" || !("type" in details)) return false;
  const type = details.type;
  if (typeof type !== "string" || !Object.hasOwn(families, type)) return false;
  const expected = report([], spec(type as Kind));
  return stableJson(details) === stableJson(expected) &&
    stableJson(content) === stableJson([{ type: "text", text: JSON.stringify(expected) }]);
}

/** Child-only native policy; registers no tools and implements no execution loop. */
export default function blindGuard(api: ExtensionAPI) {
  api.on("input", (event, ctx) => {
    // Blind solves are single-task fresh sessions. Reject pre-existing history,
    // rather than trying to recognize secrets inside arbitrary inherited prose.
    const hasHistory = ctx.sessionManager.getBranch().some(entry => entry.type === "message");
    // Native Subagents envelopes fresh task text as exactly `Task: ${task}`.
    // Remove only that fixed envelope, then apply the unchanged public schema;
    // prose, extra instructions, private fields and repeated envelopes still fail.
    const text = event.text.startsWith("Task: ") ? event.text.slice(6) : event.text;
    if (hasHistory || event.images?.length || !validateBlindTaskInput(text).ok) {
      return { action: "handled" };
    }
    return text === event.text ? { action: "continue" } : { action: "transform", text };
  });

  api.on("before_agent_start", (event, ctx) => {
    if (event.messageType !== "user" || !validateBlindTaskInput(event.prompt).ok) ctx.abort();
  });

  const guardContext = (event: { messages: Array<{ role: string; content?: unknown; toolName?: string; details?: unknown; isError?: boolean }> }, ctx: { abort(): void }) => {
    const messages = event.messages.filter(message => message.role !== "system");
    const users = messages.filter(message => message.role === "user");
    if (users.length !== 1 || messages[0] !== users[0] || !validateBlindTaskInput(extractMessageText(users[0])).ok) {
      for (const message of messages) message.content = [{ type: "text", text: "[BLIND_INPUT_REJECTED]" }];
      ctx.abort();
      return;
    }
    for (const message of messages) {
      if (message.role === "toolResult" &&
          !(message.toolName === "get_question_spec" && isPublicSpecResult(message.content, message.details))) {
        Object.assign(message, redacted());
      }
    }
  };
  api.on("context", guardContext);
  api.on("context_with_system", guardContext);

  api.on("session_before_fork", () => ({ cancel: true }));
  api.on("tool_call", event => {
    if (event.toolName !== "get_question_spec") {
      return { block: true, reason: "BLIND_TOOL_NOT_PERMITTED" };
    }
  });
  api.on("tool_result", event => {
    if (event.toolName !== "get_question_spec" || event.isError ||
        !isPublicSpecResult(event.content, event.details) || event.structuredContent !== undefined) {
      return redacted();
    }
  });
}
