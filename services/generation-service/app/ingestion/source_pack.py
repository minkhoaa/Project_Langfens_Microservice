"""SourcePack capability for Langfens Loop Engine V2.

Guarantees:
- Full content SHA-256 hash and normalized-text SHA-256 hash.
- Normalizer version ("v2.0.0") tracking.
- Provenance and license attribution recording.
- Source revision tracking: if content changes (even at same URL), revision is bumped
  and descendant invalidation is signaled.
- Converts cleanly to Canonical ArtifactEnvelope for Phase 02 durable PostgreSQL persistence.
"""

from __future__ import annotations

from datetime import datetime, timezone
import hashlib
from typing import Any, List, Optional, Tuple

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.source import (
    SourceDocument,
    SourceItem,
    SourceMetadata,
    SourcePack,
)
from app.ingestion.cleaner import NORMALIZER_VERSION


def compute_sha256(data: str | bytes) -> str:
    """Computes standard 64-char lowercase hex SHA-256."""
    b = data.encode("utf-8") if isinstance(data, str) else data
    return hashlib.sha256(b).hexdigest()


class SourcePackBuilder:
    """Constructs canonical SourcePack instances with full provenance and hash integrity."""

    @staticmethod
    def build_source_item(
        source_id: str,
        raw_content: str,
        normalized_text: str,
        title: str,
        source_url: str,
        authors: Optional[List[str]] = None,
        journal: Optional[str] = None,
        pub_date: Optional[str] = None,
        doi: Optional[str] = None,
        pmcid: Optional[str] = None,
        pmid: Optional[str] = None,
        license_type: str = "Open Access",
        license_cleared: bool = True,
        headings: Optional[List[str]] = None,
        paragraphs: Optional[List[str]] = None,
    ) -> SourceItem:
        author_list = authors or []
        body_paragraphs = paragraphs or [p.strip() for p in normalized_text.split("\n\n") if p.strip()]
        body_headings = headings or []
        word_count = len(normalized_text.split())

        metadata = SourceMetadata(
            pmid=pmid,
            pmcid=pmcid,
            doi=doi,
            title=title,
            authors=author_list,
            journal=journal,
            pubDate=pub_date,
            sourceUrl=source_url,
            licenseType=license_type,
            licenseCleared=license_cleared,
        )

        document = SourceDocument(
            text=normalized_text,
            wordCount=word_count,
            paragraphs=body_paragraphs,
            headings=body_headings,
            extractedAt=datetime.now(timezone.utc),
        )

        return SourceItem(
            sourceId=source_id,
            metadata=metadata,
            document=document,
        )

    @staticmethod
    def build_source_pack(
        pack_id: str,
        run_id: str,
        sources: List[SourceItem],
        section_id: Optional[int] = None,
        revision: int = 1,
        suitability_score: float = 1.0,
    ) -> SourcePack:
        combined_words = sum(s.document.word_count for s in sources)
        all_cleared = all(s.metadata.license_cleared for s in sources)

        return SourcePack(
            packId=pack_id,
            runId=run_id,
            sectionId=section_id,
            revision=revision,
            sources=sources,
            combinedWordCount=combined_words,
            suitabilityScore=suitability_score,
            licenseCleared=all_cleared,
            createdAt=datetime.now(timezone.utc),
        )

    @staticmethod
    def update_source_content(
        current_pack: SourcePack,
        updated_source_id: str,
        new_raw_content: str,
        new_normalized_text: str,
        new_title: Optional[str] = None,
    ) -> Tuple[SourcePack, bool]:
        """Updates a source within a pack.

        If the normalized content hash differs from the existing source:
        - Bumps revision (current_pack.revision + 1)
        - Returns (new_source_pack, True) indicating downstream invalidation required.
        If content is identical:
        - Returns (current_pack, False) with no revision change.
        """
        updated_sources: List[SourceItem] = []
        content_changed = False

        for item in current_pack.sources:
            if item.source_id == updated_source_id:
                old_hash = compute_sha256(item.document.text)
                new_hash = compute_sha256(new_normalized_text)

                if old_hash != new_hash:
                    content_changed = True
                    new_item = SourcePackBuilder.build_source_item(
                        source_id=item.source_id,
                        raw_content=new_raw_content,
                        normalized_text=new_normalized_text,
                        title=new_title or item.metadata.title,
                        source_url=item.metadata.source_url,
                        authors=item.metadata.authors,
                        journal=item.metadata.journal,
                        pub_date=item.metadata.pub_date,
                        doi=item.metadata.doi,
                        pmcid=item.metadata.pmcid,
                        pmid=item.metadata.pmid,
                        license_type=item.metadata.license_type,
                        license_cleared=item.metadata.license_cleared,
                    )
                    updated_sources.append(new_item)
                else:
                    updated_sources.append(item)
            else:
                updated_sources.append(item)

        if not content_changed:
            return current_pack, False

        new_revision = current_pack.revision + 1
        new_pack = SourcePackBuilder.build_source_pack(
            pack_id=current_pack.pack_id,
            run_id=current_pack.run_id,
            sources=updated_sources,
            section_id=current_pack.section_id,
            revision=new_revision,
            suitability_score=current_pack.suitability_score,
        )

        return new_pack, True

    @staticmethod
    def to_artifact_envelope(
        pack: SourcePack,
        parent_refs: Optional[List[ArtifactRef]] = None,
    ) -> ArtifactEnvelope:
        """Packages a SourcePack into an immutable ArtifactEnvelope for Phase 02 persistence."""
        return ArtifactEnvelope.create(
            artifact_id=pack.pack_id,
            artifact_type=ArtifactType.SOURCE_PACK,
            run_id=pack.run_id,
            section_id=pack.section_id,
            version=pack.revision,
            producer_version=NORMALIZER_VERSION,
            payload=pack.model_dump(mode="json", by_alias=True),
            parent_refs=parent_refs or [],
            created_at=pack.created_at,
        )
