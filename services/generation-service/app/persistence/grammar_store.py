"""Grammar Research Persistence, Replay, and Surface Protection (RG06-S05).

Invariants:
- Research grammar runs are durable and access controlled by tenant_id.
- Replayed runs link to original run without mutating accepted state.
- C5 ProductIntegrationContract: Research items CANNOT publish to production exams.
- SEC-01: Student-visible projections strictly strip private answer evidence.
"""

from __future__ import annotations

import copy
from typing import Any, Dict, List, Optional
from pydantic import Field

from app.contracts.base import CanonicalBaseModel
from app.contracts.research import (
    GenerationResult,
    GrammarRulePack,
    GrammarTask,
    ReferenceAnswerEvidence,
    StandaloneGrammarRequest,
)


class ResearchPublicationForbiddenError(PermissionError):
    """Raised when an attempt is made to publish a research item to production."""

    pass


class GrammarResearchRecord(CanonicalBaseModel):
    """Durable record of a grammar research generation run."""

    run_id: str
    dataset_item_id: str
    configuration_id: str
    task: GrammarTask
    rule_pack: GrammarRulePack
    generation_result: GenerationResult
    private_evidence: List[ReferenceAnswerEvidence] = Field(default_factory=list)
    tenant_id: str
    is_durable: bool = True
    is_published: bool = False
    replayed_from_run_id: Optional[str] = None


class GrammarResearchStore:
    """In-memory durable store and access controller for grammar research artifacts."""

    def __init__(self):
        # Maps run_id -> GrammarResearchRecord
        self._records: Dict[str, GrammarResearchRecord] = {}

    def save_record(
        self,
        request: StandaloneGrammarRequest,
        generation_result: GenerationResult,
        private_evidence: List[ReferenceAnswerEvidence],
        tenant_id: str,
    ) -> GrammarResearchRecord:
        """Stores a research generation record with full provenance and durability."""
        record = GrammarResearchRecord(
            run_id=request.run_id,
            dataset_item_id=request.dataset_item_id,
            configuration_id=request.configuration_id,
            task=request.task,
            rule_pack=request.rule_pack,
            generation_result=generation_result,
            private_evidence=private_evidence,
            tenant_id=tenant_id,
            is_durable=True,
            is_published=False,
            replayed_from_run_id=None,
        )
        self._records[request.run_id] = record
        return record

    def get_record(self, run_id: str, tenant_id: str) -> Optional[GrammarResearchRecord]:
        """Retrieves a research record, enforcing strict tenant isolation."""
        record = self._records.get(run_id)
        if not record or record.tenant_id != tenant_id:
            return None
        return record

    def replay_run(
        self,
        original_run_id: str,
        new_run_id: str,
        tenant_id: str,
    ) -> GrammarResearchRecord:
        """Creates a replayed research run linked to the original lineage."""
        original = self.get_record(original_run_id, tenant_id=tenant_id)
        if not original:
            raise KeyError(f"Run {original_run_id} not found or unauthorized for tenant {tenant_id}")

        new_gen_result = original.generation_result.model_copy(update={"run_id": new_run_id})

        replayed_record = GrammarResearchRecord(
            run_id=new_run_id,
            dataset_item_id=original.dataset_item_id,
            configuration_id=original.configuration_id,
            task=original.task,
            rule_pack=original.rule_pack,
            generation_result=new_gen_result,
            private_evidence=original.private_evidence,
            tenant_id=tenant_id,
            is_durable=True,
            is_published=False,
            replayed_from_run_id=original_run_id,
        )
        self._records[new_run_id] = replayed_record
        return replayed_record

    def publish_to_production_exam(self, run_id: str, tenant_id: str) -> None:
        """Guards against unauthorized publication of research exercises to production.

        Enforces C5 ProductIntegrationContract and SEC-02 invariants: research mode items
        can NEVER be published directly or transition to PublishedSnapshot.
        """
        record = self.get_record(run_id, tenant_id=tenant_id)
        if not record:
            raise KeyError(f"Run {run_id} not found or unauthorized for tenant {tenant_id}")

        # Inviolable protection: research items cannot publish to production
        raise ResearchPublicationForbiddenError(
            f"RESEARCH_PUBLICATION_FORBIDDEN: Run {run_id} is in research mode and cannot be published to production exams."
        )

    def project_student_view(self, run_id: str, tenant_id: str) -> Dict[str, Any]:
        """Projects an allowlisted student-visible view without private answers or rationale."""
        record = self.get_record(run_id, tenant_id=tenant_id)
        if not record:
            raise KeyError(f"Run {run_id} not found or unauthorized for tenant {tenant_id}")

        gen_content = record.generation_result.generated_content
        if not gen_content:
            return {"run_id": run_id, "questions": []}

        student_questions = []
        for q in gen_content.questions:
            student_questions.append({
                "question_id": q.question_id,
                "question_type": q.question_type.value if hasattr(q.question_type, "value") else str(q.question_type),
                "text": q.text,
                "options": list(q.options),
                "instructions": q.instructions,
            })

        return {
            "run_id": run_id,
            "context_text": gen_content.context_text,
            "questions": student_questions,
        }
