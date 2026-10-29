import { diagnostic as d, type Diagnostic } from "./contracts.ts";

export type RepairState = { questionId: string; attempts: number; signature: string; identity: string; stopped: boolean; reason?: string };
/** Admission of validation/revalidation only. Never runs a repair or mutates an artifact. */
export class QuestionRepairPolicy {
  private states = new Map<string, RepairState>();
  clear() { this.states.clear(); }
  restore(state: RepairState) {
    if (state && typeof state.questionId === "string" && Number.isInteger(state.attempts) && state.attempts >= 0 && typeof state.signature === "string" && typeof state.identity === "string" && typeof state.stopped === "boolean") this.states.set(state.questionId, { ...state });
  }
  check(q: { id: string; groupId?: string; sectionId?: string; idx: number; type: string }, diagnostics: Diagnostic[]) {
    const identity = JSON.stringify([q.groupId, q.sectionId, q.idx, q.type]);
    const errors = diagnostics.filter(x => x.severity === "error");
    const signature = JSON.stringify(errors.map(x => [x.code, x.path]).sort());
    let state = this.states.get(q.id);
    const extra: Diagnostic[] = [];
    if (!state && errors.length) {
      state = { questionId: q.id, attempts: 0, signature, identity, stopped: errors.some(x => x.category !== "invalid-input") };
      if (state.stopped) state.reason = "Nonretryable capability/semantic blocker";
    } else if (state) {
      if (!state.stopped) {
        state.attempts++;
        if (identity !== state.identity) { state.stopped = true; state.reason = "Question identity/membership/type changed"; }
        else if (signature === state.signature && errors.length) { state.stopped = true; state.reason = "No diagnostic progress"; extra.push(d("REPAIR_NO_PROGRESS", "/question", state.reason)); }
        else if (errors.some(x => x.category !== "invalid-input")) { state.stopped = true; state.reason = "Nonretryable capability/semantic blocker"; }
        else if (state.attempts >= 2 && errors.length) { state.stopped = true; state.reason = "Two repair submissions exhausted"; }
        state.signature = signature; // Compare against the immediately preceding validation, not the original one.
      }
      if (state.stopped) extra.push(d("REPAIR_LIMIT_EXCEEDED", "/question", `Automated repair halted: ${state.reason}. Human review required.`, "error", "unsupported-capability", "Do not retry or replace IDs to evade the question-local stop."));
      // A resolved lineage is retained; a new error cannot reset its budget.
      if (state.attempts >= 2 && !errors.length) { state.stopped = true; state.reason = "Two repair submissions consumed; subsequent revisions require human review"; }
    }
    if (state) this.states.set(q.id, state);
    return { diagnostics: [...diagnostics, ...extra], ...(state ? { repairState: { ...state } } : {}) };
  }
}
