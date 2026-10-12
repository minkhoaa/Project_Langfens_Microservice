"""Phase 15 V2 paper-loop stale-reference regression (agent B / case 13).

Scope: `PaperGeneratorAdapter` and `PaperLoop.run` in `app/loop/paper.py`.

FINDING (campaign `camp_G15_dde0f9bd38d4`, case 13, seed 101, run
`bench_d4b5eead136149a038c9e1ab759564d3`):

    failureReason = "Paper loop rejected paper: INVALID_OUTPUT: capability returned
                      wrong target/version/hash/parents"

The paper artifact was BUILT from stale references. The accepted heads were

    art_section_1 v1 | art_section_2 v3 | art_section_3 v1
    art_passage_s1 v1 | art_passage_s2 v2 | art_passage_s3 v1

but the paper's own `parentRefs` named

    art_section_1 v1 | art_section_2 v1  <-- BACKWARDS | art_section_3 v1
    art_passage_s1 v1 | art_passage_s2 v2 | art_passage_s3 v1

so the paper pointed BACKWARD along the chain. `_deps_resyncable_only`
(`app/loop/runtime.py:566`, added in RC-7) refuses any parent ref whose version is
LOWER than the declared one, because "a dependency never moves backwards in an
append-only chain". That `INVALID_OUTPUT` is a TRUTHFUL rejection. These tests do
NOT weaken it -- `test_..._regressed_parent_ref_is_still_refused` pins that.

THE DEFECT, reproduced empirically against this fixture
------------------------------------------------------
`PaperGeneratorAdapter.generate` resolved the live heads ONLY when
`version > 1`:

    sections_to_use = self._resolve_current_sections(context) if version > 1 else self.section_envelopes

so the FIRST draft -- the one this campaign failed on -- was assembled from the
snapshot captured before the sub-loops ran. With a section head at v3 and a
snapshot at v1:

    version=1 -> {'art_section_s2': 1}   # stale: reproduces case 13 exactly
    version=2 -> {'art_section_s2': 3}   # refresh ran

A second, independent mechanism: `_resolve_current_sections` keys its head lookup
on `sec.artifact_id` and silently keeps the snapshot when that key misses. The
campaign notes that two section id conventions coexist in this run
(`art_section_N` and `art_section_sN`). When the snapshot is re-keyed to the
convention the chain does NOT use, the lookup misses and even `version=2` still
emits the stale v1 ref. Both are producer-side; both are fixed by resolving every
parent to the accepted head at assembly time, keyed on the canonical section id.

INVARIANTS PRESERVED
-------------------
* Verbatim grounding, anti-leakage, answer uniqueness, group distinctness, schema,
  frozen evaluator thresholds, source isolation, frozen seeds, no synthesis: all
  untouched. No evaluator, validator, or threshold is edited.
* No cap is raised. `max_versions`, `max_generated_versions`,
  `max_repair_attempts_per_version`, `max_total_repairs` are unchanged, and
  `test_..._no_cap_was_raised` pins that.
* CAS/fencing: the refresh is a pure `resume_state` READ. It writes nothing.
* Immutability: the paper is always emitted as a NEW version; no envelope is
  mutated in place.
* Idempotency: re-running the same assembly yields an identical content hash.
* Strict closure: a chain that genuinely regressed, or whose head cannot be
  resolved, still FAILS CLOSED. Recovery is not "accept anything".
"""

from __future__ import annotations

import json
import tempfile
import uuid
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple
from uuid import UUID

import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.issue import IssueScope
from app.contracts.loop import DecisionType, LoopReason
from app.contracts.section import assemble_immutable_section
from app.loop.context import AuthorityGrant, BudgetTracker, LoopContext
from app.loop.paper import PaperGeneratorAdapter, PaperLoop
from app.loop.policy import LoopPolicy
from app.persistence.models import ArtifactResumeInfo, ResumeStateResult

from tests.test_t06_loop_runtime import DurableStore, simulated_run_profile
from tests.test_t11_section_loop import (
    create_mock_passage_envelope,
    create_mock_question_envelopes,
)

RUN_ID = "run_paper_head_refresh"
SECTION_WORD_COUNTS = (800, 820, 850)


# ─────────────────────────────────────────────────────────────────────────────
# Fixture harness
# ─────────────────────────────────────────────────────────────────────────────


def _blueprint_ref() -> ArtifactRef:
    return ArtifactRef(
        artifactId="art_bp_1",
        artifactType=ArtifactType.EXAM_BLUEPRINT,
        version=1,
        contentHash="0" * 64,
    )


def _sections(run_id: str = RUN_ID, blueprint: Optional[ArtifactRef] = None) -> List[ArtifactEnvelope]:
    """The canonical 3-section snapshot every test starts from."""
    blueprint = blueprint or _blueprint_ref()
    return [
        assemble_immutable_section(
            idx, f"Section {idx}",
            create_mock_passage_envelope(idx, wc, run_id=run_id),
            blueprint,
            create_mock_question_envelopes(idx, run_id=run_id),
            run_id=run_id, version=1,
        )
        for idx, wc in zip((1, 2, 3), SECTION_WORD_COUNTS)
    ]


def _resume_info(envelope: ArtifactEnvelope, *, is_stale: bool = False) -> ArtifactResumeInfo:
    dumped = envelope.model_dump(mode="json", by_alias=True)
    return ArtifactResumeInfo(
        artifactId=envelope.artifact_id,
        artifactType=envelope.artifact_type.value,
        acceptedVersion=envelope.version,
        acceptedHash=envelope.content_hash,
        payloadJson=json.dumps(dumped["payload"]),
        parentRefs=list(envelope.parent_refs),
        isStale=is_stale,
        envelopeJson=json.dumps(dumped),
    )


class RecordingStore:
    """A resume_state-only checkpoint client.

    The refresh under test must be a pure READ, so this client deliberately offers
    no commit surface at all: if the fix ever tried to write, it would raise
    `AttributeError` and the test would fail loudly rather than pass by accident.
    """

    def __init__(self, artifacts: List[ArtifactResumeInfo], epoch: int = 1):
        self._artifacts = artifacts
        self.epoch = epoch
        self.resume_calls = 0

    def resume_state(self, run_id: str) -> ResumeStateResult:
        self.resume_calls += 1
        return ResumeStateResult(
            runId=run_id, jobId=uuid.uuid4(), epoch=self.epoch, status="RUNNING",
            engineVersion="2.0.0", schemaVersion="2.0.0", policyVersion="2.0.0",
            artifacts=list(self._artifacts),
        )


def _make_context(
    sections: List[ArtifactEnvelope], blueprint: ArtifactRef, owner: UUID,
    target: str = "art_paper_p1",
) -> LoopContext:
    """Declare the paper's input deps exactly as `PaperLoop.run` does."""
    passage_refs: List[ArtifactRef] = []
    question_refs: List[ArtifactRef] = []
    for sec in sections:
        payload = sec.payload
        passage_refs.append(ArtifactRef.model_validate(payload["passageRef"]))
        question_refs.extend(ArtifactRef.model_validate(qr) for qr in payload["questionRefs"])
    input_deps = [blueprint] + [s.to_ref() for s in sections] + passage_refs + question_refs
    return LoopContext(
        runId=RUN_ID, scope=IssueScope.PAPER,
        targetArtifactId=target, targetArtifactType=ArtifactType.READING_PAPER,
        inputDependencies=tuple(input_deps),
        authority=AuthorityGrant(leaseOwner=owner, epoch=1),
        budgetTracker=BudgetTracker(),
    )


def _full_chain(
    section_heads: Dict[int, ArtifactEnvelope],
    stale_ids: Tuple[str, ...] = (),
) -> List[ArtifactResumeInfo]:
    """Build the accepted-head records for a chain.

    Heads come from the real `assemble_immutable_section`, so every `acceptedHash`
    genuinely matches its own payload and parents. A chain built any other way would
    be internally inconsistent and would fail the store's own validation for reasons
    unrelated to what these tests are pinning.
    """
    return [
        _resume_info(section, is_stale=section.artifact_id in stale_ids)
        for section in section_heads.values()
    ]


def _advance_section_two(
    sections: List[ArtifactEnvelope], blueprint: ArtifactRef, run_id: str = RUN_ID,
) -> Tuple[ArtifactEnvelope, ArtifactEnvelope]:
    """Advance section 2's passage to v2 and the section itself to v3, as the sub-loops do."""
    passage_v1 = ArtifactRef.model_validate(sections[1].payload["passageRef"])
    passage_v2 = ArtifactEnvelope.create(
        artifact_id=passage_v1.artifact_id, artifact_type=ArtifactType.PASSAGE, run_id=run_id,
        payload=dict(create_mock_passage_envelope(2, 830, run_id=run_id).payload),
        producer_version="2.0.0", version=passage_v1.version + 1, section_id=2,
    )
    parents = [passage_v2.to_ref()] + list(sections[1].parent_refs[1:])
    section_v3 = assemble_immutable_section(
        2, "Section 2", passage_v2, blueprint,
        create_mock_question_envelopes(2, run_id=run_id),
        run_id=run_id, version=sections[1].version + 2,
    )
    # Bind the recorded parent refs to the snapshot's own refs so only the passage and
    # section versions differ -- this isolates the regression to the section head.
    section_v3 = section_v3.model_copy(
        update={"parent_refs": tuple(ArtifactRef.model_validate(r.model_dump(by_alias=True)) for r in parents)}
    )
    section_v3 = ArtifactEnvelope.create(
        artifact_id=section_v3.artifact_id, artifact_type=section_v3.artifact_type,
        run_id=run_id, payload=dict(section_v3.payload), producer_version="2.0.0",
        version=section_v3.version, section_id=2,
        parent_refs=section_v3.parent_refs,
    )
    return passage_v2, section_v3


def _section_versions(envelope: ArtifactEnvelope) -> Dict[str, int]:
    return {
        r.artifact_id: r.version
        for r in envelope.parent_refs
        if r.artifact_type == ArtifactType.SECTION
    }


def _passage_versions(envelope: ArtifactEnvelope) -> Dict[str, int]:
    return {
        r.artifact_id: r.version
        for r in envelope.parent_refs
        if r.artifact_type == ArtifactType.PASSAGE
    }


def _tmpdir() -> Path:
    """A throwaway directory for the durable store each fail-closed test needs."""
    return Path(tempfile.mkdtemp(prefix="phase15_paper_head_"))


def _tmp_store(artifacts: List[ArtifactResumeInfo], owner: UUID, tmp_path: Path) -> DurableStore:
    """A durable store pre-seeded with `artifacts` as the accepted heads."""
    policy = LoopPolicy(required_evaluator_ids=("required",))
    store = DurableStore(tmp_path / "paper.db", owner, run_profile=simulated_run_profile(policy))
    state = store._state()
    for info in artifacts:
        if not info.envelopeJson:
            continue
        record = ArtifactEnvelope.model_validate_json(info.envelopeJson).model_dump(
            mode="json", by_alias=True
        )
        state["heads"][info.artifactId] = record
    store._save(state, "seed_heads")
    return store


async def _run_paper_loop(
    monkeypatch, tmp_path: Path, run_id: str, blueprint: ArtifactRef,
    snapshot: List[ArtifactEnvelope], store: RecordingStore,
):
    """Drive the REAL `PaperLoop` so a failure lands on a real runtime terminal.

    The runtime needs `resume_state`/`save_draft_checkpoint`/`commit_checkpoint` to
    drive a loop to a terminal, so the chain is mirrored into a real `DurableStore`.
    The head READ the assembler performs is redirected to the `RecordingStore`, which
    is where each test encodes the exact chain shape under test (stale flags, missing
    envelopes, divergent ids). Both call sites -- `PaperLoop.run`'s declared deps and
    `PaperGeneratorAdapter`'s assembly -- go through the same patched resolver, which
    is what keeps the two sides of the strict-closure check consistent.
    """
    import app.loop.paper as paper_module

    owner = uuid.uuid4()
    durable = _tmp_store(store._artifacts, owner, tmp_path)
    original_resolver = paper_module._resolve_live_paper_sections

    def _read_from_recording_store(rid, sections, _client):
        return original_resolver(rid, sections, store)

    monkeypatch.setattr(paper_module, "_resolve_live_paper_sections", _read_from_recording_store)
    return await PaperLoop(persistence_client=durable).run(
        run_id=run_id, blueprint_ref=blueprint, section_envelopes=list(snapshot),
        title="Fail Closed Paper", paper_id="p_failclosed", owner=owner, epoch=1,
    )


# ─────────────────────────────────────────────────────────────────────────────
# (a) A paper whose sub-loops advanced a section head is bound to the live head.
# ─────────────────────────────────────────────────────────────────────────────


@pytest.mark.asyncio
async def test_paper_generator_binds_live_section_head_after_subloop_advance():
    """The first draft must resolve section 2 to the accepted v3 head.

    Pre-fix `generate` only resolved live heads when `version > 1`, so the v1 draft
    was assembled from the pre-loop snapshot and named section 2 @ v1 -- the exact
    case-13 backward ref the runtime truthfully rejected.
    """
    blueprint = _blueprint_ref()
    snapshot = _sections()
    _, section_v3 = _advance_section_two(snapshot, blueprint)
    chain = _full_chain({1: snapshot[0], 2: section_v3, 3: snapshot[2]})
    store = RecordingStore(chain)

    envelope = await PaperGeneratorAdapter(
        paper_id="p1", title="T", blueprint_ref=blueprint,
        section_envelopes=snapshot, persistence_client=store,
    ).generate(_make_context(snapshot, blueprint, uuid.uuid4()), "intent_gen_1", version=1)

    assert envelope.verify_integrity(), "the emitted paper must verify its own content hash"
    sections = _section_versions(envelope)
    assert sections[section_v3.artifact_id] == 3, (
        f"paper must bind the LIVE section head v3, got {sections} (pre-fix emits v1)"
    )
    assert sections[section_v3.artifact_id] != 1, "a v1 ref would be the case-13 regression"

    # No parent may move backwards relative to what the loop originally declared.
    declared = {r.artifact_id: r.version for r in _make_context(snapshot, blueprint, uuid.uuid4()).input_dependencies}
    for ref in envelope.parent_refs:
        prior = declared.get(ref.artifact_id)
        if prior is not None:
            assert ref.version >= prior, (
                f"parent {ref.artifact_id} moved backwards: v{prior} -> v{ref.version}"
            )


@pytest.mark.asyncio
async def test_paper_generator_binds_live_passage_head_after_subloop_advance():
    """The section's own passage advance must propagate into the paper's passage refs.

    Case 13 recorded `art_passage_s2 v2` as already current in the paper, but that
    only held for the passage the section payload happened to carry. The paper must
    resolve the passage head too, not merely the section head.
    """
    blueprint = _blueprint_ref()
    snapshot = _sections()
    passage_v2, section_v3 = _advance_section_two(snapshot, blueprint)
    chain = _full_chain({1: snapshot[0], 2: section_v3, 3: snapshot[2]})
    store = RecordingStore(chain)

    envelope = await PaperGeneratorAdapter(
        paper_id="p1", title="T", blueprint_ref=blueprint,
        section_envelopes=snapshot, persistence_client=store,
    ).generate(_make_context(snapshot, blueprint, uuid.uuid4()), "intent_gen_1", version=1)

    passages = _passage_versions(envelope)
    assert passages[passage_v2.artifact_id] == passage_v2.version, (
        f"paper must bind the LIVE passage head v{passage_v2.version}, got {passages}"
    )


@pytest.mark.asyncio
async def test_paper_generator_resolves_section_id_convention_divergence():
    """Two section id conventions must not silently strand the lookup on a stale snapshot.

    The campaign observed `art_section_1` and `art_section_s1` coexisting in one run.
    Pre-fix `_resolve_current_sections` keyed its head lookup on the SNAPSHOT's
    `artifact_id`, so when the snapshot used the convention the chain does not, the
    lookup missed and the stale envelope was kept -- even at version 2. The paper must
    resolve by the canonical section slot instead of trusting the snapshot's id.
    """
    blueprint = _blueprint_ref()
    snapshot = _sections()
    _, section_v3 = _advance_section_two(snapshot, blueprint)
    chain = _full_chain({1: snapshot[0], 2: section_v3, 3: snapshot[2]})
    store = RecordingStore(chain)

    # The caller's snapshot carries the OTHER convention than the committed chain.
    divergent = [s.model_copy(update={"artifact_id": f"art_section_{i}"}) for i, s in enumerate(snapshot, 1)]

    envelope = await PaperGeneratorAdapter(
        paper_id="p1", title="T", blueprint_ref=blueprint,
        section_envelopes=divergent, persistence_client=store,
    ).generate(_make_context(divergent, blueprint, uuid.uuid4()), "intent_gen_2", version=2)

    sections = _section_versions(envelope)
    advanced = [v for aid, v in sections.items() if v >= 3]
    assert advanced, (
        f"the advanced section head must be found despite the id-convention divergence; "
        f"got {sections} (pre-fix the lookup misses and keeps the stale v1 ref)"
    )


# ─────────────────────────────────────────────────────────────────────────────
# (b) A STALE / regressed head is still refused. RC-7 must keep rejecting.
# ─────────────────────────────────────────────────────────────────────────────


@pytest.mark.asyncio
async def test_regressed_parent_ref_is_still_refused_by_the_resync_guard(tmp_path):
    """A paper naming a section at v1 while the head is v3 must still be INVALID_OUTPUT.

    This is the case-13 SHAPE and it must remain a rejection. The producer-side fix
    stops the paper from being BUILT that way; it must never make a backward ref
    "resyncable", which would paper over real corruption. This test drives
    `_deps_resyncable_only` directly with a regressed ref and asserts it is refused.
    """
    from app.loop.runtime import BoundedLoopRuntime
    from tests.test_t06_loop_runtime import DurableStore, simulated_run_profile

    blueprint = _blueprint_ref()
    snapshot = _sections()
    owner = uuid.uuid4()
    policy = LoopPolicy(required_evaluator_ids=("required",))

    ctx = _make_context(snapshot, blueprint, owner, target="art_paper_p_regressed")
    profile = simulated_run_profile(policy)
    store = DurableStore(tmp_path / "regressed.db", owner, run_profile=profile)

    rt = BoundedLoopRuntime(
        ctx, policy,
        generator=None, evaluators=[], repairer=None,
        persistence_client=store, accepted_dependencies={},
    )

    # A paper whose section ref is the STALE v1 while the runtime has since advanced.
    regressed = ArtifactEnvelope.create(
        artifact_id="art_paper_p_regressed", artifact_type=ArtifactType.READING_PAPER,
        run_id=RUN_ID, payload={"text": "paper bound to a regressed section head"},
        producer_version="2.0.0", version=1, parent_refs=ctx.input_dependencies,
    )
    rt.context.input_dependencies = tuple(
        ArtifactRef.model_validate(r.model_dump(by_alias=True)) for r in ctx.input_dependencies
        if r.artifact_type != ArtifactType.SECTION
    ) + tuple(
        ArtifactRef.model_validate(r.model_dump(by_alias=True)) for r in ctx.input_dependencies
        if r.artifact_type == ArtifactType.SECTION
    )

    assert rt._deps_resyncable_only(regressed, 1) is True, (
        "sanity: with the declared deps still at v1 the v1 ref is the current declaration"
    )

    # Now the runtime's declared dep has advanced to v3 -- the exact case-13 delta.
    declared_v3 = dict((r.artifact_id, r) for r in rt.context.input_dependencies)
    advanced_section = ArtifactEnvelope.create(
        artifact_id=snapshot[1].artifact_id, artifact_type=ArtifactType.SECTION, run_id=RUN_ID,
        payload={"text": "section 2 advanced"}, producer_version="2.0.0", version=3,
    )
    declared_v3[snapshot[1].artifact_id] = ArtifactRef.model_validate(
        advanced_section.to_ref().model_dump(by_alias=True)
    )
    rt.context.input_dependencies = tuple(declared_v3[r.artifact_id] for r in ctx.input_dependencies)

    assert rt._deps_resyncable_only(regressed, 1) is False, (
        "a parent ref below the declared head is a chain regression and must NOT be "
        "resyncable -- RC-7 must keep rejecting it (case 13 must stay truthful)"
    )


# ─────────────────────────────────────────────────────────────────────────────
# (c) CAS / lease enforcement and idempotency are preserved.
# ─────────────────────────────────────────────────────────────────────────────


@pytest.mark.asyncio
async def test_head_refresh_is_a_pure_read_with_no_write_surface():
    """The refresh must only READ. `RecordingStore` exposes no commit method at all.

    If the fix tried to write anything, this would raise `AttributeError` rather
    than silently pass. CAS/fencing lives on the commit path, which this code never
    touches.
    """
    blueprint = _blueprint_ref()
    snapshot = _sections()
    _, section_v3 = _advance_section_two(snapshot, blueprint)
    chain = _full_chain({1: snapshot[0], 2: section_v3, 3: snapshot[2]})
    store = RecordingStore(chain)

    assert not hasattr(store, "commit_checkpoint")
    assert not hasattr(store, "grant_operation")
    assert not hasattr(store, "save_draft_checkpoint")

    envelope = await PaperGeneratorAdapter(
        paper_id="p1", title="T", blueprint_ref=blueprint,
        section_envelopes=snapshot, persistence_client=store,
    ).generate(_make_context(snapshot, blueprint, uuid.uuid4()), "intent_gen_1", version=1)

    assert envelope.verify_integrity()
    assert store.epoch == 1, "a read must not bump the fenced epoch"


@pytest.mark.asyncio
async def test_repeated_assembly_is_idempotent():
    """Re-running the same assembly must not double-apply or drift.

    Two generations over the same chain must produce byte-identical envelopes. This
    is what stops a repair replay from appending a new version each attempt.
    """
    blueprint = _blueprint_ref()
    snapshot = _sections()
    _, section_v3 = _advance_section_two(snapshot, blueprint)
    chain = _full_chain({1: snapshot[0], 2: section_v3, 3: snapshot[2]})

    first = await PaperGeneratorAdapter(
        paper_id="p1", title="T", blueprint_ref=blueprint, section_envelopes=snapshot,
        persistence_client=RecordingStore(chain),
    ).generate(_make_context(snapshot, blueprint, uuid.uuid4()), "intent_a", version=1)
    second = await PaperGeneratorAdapter(
        paper_id="p1", title="T", blueprint_ref=blueprint, section_envelopes=snapshot,
        persistence_client=RecordingStore(chain),
    ).generate(_make_context(snapshot, blueprint, uuid.uuid4()), "intent_a", version=1)

    assert first.content_hash == second.content_hash, "assembly must be deterministic"
    assert tuple(first.parent_refs) == tuple(second.parent_refs)


@pytest.mark.asyncio
async def test_head_refresh_never_raises_a_cap():
    """No version/call/token budget may be widened by the refresh."""
    default = LoopPolicy()
    assert default.max_versions == 3
    assert default.max_generated_versions == 3
    assert default.max_repair_attempts_per_version == 2
    assert default.max_total_repairs == 5


# ─────────────────────────────────────────────────────────────────────────────
# (d) A genuinely inconsistent chain still FAILS CLOSED.
# ─────────────────────────────────────────────────────────────────────────────


@pytest.mark.asyncio
async def test_stale_marked_head_fails_closed_instead_of_binding_the_snapshot(monkeypatch):
    """A record the persistence layer marks stale is NOT a head. Recovery must fail closed.

    Section 2's only recorded version is flagged `isStale`, so there is no accepted
    head for that slot. The assembly must REFUSE. It must not quietly fall back to the
    caller's v1 snapshot: that fallback is precisely the case-13 defect, re-entered
    through the back door, and it would emit a paper naming a section the store has
    explicitly disowned.

    The refusal is asserted through the real runtime, proving it terminates as
    `INVALID_OUTPUT` rather than merely raising somewhere unobserved.
    """
    blueprint = _blueprint_ref()
    snapshot = _sections()
    _, section_v3 = _advance_section_two(snapshot, blueprint)
    chain = _full_chain(
        {1: snapshot[0], 2: section_v3, 3: snapshot[2]},
        stale_ids=(section_v3.artifact_id,),
    )
    store = RecordingStore(chain)

    result = await _run_paper_loop(
        monkeypatch, _tmpdir(), RUN_ID, blueprint, snapshot, store,
    )

    assert result.decision == DecisionType.FAIL, (
        f"a chain with no accepted head must fail closed, got {result.decision}: "
        f"{result.terminal_reason}"
    )
    assert result.terminal_reason_code == LoopReason.INVALID_OUTPUT, (
        f"expected INVALID_OUTPUT, got {result.terminal_reason_code}: {result.terminal_reason}"
    )
    assert result.accepted_artifact is None, "no paper may be accepted on a stale-only chain"


@pytest.mark.asyncio
async def test_unresolvable_head_fails_closed_instead_of_binding_the_snapshot(monkeypatch):
    """A head the store reports but cannot hand back is UNRESOLVABLE. Fail closed.

    Section 2's head record exists at v3 but carries no envelope, so the paper cannot
    bind it. Falling back to the caller's v1 snapshot would emit exactly the backward
    ref case 13 failed on. The assembly must refuse, and the runtime must terminate
    `INVALID_OUTPUT` with nothing accepted.
    """
    blueprint = _blueprint_ref()
    snapshot = _sections()
    _, section_v3 = _advance_section_two(snapshot, blueprint)
    chain = _full_chain({1: snapshot[0], 2: section_v3, 3: snapshot[2]})
    # The head is reported but carries no envelope, so the assembler cannot bind it.
    # `ArtifactResumeInfo` is frozen, so the record is rebuilt rather than mutated.
    chain = [
        (info.model_copy(update={"envelopeJson": None})
         if info.artifactId == section_v3.artifact_id else info)
        for info in chain
    ]
    store = RecordingStore(chain)

    result = await _run_paper_loop(
        monkeypatch, _tmpdir(), RUN_ID, blueprint, snapshot, store,
    )

    assert result.decision == DecisionType.FAIL, (
        f"an unresolvable head must fail closed, got {result.decision}: {result.terminal_reason}"
    )
    assert result.terminal_reason_code == LoopReason.INVALID_OUTPUT, (
        f"expected INVALID_OUTPUT, got {result.terminal_reason_code}: {result.terminal_reason}"
    )
    assert result.accepted_artifact is None


@pytest.mark.asyncio
async def test_regressed_head_is_not_resynced_from_the_snapshot():
    """A head BEHIND the declared version is a chain regression. Fail closed.

    The caller holds section 2 at v3 while the store's accepted head is still v1. An
    append-only chain never moves backwards, so adopting v1 would rewrite history.
    The assembly must refuse rather than silently downgrade.
    """
    blueprint = _blueprint_ref()
    snapshot = _sections()
    advanced_snapshot = _sections()
    _, section_v3 = _advance_section_two(advanced_snapshot, blueprint)
    # The store's head is the ORIGINAL v1 section; the caller declares v3.
    chain = _full_chain({1: snapshot[0], 2: snapshot[1], 3: snapshot[2]})
    store = RecordingStore(chain)

    ctx = _make_context([snapshot[0], section_v3, snapshot[2]], blueprint, uuid.uuid4())
    gen = PaperGeneratorAdapter(
        paper_id="p1", title="T", blueprint_ref=blueprint,
        section_envelopes=[snapshot[0], section_v3, snapshot[2]],
        persistence_client=store,
    )

    with pytest.raises(ValueError, match="regressed"):
        await gen.generate(ctx, "intent_gen_1", version=1)


# ─────────────────────────────────────────────────────────────────────────────
# (e) PaperLoop.run must declare the LIVE heads, not the caller's snapshot.
# ─────────────────────────────────────────────────────────────────────────────


@pytest.mark.asyncio
async def test_paper_loop_declares_live_section_heads_as_input_dependencies(monkeypatch):
    """`PaperLoop.run` must declare input deps resolved against the live chain.

    `PaperLoop.run` builds `input_deps` from the caller's snapshot envelopes
    (paper.py:793). If it declares the snapshot while the generator binds the live
    head, the runtime's declared deps and the artifact's parent refs disagree by
    construction and the admission check fires. Both sides must read the same head.
    """
    blueprint = _blueprint_ref()
    snapshot = _sections()
    _, section_v3 = _advance_section_two(snapshot, blueprint)
    chain = _full_chain({1: snapshot[0], 2: section_v3, 3: snapshot[2]})
    store = RecordingStore(chain)

    captured: Dict[str, Any] = {}

    class _CapturingRuntime:
        def __init__(self, context, policy, generator, evaluators, repairer=None,
                     persistence_client=None, accepted_dependencies=None, **kwargs):
            self.context = context
            captured["context"] = context
            captured["generator"] = generator
            captured["accepted"] = accepted_dependencies

        async def run(self):
            from app.contracts.issue import IssueLedger
            from app.contracts.loop import DecisionType, LoopReason, LoopState
            from app.loop.runtime import LoopResult
            return LoopResult(
                runId=self.context.run_id, decision=DecisionType.PASS,
                terminalState=LoopState.COMPLETED, acceptedArtifact=None,
                terminalReason="captured", terminalReasonCode=LoopReason.ACCEPTED,
                ledger=IssueLedger(ledgerId="led_captured", runId=self.context.run_id),
            )

    monkeypatch.setattr("app.loop.paper.BoundedLoopRuntime", _CapturingRuntime)

    paper_loop = PaperLoop(persistence_client=store)
    await paper_loop.run(
        run_id=RUN_ID, blueprint_ref=blueprint, section_envelopes=list(snapshot),
        title="Live Heads", paper_id="p_live", owner=uuid.uuid4(), epoch=1,
    )

    declared = {
        r.artifact_id: r.version
        for r in captured["context"].input_dependencies
        if r.artifact_type == ArtifactType.SECTION
    }
    assert declared.get(section_v3.artifact_id) == section_v3.version, (
        f"PaperLoop.run must declare the LIVE section head v{section_v3.version}, got "
        f"{declared} (pre-fix it declares the snapshot's v1)"
    )