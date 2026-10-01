"""Dependency and Lineage Freshness Validator for Loop Engine V2."""

from __future__ import annotations

from typing import Dict, List, Sequence, Set, Tuple

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef


class DependencyValidator:
    """Validates artifact dependencies, lineage freshness, and computes invalidation closures."""

    @staticmethod
    def validate_dependency_freshness(
        artifact: ArtifactEnvelope,
        accepted_dependencies: Dict[str, ArtifactRef],
    ) -> Tuple[bool, List[str]]:
        """Verifies that all parent references in artifact match the current accepted upstream references.
        
        Returns (is_fresh, stale_details).
        """
        stale_reasons: List[str] = []
        for ref in artifact.parent_refs:
            if ref.artifact_id not in accepted_dependencies:
                stale_reasons.append(f"Missing accepted dependency for artifact '{ref.artifact_id}'")
            else:
                accepted = accepted_dependencies[ref.artifact_id]
                if accepted.version != ref.version:
                    stale_reasons.append(
                        f"Stale dependency version for artifact '{ref.artifact_id}': "
                        f"ref has v{ref.version}, but current accepted is v{accepted.version}"
                    )
                elif accepted.content_hash.lower() != ref.content_hash.lower():
                    stale_reasons.append(
                        f"Stale dependency hash for artifact '{ref.artifact_id}': "
                        f"ref hash '{ref.content_hash[:8]}...' != accepted hash '{accepted.content_hash[:8]}...'"
                    )

        is_fresh = len(stale_reasons) == 0
        return is_fresh, stale_reasons

    @staticmethod
    def compute_invalidation_closure(
        modified_artifact_id: str,
        artifacts_pool: Sequence[ArtifactEnvelope],
    ) -> Set[str]:
        """Computes the full transitive closure of descendant artifact IDs that must be invalidated
        because they depend directly or indirectly on modified_artifact_id.
        """
        invalidated: Set[str] = {modified_artifact_id}
        changed = True

        while changed:
            changed = False
            for art in artifacts_pool:
                if art.artifact_id not in invalidated:
                    # Check if any parent reference is in invalidated set
                    if any(ref.artifact_id in invalidated for ref in art.parent_refs):
                        invalidated.add(art.artifact_id)
                        changed = True

        return invalidated

    @staticmethod
    def check_descendants_freshness(
        parent_ref: ArtifactRef,
        descendant_artifacts: Sequence[ArtifactEnvelope],
    ) -> Tuple[bool, List[str]]:
        """Checks whether all descendants of a specific parent artifact reference are using the exact
        latest version and content hash of that parent.
        """
        violations: List[str] = []
        for desc in descendant_artifacts:
            for p in desc.parent_refs:
                if p.artifact_id == parent_ref.artifact_id:
                    if p.version != parent_ref.version or p.content_hash.lower() != parent_ref.content_hash.lower():
                        violations.append(
                            f"Descendant artifact '{desc.artifact_id}' (v{desc.version}) "
                            f"references stale parent '{p.artifact_id}' v{p.version} ({p.content_hash[:8]}), "
                            f"expected latest v{parent_ref.version} ({parent_ref.content_hash[:8]})"
                        )
        return len(violations) == 0, violations
