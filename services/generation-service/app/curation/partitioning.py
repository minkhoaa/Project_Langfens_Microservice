"""Phase-14 Connected Component Splitter and Leak-Free Partitioning.

Builds an undirected graph connecting source families by:
  - ``pmcid`` (e.g. PMC123456)
  - ``openalex_id`` (e.g. W123456789)
  - ``doi`` (e.g. 10.1234/example)
  - ``topic_id`` (e.g. topic_volcano_01)
  - Text near-duplicates (Jaccard similarity > 0.8 on 3-gram word shingle sets)

Partitions the connected groups into:
  - ``train`` (70%)
  - ``val``   (15%)
  - ``test``  (15%)

Guarantees ZERO data leakage: all related source variants, questions, passages,
and human edits stay strictly within the same partition split.
Repeat execution on identical input yields bit-for-bit identical hashes.
"""
from __future__ import annotations

import hashlib
import json
import re
from collections import defaultdict
from dataclasses import dataclass, field
from typing import Any, Iterable, Sequence


_WORD_TOKEN_RE = re.compile(r"\b[a-zA-Z0-9_-]+\b")


def _extract_shingles(text: str, k: int = 3) -> set[tuple[str, ...]]:
    """Extract word k-shingles from text for near-duplicate Jaccard similarity."""
    if not text:
        return set()
    tokens = [t.lower() for t in _WORD_TOKEN_RE.findall(text)]
    if len(tokens) < k:
        return {tuple(tokens)} if tokens else set()
    return {tuple(tokens[i : i + k]) for i in range(len(tokens) - k + 1)}


def jaccard_similarity(set_a: set[Any], set_b: set[Any]) -> float:
    """Compute Jaccard similarity between two sets."""
    if not set_a and not set_b:
        return 1.0
    if not set_a or not set_b:
        return 0.0
    intersection = len(set_a.intersection(set_b))
    union = len(set_a.union(set_b))
    return intersection / union if union > 0 else 0.0


class DisjointSet:
    """Union-Find disjoint-set data structure with path compression."""

    def __init__(self) -> None:
        self.parent: dict[str, str] = {}
        self.rank: dict[str, int] = {}

    def find(self, item: str) -> str:
        if item not in self.parent:
            self.parent[item] = item
            self.rank[item] = 0
            return item
        if self.parent[item] != item:
            self.parent[item] = self.find(self.parent[item])
        return self.parent[item]

    def union(self, a: str, b: str) -> None:
        root_a = self.find(a)
        root_b = self.find(b)
        if root_a == root_b:
            return
        if self.rank[root_a] < self.rank[root_b]:
            self.parent[root_a] = root_b
        elif self.rank[root_a] > self.rank[root_b]:
            self.parent[root_b] = root_a
        else:
            self.parent[root_b] = root_a
            self.rank[root_a] += 1


@dataclass(frozen=True)
class PartitionResult:
    """Result of leak-free connected component partitioning."""

    train: list[dict[str, Any]]
    val: list[dict[str, Any]]
    test: list[dict[str, Any]]
    component_count: int
    train_count: int
    val_count: int
    test_count: int
    leakage_violations: int
    split_hashes: dict[str, str]

    def to_dict(self) -> dict[str, Any]:
        return {
            "component_count": self.component_count,
            "train_count": self.train_count,
            "val_count": self.val_count,
            "test_count": self.test_count,
            "leakage_violations": self.leakage_violations,
            "split_hashes": self.split_hashes,
            "train": self.train,
            "val": self.val,
            "test": self.test,
        }


class ConnectedComponentSplitter:
    """Partitions records into train/val/test splits without source-family leakage."""

    def __init__(
        self,
        *,
        jaccard_threshold: float = 0.8,
        train_ratio: float = 0.70,
        val_ratio: float = 0.15,
        test_ratio: float = 0.15,
        salt: str = "langfens_partition_seed_v1",
    ) -> None:
        self.jaccard_threshold = jaccard_threshold
        self.train_ratio = train_ratio
        self.val_ratio = val_ratio
        self.test_ratio = test_ratio
        self.salt = salt

    def partition(self, items: Sequence[dict[str, Any]]) -> PartitionResult:
        """Partition items into train, val, test with 0 leakage across components."""
        if not items:
            return PartitionResult(
                train=[],
                val=[],
                test=[],
                component_count=0,
                train_count=0,
                val_count=0,
                test_count=0,
                leakage_violations=0,
                split_hashes={"train": "", "val": "", "test": ""},
            )

        # Step 1: Assign stable internal IDs and index attributes
        indexed_items: dict[str, dict[str, Any]] = {}
        shingles_by_id: dict[str, set[tuple[str, ...]]] = {}
        dsu = DisjointSet()

        # Attribute lookup tables
        pmcid_to_ids: dict[str, list[str]] = defaultdict(list)
        openalex_to_ids: dict[str, list[str]] = defaultdict(list)
        doi_to_ids: dict[str, list[str]] = defaultdict(list)
        topic_to_ids: dict[str, list[str]] = defaultdict(list)

        for i, item in enumerate(items):
            item_id = str(item.get("id") or item.get("feedback_id") or item.get("item_id") or f"item_{i:06d}")
            indexed_items[item_id] = item
            dsu.find(item_id)

            # Collect source metadata
            pmcid = item.get("pmcid") or item.get("source_pmcid")
            if pmcid:
                pmcid_to_ids[str(pmcid).strip().upper()].append(item_id)

            openalex = item.get("openalex_id") or item.get("source_openalex_id")
            if openalex:
                openalex_to_ids[str(openalex).strip().upper()].append(item_id)

            doi = item.get("doi") or item.get("source_doi")
            if doi:
                doi_to_ids[str(doi).strip().lower()].append(item_id)

            topic = item.get("topic_id") or item.get("topic")
            if topic:
                topic_to_ids[str(topic).strip().lower()].append(item_id)

            # Shingles for near-duplicate detection
            text_candidates = [
                str(item.get("passage_text") or ""),
                str(item.get("question_text") or ""),
                str(item.get("comment") or ""),
                str(item.get("payload") or ""),
            ]
            full_text = " ".join(t for t in text_candidates if t)
            if full_text:
                shingles_by_id[item_id] = _extract_shingles(full_text)

        # Step 2: Union items sharing explicit identifiers
        for group in (pmcid_to_ids, openalex_to_ids, doi_to_ids, topic_to_ids):
            for ids in group.values():
                if len(ids) > 1:
                    first = ids[0]
                    for other in ids[1:]:
                        dsu.union(first, other)

        # Step 3: Union items with near-duplicate text (> jaccard threshold)
        all_ids = sorted(indexed_items.keys())
        for i in range(len(all_ids)):
            id_a = all_ids[i]
            shingles_a = shingles_by_id.get(id_a)
            if not shingles_a:
                continue
            for j in range(i + 1, len(all_ids)):
                id_b = all_ids[j]
                # If already connected, skip comparison
                if dsu.find(id_a) == dsu.find(id_b):
                    continue
                shingles_b = shingles_by_id.get(id_b)
                if not shingles_b:
                    continue
                sim = jaccard_similarity(shingles_a, shingles_b)
                if sim >= self.jaccard_threshold:
                    dsu.union(id_a, id_b)

        # Step 4: Group items into Connected Components
        components: dict[str, list[str]] = defaultdict(list)
        for item_id in all_ids:
            root = dsu.find(item_id)
            components[root].append(item_id)

        # Sort members within each component deterministically
        for root in components:
            components[root].sort()

        # Step 5: Deterministically assign components to train / val / test
        # Sort components by representative (first item id in sorted list)
        sorted_component_roots = sorted(components.keys(), key=lambda r: components[r][0])

        train_items: list[dict[str, Any]] = []
        val_items: list[dict[str, Any]] = []
        test_items: list[dict[str, Any]] = []

        assigned_split_by_id: dict[str, str] = {}

        for root in sorted_component_roots:
            member_ids = components[root]
            # Use deterministic hash of (salt + representative) for uniform bucket routing
            rep_id = member_ids[0]
            hash_input = f"{self.salt}:{rep_id}".encode("utf-8")
            hash_val = int(hashlib.sha256(hash_input).hexdigest()[:8], 16) / 0xFFFFFFFF

            if hash_val < self.train_ratio:
                split_name = "train"
                for mid in member_ids:
                    train_items.append(indexed_items[mid])
                    assigned_split_by_id[mid] = split_name
            elif hash_val < (self.train_ratio + self.val_ratio):
                split_name = "val"
                for mid in member_ids:
                    val_items.append(indexed_items[mid])
                    assigned_split_by_id[mid] = split_name
            else:
                split_name = "test"
                for mid in member_ids:
                    test_items.append(indexed_items[mid])
                    assigned_split_by_id[mid] = split_name

        # Step 6: Verify zero leakage invariant
        leakage_violations = 0
        for root, member_ids in components.items():
            splits = {assigned_split_by_id[mid] for mid in member_ids}
            if len(splits) > 1:
                leakage_violations += 1

        # Step 7: Deterministic SHA-256 for each split
        split_hashes = {
            "train": self._hash_records(train_items),
            "val": self._hash_records(val_items),
            "test": self._hash_records(test_items),
        }

        return PartitionResult(
            train=train_items,
            val=val_items,
            test=test_items,
            component_count=len(components),
            train_count=len(train_items),
            val_count=len(val_items),
            test_count=len(test_items),
            leakage_violations=leakage_violations,
            split_hashes=split_hashes,
        )

    def _hash_records(self, records: list[dict[str, Any]]) -> str:
        if not records:
            return hashlib.sha256(b"").hexdigest()
        canonical = json.dumps(records, sort_keys=True, separators=(",", ":"), default=str)
        return hashlib.sha256(canonical.encode("utf-8")).hexdigest()
