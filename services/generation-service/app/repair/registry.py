"""RepairRegistry for Langfens Loop Engine V2."""

from __future__ import annotations

from typing import Dict, List, Optional, Sequence, Set

from app.contracts.artifact import ArtifactType
from app.contracts.issue import Issue, IssueCode
from app.loop.policy import LoopPolicy
from app.repair.base import BaseRepairer, RepairCapabilityMetadata, RepairScope


class RepairRegistry:
    """Registry managing available surgical repairers and allowable issue codes."""

    def __init__(self, policy: Optional[LoopPolicy] = None):
        self._repairers: Dict[str, BaseRepairer] = {}
        self._policy = policy or LoopPolicy()

    @property
    def policy(self) -> LoopPolicy:
        return self._policy

    def register(self, repairer: BaseRepairer) -> None:
        """Registers a repair capability."""
        self._repairers[repairer.repairer_id] = repairer

    def unregister(self, repairer_id: str) -> None:
        self._repairers.pop(repairer_id, None)

    def get(self, repairer_id: str) -> Optional[BaseRepairer]:
        return self._repairers.get(repairer_id)

    def list_repairers(self) -> List[BaseRepairer]:
        return list(self._repairers.values())

    def is_repairable(self, code: IssueCode) -> bool:
        """Checks if an issue code is eligible for repair under the active policy allowlist."""
        # Codes explicitly marked for regeneration or escalation are NEVER repairable
        if code in self._policy.regenerate_codes or code in self._policy.escalate_codes:
            return False
        return code in self._policy.allow_repair_codes

    def find_repairers_for_issue(
        self,
        issue: Issue,
        target_artifact_type: ArtifactType,
        scope: Optional[RepairScope] = None,
    ) -> List[BaseRepairer]:
        """Finds all registered repairers capable of addressing the given issue."""
        if not self.is_repairable(issue.code):
            return []

        matched: List[BaseRepairer] = []
        for rep in self._repairers.values():
            if target_artifact_type in rep.metadata.target_artifact_types:
                if issue.code in rep.metadata.handled_codes:
                    if scope is None or rep.scope == scope:
                        matched.append(rep)

        return matched

    def export_manifest(self) -> dict:
        """Exports declarative manifest of repair capabilities for Phase 07 audit artifacts."""
        return {
            "repairers": [
                {
                    "repairerId": rep.repairer_id,
                    "repairerVersion": rep.repairer_version,
                    "name": rep.metadata.name,
                    "description": rep.metadata.description,
                    "scope": rep.scope.value,
                    "targetArtifactTypes": [t.value for t in rep.metadata.target_artifact_types],
                    "handledCodes": [c.value for c in rep.metadata.handled_codes],
                    "timeoutSeconds": rep.metadata.timeout_seconds,
                    "estimatedTokens": rep.metadata.estimated_tokens,
                    "estimatedCostUsd": rep.metadata.estimated_cost_usd,
                }
                for rep in sorted(self._repairers.values(), key=lambda r: (r.scope.value, r.repairer_id))
            ],
            "totalCount": len(self._repairers),
            "allowRepairCodes": [c.value for c in sorted(self._policy.allow_repair_codes, key=lambda c: c.value)],
        }
