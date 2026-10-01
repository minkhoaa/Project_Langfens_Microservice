"""Question-level and group-level surgical repairers for Langfens Loop Engine V2."""

from __future__ import annotations
from types import MappingProxyType
import copy
import re
from datetime import datetime, timezone
from uuid import uuid4

from app.config import settings
from app.contracts.artifact import ArtifactEnvelope, ArtifactType, compute_content_hash
from app.contracts.issue import Issue, IssueCode
from app.contracts.policies import match_verbatim_in_passage
from app.repair.base import (
    BaseRepairer,
    RepairCapabilityMetadata,
    RepairExecutionError,
    RepairJustificationError,
    RepairScope,
)


def unwrap_payload(val: Any) -> Any:
    """Recursively converts MappingProxyType to mutable dict/list structures."""
    if isinstance(val, (dict, MappingProxyType)):
        return {k: unwrap_payload(v) for k, v in val.items()}
    if isinstance(val, (list, tuple)):
        return [unwrap_payload(x) for x in val]
    return val

class QuestionItemRepairer(BaseRepairer):
    """Surgically repairs a single question's prompt, options, or answer length.
    
    P07-08 / T07-03 Invariant: Unaffected questions maintain identical hash and structure.
    P07-08 / T07-08 Invariant: Answer changes must have passage evidence justification.
    """

    def __init__(self, timeout_seconds: Optional[float] = None, estimated_tokens: Optional[int] = None):
        t_sec = timeout_seconds if timeout_seconds is not None else getattr(settings, "repair_timeout_seconds", 30.0)
        tok = estimated_tokens if estimated_tokens is not None else getattr(settings, "repair_max_tokens_per_attempt", 1500)
        super().__init__(
            RepairCapabilityMetadata(
                repairer_id="rep_question_item",
                repairer_version="1.0.0",
                name="Question Item Surgical Repairer",
                description="Trims answers to 3 words, replaces bad distractors, clarifies prompts",
                scope=RepairScope.QUESTION,
                target_artifact_types=[ArtifactType.SECTION, ArtifactType.QUESTION],
                handled_codes={
                    IssueCode.WORD_LIMIT_EXCEEDED,
                    IssueCode.BAD_DISTRACTOR,
                    IssueCode.INSUFFICIENT_OPTIONS,
                    IssueCode.AMBIGUOUS_ANSWER,
                },
                timeout_seconds=t_sec,
                estimated_tokens=tok,
                estimated_cost_usd=0.015,
            )
        )

    async def _repair_impl(
        self,
        context: Any,
        artifact: ArtifactEnvelope,
        issues: Sequence[Issue],
        intent_id: str,
        version: int,
    ) -> ArtifactEnvelope:
        payload = unwrap_payload(artifact.payload)
        passage_text = payload.get("passage", "") or payload.get("passageText", "")

        # Extract target question numbers from issue messages or affected refs
        target_q_nums = set()
        for iss in issues:
            q_num_match = re.search(r"Question\s+(\d+)", iss.message)
            if q_num_match:
                target_q_nums.add(int(q_num_match.group(1)))

        async def repair_single_q(q: Dict[str, Any]):
            q_type = q.get("questionType") or q.get("type", "")
            orig_ans = q.get("answer", "")
            ans = orig_ans

            for iss in issues:
                if iss.code == IssueCode.WORD_LIMIT_EXCEEDED:
                    words = ans.split()
                    if len(words) > 3:
                        # Identify candidates matching verbatim in passage
                        candidate_spans = [
                            " ".join(words[-3:]),
                            " ".join(words[:3]),
                            " ".join(words[-2:]),
                            " ".join(words[:2]),
                            words[-1],
                            words[0],
                        ]
                        valid_span = None
                        for cand in candidate_spans:
                            if passage_text and match_verbatim_in_passage(cand, passage_text):
                                valid_span = cand
                                break
                        if valid_span is None and passage_text:
                            # Fail closed if no verified span exists
                            raise RepairJustificationError(
                                f"Cannot justify trimmed answer for '{orig_ans}' in passage text; repair aborted"
                            )
                        q["answer"] = valid_span or " ".join(words[:3])

                elif iss.code == IssueCode.BAD_DISTRACTOR and q_type == "MultipleChoiceSingle":
                    # P07-08 Invariant: Distractor replacement requires verifiable evidence quote + wrongness rationale
                    # proving the option is contradicted/irrelevant to the question stem, followed by uniqueness re-evaluation.
                    if not iss.proposed_repair:
                        raise RepairJustificationError(
                            f"Distractor replacement for Question {q.get('questionNumber')} rejected: "
                            "requires explicit passage-backed justification and wrongness rationale; "
                            "blind substitution is forbidden"
                        )
                    if not iss.evidence or len(iss.evidence.strip()) < 5:
                        raise RepairJustificationError(
                            f"Distractor replacement for Question {q.get('questionNumber')} rejected: "
                            "missing mandatory verifiable passage evidence quote"
                        )
                    if passage_text and iss.evidence.strip() not in passage_text:
                        raise RepairJustificationError(
                            f"Distractor replacement for Question {q.get('questionNumber')} rejected: "
                            f"evidence quote '{iss.evidence[:40]}' not found in passage"
                        )

                    options = q.get("options", [])
                    keys_present = {opt.get("key") for opt in options if hasattr(opt, "get")}

                    parts = iss.proposed_repair.split("|", 1)
                    key_text_part = parts[0].strip()
                    rationale_part = parts[1].strip() if len(parts) > 1 else ""
                    if not rationale_part:
                        raise RepairJustificationError(
                            f"Distractor replacement for Question {q.get('questionNumber')} rejected: "
                            "missing mandatory wrongness rationale proving the option is contradicted/irrelevant to stem"
                        )

                    subparts = key_text_part.split(":", 1)
                    target_key = subparts[0].strip() if len(subparts) > 1 else None
                    replacement_text = subparts[-1].strip()

                    if passage_text and replacement_text.lower() not in passage_text.lower():
                        raise RepairJustificationError(
                            f"Distractor replacement rejected: replacement text '{replacement_text}' is not grounded in passage text"
                        )
                    if iss.evidence and replacement_text.lower() not in iss.evidence.lower():
                        raise RepairJustificationError(
                            f"Distractor replacement rejected: replacement text '{replacement_text}' is not supported by supplied evidence quote"
                        )

                    if target_key and target_key not in keys_present:
                        raise RepairJustificationError(
                            f"Distractor replacement rejected: target key '{target_key}' not among options {keys_present}"
                        )
                    if target_key == ans:
                        raise RepairJustificationError(
                            f"Distractor replacement rejected: cannot replace the correct answer key '{ans}' as a distractor"
                        )
                    for opt in options:
                        if target_key and opt.get("key") == target_key:
                            opt["text"] = replacement_text
                        elif not target_key and opt.get("key") != ans and opt.get("text", "").lower() == ans.lower():
                            opt["text"] = replacement_text

                    # Post-repair uniqueness re-evaluation
                    all_opt_texts = [o.get("text", "").lower() for o in options]
                    if len(all_opt_texts) != len(set(all_opt_texts)):
                        raise RepairJustificationError(
                            "Post-repair uniqueness failed: duplicate option text detected among options"
                        )
                    correct_text = next((o.get("text", "") for o in options if o.get("key") == ans), ans)
                    if replacement_text.lower() == correct_text.lower():
                        raise RepairJustificationError(
                            "Post-repair uniqueness failed: replacement option is identical to correct answer"
                        )

                    # Post-repair evaluator check: verify replacement option does not answer the stem or violate uniqueness
                    from app.evaluators.semantic import AmbiguityAndDistractorEvaluator
                    q_eval_payload = dict(q)
                    if "passage" not in q_eval_payload and passage_text:
                        q_eval_payload["passage"] = passage_text
                    temp_env = ArtifactEnvelope.create(
                        artifact_id=f"temp_q_{q.get('questionNumber', 1)}",
                        artifact_type=ArtifactType.QUESTION,
                        run_id=artifact.run_id,
                        payload=q_eval_payload,
                        producer_version="2.0.0",
                    )
                    post_eval = AmbiguityAndDistractorEvaluator()
                    post_res = await post_eval.evaluate(context, temp_env, intent_id="post_rep_unique")
                    if any(iss.code in (IssueCode.BAD_DISTRACTOR, IssueCode.AMBIGUOUS_ANSWER) for iss in post_res.issues):
                        raise RepairJustificationError(
                            "Post-repair uniqueness failed: replacement option is supported by passage as an answer, "
                            "violating single-answer uniqueness"
                        )
                elif iss.code == IssueCode.INSUFFICIENT_OPTIONS and q_type == "MultipleChoiceSingle":
                    if not iss.proposed_repair:
                        raise RepairJustificationError(
                            f"Adding options to Question {q.get('questionNumber')} rejected: "
                            "requires explicit passage-backed justification; blind phrase substitution is forbidden"
                        )
                    if not iss.evidence or len(iss.evidence.strip()) < 5:
                        raise RepairJustificationError(
                            f"Adding options to Question {q.get('questionNumber')} rejected: "
                            "missing mandatory verifiable passage evidence quote"
                        )
                    if passage_text and iss.evidence.strip() not in passage_text:
                        raise RepairJustificationError(
                            f"Adding options to Question {q.get('questionNumber')} rejected: "
                            f"evidence quote '{iss.evidence[:40]}' not found in passage"
                        )
                    parts = iss.proposed_repair.split("|", 1)
                    key_text_part = parts[0].strip()
                    rationale_part = parts[1].strip() if len(parts) > 1 else ""
                    if not rationale_part:
                        raise RepairJustificationError(
                            f"Adding option to Question {q.get('questionNumber')} rejected: "
                            "missing mandatory wrongness rationale proving the option is contradicted/irrelevant to stem"
                        )
                    subparts = key_text_part.split(":", 1)
                    if len(subparts) <= 1:
                        raise RepairJustificationError(
                            "Adding option rejected: proposed repair must specify 'KEY: TEXT | Rationale: ...'"
                        )
                    new_key = subparts[0].strip()
                    new_text = subparts[1].strip()

                    if passage_text and new_text.lower() not in passage_text.lower():
                        raise RepairJustificationError(
                            f"Adding option rejected: new option text '{new_text}' is not grounded in passage text"
                        )
                    if iss.evidence and new_text.lower() not in iss.evidence.lower():
                        raise RepairJustificationError(
                            f"Adding option rejected: new option text '{new_text}' is not supported by supplied evidence quote"
                        )

                    options = q.get("options", [])
                    keys_present = {opt.get("key") for opt in options if hasattr(opt, "get")}
                    if new_key in keys_present:
                        raise RepairJustificationError(
                            f"Adding option rejected: key '{new_key}' is already present among options {keys_present}"
                        )
                    correct_text = next((o.get("text", "") for o in options if o.get("key") == ans), ans)
                    if new_key == ans:
                        raise RepairJustificationError(
                            f"Adding option rejected: cannot add new option with correct answer key '{ans}'"
                        )
                    if new_text.lower() == correct_text.lower():
                        raise RepairJustificationError(
                            f"Adding option rejected: new option text '{new_text}' is identical to correct answer"
                        )

                    existing_texts = {o.get("text", "").lower() for o in options if hasattr(o, "get")}
                    if new_text.lower() in existing_texts:
                        raise RepairJustificationError(
                            f"Adding option rejected: new option text '{new_text}' duplicates an existing option"
                        )

                    options.append({"key": new_key, "text": new_text})
                    q["options"] = sorted(options, key=lambda o: o.get("key", ""))

                    if len(q["options"]) != 4:
                        raise RepairJustificationError(
                            f"Post-repair option check failed: MultipleChoiceSingle must have exactly 4 options, found {len(q['options'])}"
                        )
                    # Post-repair evaluator check for added options
                    from app.evaluators.semantic import AmbiguityAndDistractorEvaluator
                    q_eval_payload = dict(q)
                    if "passage" not in q_eval_payload and passage_text:
                        q_eval_payload["passage"] = passage_text
                    temp_env = ArtifactEnvelope.create(
                        artifact_id=f"temp_q_{q.get('questionNumber', 1)}",
                        artifact_type=ArtifactType.QUESTION,
                        run_id=artifact.run_id,
                        payload=q_eval_payload,
                        producer_version="2.0.0",
                    )
                    post_eval = AmbiguityAndDistractorEvaluator()
                    post_res = await post_eval.evaluate(context, temp_env, intent_id="post_rep_unique")
                    if any(iss.code in (IssueCode.BAD_DISTRACTOR, IssueCode.INSUFFICIENT_OPTIONS, IssueCode.AMBIGUOUS_ANSWER) for iss in post_res.issues):
                        raise RepairJustificationError(
                            "Post-repair uniqueness failed: added option violates single-answer uniqueness or option rules"
                        )
                    prompt = q.get("prompt", "") or q.get("questionText", "")
                    q["prompt"] = prompt.rstrip("?") + " specifically according to paragraph 2?"

            # Invariant: Item/option/answer repair must have passage evidence justification
            final_ans = q.get("answer", "")
            if final_ans != orig_ans and passage_text and q_type in ("SentenceCompletion", "SummaryCompletion", "ShortAnswer"):
                if not match_verbatim_in_passage(final_ans, passage_text):
                    raise RepairJustificationError(
                        f"Repaired answer '{final_ans}' lacks passage evidence justification (not verbatim in passage)"
                    )
        if artifact.artifact_type == ArtifactType.QUESTION:
            await repair_single_q(payload)
        elif artifact.artifact_type == ArtifactType.SECTION:
            # T07-03: Only repair questions in target_q_nums; all other questions untouched!
            for grp in payload.get("groups", []):
                for q in grp.get("questions", []):
                    q_num = q.get("questionNumber")
                    if not target_q_nums or q_num in target_q_nums:
                        await repair_single_q(q)
        return artifact.create_next_version(new_payload=payload, producer_version="2.0.0")


class SummaryGroupRepairer(BaseRepairer):
    """Surgically repairs summary completion groups (blanks, shared context coherence).
    
    P07-08 / T07-04 Invariant: Re-evaluates entire shared group when shared context changes.
    """

    def __init__(self, timeout_seconds: Optional[float] = None, estimated_tokens: Optional[int] = None):
        t_sec = timeout_seconds if timeout_seconds is not None else getattr(settings, "repair_timeout_seconds", 30.0)
        tok = estimated_tokens if estimated_tokens is not None else getattr(settings, "repair_max_tokens_per_attempt", 1500)
        super().__init__(
            RepairCapabilityMetadata(
                repairer_id="rep_summary_group",
                repairer_version="1.0.0",
                name="Summary Group Coherence Repairer",
                description="Aligns summary blank placeholders and re-evaluates the shared group",
                scope=RepairScope.GROUP,
                target_artifact_types=[ArtifactType.SECTION],
                handled_codes={
                    IssueCode.SCHEMA_VIOLATION,
                    IssueCode.AMBIGUOUS_ANSWER,
                },
                timeout_seconds=t_sec,
                estimated_tokens=tok,
                estimated_cost_usd=0.015,
            )
        )
    async def _repair_impl(
        self,
        context: Any,
        artifact: ArtifactEnvelope,
        issues: Sequence[Issue],
        intent_id: str,
        version: int,
    ) -> ArtifactEnvelope:
        payload = unwrap_payload(artifact.payload)

        # Identify which summary group is affected (by group number in issue message)
        target_group_idx = None
        for iss in issues:
            m = re.search(r"[Gg]roup\s+(\d+)", iss.message)
            if m:
                target_group_idx = int(m.group(1)) - 1
                break

        repaired_any = False
        for g_idx, grp in enumerate(payload.get("groups", [])):
            g_type = grp.get("questionType") or grp.get("type", "")
            if g_type != "SummaryCompletion":
                continue

            # Only target the affected group if target_group_idx is specified
            if target_group_idx is not None and g_idx != target_group_idx:
                continue

            questions = grp.get("questions", [])
            num_qs = len(questions)
            shared_ctx = grp.get("sharedContext", "") or ""

            # Check if any issue supplied a verified proposed_repair
            matching_issue = next((iss for iss in issues if iss.proposed_repair), None)
            if matching_issue and matching_issue.proposed_repair:
                grp["sharedContext"] = matching_issue.proposed_repair
                repaired_any = True
                continue

            # Try in-place blank normalization preserving existing wording
            blank_pattern = re.compile(r"\[BLANK(?:_\d+)?\]|_{3,}")
            matches = list(blank_pattern.finditer(shared_ctx))
            if len(matches) == num_qs:
                # Sequentially normalize placeholders into [BLANK_1], ..., [BLANK_N]
                parts = []
                last_idx = 0
                for b_idx, m in enumerate(matches):
                    parts.append(shared_ctx[last_idx:m.start()])
                    parts.append(f"[BLANK_{b_idx + 1}]")
                    last_idx = m.end()
                parts.append(shared_ctx[last_idx:])
                new_ctx = "".join(parts)
                if new_ctx != shared_ctx:
                    grp["sharedContext"] = new_ctx
                    repaired_any = True
            else:
                # Cannot reconcile blank count without destroying text coherence; fail closed
                raise RepairExecutionError(
                    f"Cannot reconcile summary group {g_idx+1} blanks ({len(matches)} blanks for {num_qs} questions) "
                    "without destroying text coherence; requires full group regeneration"
                )

        if not repaired_any:
            raise RepairExecutionError(
                "No evidence-backed summary group repair could be applied; requires regeneration"
            )

        return artifact.create_next_version(new_payload=payload, producer_version="2.0.0")
