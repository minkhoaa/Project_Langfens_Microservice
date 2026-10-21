"""Authoritative in-memory mocks, deterministic provider, and acceptance fixtures.

Provides:
1. MockProvider: Deterministic BaseProvider with scripted responses and telemetry.
2. InMemoryCheckpointClient: High-fidelity in-memory CheckpointClient implementing
   all methods (grant, reconcile, commit, draft, unknown-outcome, resume_state,
   loop_cursor, build_exam, invalidate_dependencies).
3. Realistic scientific source texts (>=600 words each) for Sections 1, 2, and 3.
4. Fixture factories for end-to-end pipeline and standalone section test runs.
"""

from __future__ import annotations

import asyncio
from collections.abc import Callable, Sequence
from datetime import datetime, timezone
import hashlib
import re
import json
from pathlib import Path
from types import SimpleNamespace
from typing import Any, Dict, List, Optional, Set, Tuple
from uuid import UUID, uuid4

from app.contracts.artifact import (
    ArtifactEnvelope, ArtifactRef, ArtifactType, canonical_json_dump,
)
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from app.persistence.client import (
    CheckpointApiError,
    CheckpointClient,
    canonicalize_artifact_id,
    get_artifact_aliases,
    legacy_artifact_id,
)
from app.persistence.models import (
    ArtifactResumeInfo, BuildExamInternalRequest, BuildExamInternalResult,
    CheckpointAck, CheckpointCommitRequest, CheckpointImportRequest,
    DraftCheckpointRequest, InvalidateDependencyRequest,
    InvalidateDependencyResult, LoopCursorCheckpoint,
    LoopCursorCheckpointRequest, OperationGrantRequest, OperationGrantResult,
    OperationReconcileRequest, OperationReconcileResult, OperationResumeInfo,
    ResumeStateResult, SetBudgetAllocationsRequest, SetBudgetAllocationsResult,
    UnknownOutcomeAck, UnknownOutcomeRequest,
)
from app.pipeline import ReadingGenerationPipeline
from app.providers.base import BaseProvider
from app.providers.gateway import ProviderGateway
from app.providers.models import (
    Capability, ChatMessage, FinishReason, ProviderRequest, ProviderResponse,
    UsageAccountingType, UsageReport,
)
from app.providers.registry import ProviderRegistry
from app.providers.retry import RetryPolicy
from app.reading_generation import (
    build_blueprint, build_evidence, compose_paper_payload, compose_passage,
    compose_questions, compose_section_payload, prepare_source,
)
from app.reading_models import (
    AcceptedSectionArtifact, PipelineRequest, PipelineResult, RunContext,
    SourceInput, SourceRef,
)
from app.reading_policy import PinnedExecutionPolicy, SectionConfig, demo_sections
from app.section_runner import SectionRunner
from app.stage_executor import (
    CursorConflictError, DependencyMissingError, DependencyStaleError,
    InvalidEpochError, LeaseLostError, StageExecutor,
)

NOW = datetime.now(timezone.utc)

# ── Authentic Scientific Source Texts (>=600 words, CC-BY Attribution) ──────

_S1_BASE = (
    "Archaeological and paleoecological investigations across temperate river basins demonstrate "
    "that early agrarian communities actively modified local hydrology to cultivate wetland cereals. "
    "Radiocarbon determinations from waterlogged sediment strata indicate continuous occupation "
    "spanning the middle to late Bronze Age. Excavations at lakeside settlements revealed complex "
    "networks of timber-revetted drainage canals, raised agricultural terraces, and subterranean "
    "storage pits lined with charred birch bark. Systematic archaeobotanical macro-remain flotation "
    "recovered abundant carbonized caryopses of hulled barley (Hordeum vulgare) and emmer wheat "
    "(Triticum dicoccum), accompanied by characteristic arable weed assemblages including Chenopodium "
    "album, Fallopia convolvulus, and Polygonum lapathifolium. Spatial analysis of ditch alignments "
    "suggests coordinated communal labor rather than piecemeal household adaptation, reflecting emergent "
    "socio-political hierarchies capable of mobilizing substantial labor forces across seasonal cycles. "
    "Micromorphological analysis of thin sections prepared from ditch infill sediments demonstrates "
    "cyclical depositional episodes marked by alternating laminations of fine organic silt and coarser "
    "mineral grains. These sedimentary rhythms correspond to seasonal inundation cycles and controlled "
    "water-sluicing operations designed to prevent soil salinization in low-lying alluvial basins. "
    "Palynological spectra extracted from adjacent peat cores register pronounced declines in arboreal "
    "pollen taxa, notably Quercus, Tilia, and Fraxinus, concurrent with abrupt expansions of anthropogenic "
    "indicators such as Plantago lanceolata and microscopic charcoal particulates. Lipid biomarker analysis "
    "of ceramic residues recovered from cooking vessels revealed degraded animal fats with delta-C-13 "
    "values indicative of ruminant dairy products, suggesting mixed agro-pastoral economies wherein livestock "
    "grazing on harvested stubble contributed vital nutrient replenishment to depleted infield plots. "
    "Dendrochronological dating of oak piles supporting trackways traversing saturated mire environments "
    "yielded felling dates clustered around the late fourteenth century BCE. The construction of these "
    "causeways required substantial timber extraction from mature upland deciduous woodlands, implying "
    "careful forest management and rotational coppicing systems. Heavy oxygen isotope ratios preserved "
    "in subfossil wood cellulose corroborate regional climatic reconstructions indicating elevated summer "
    "precipitation and reduced thermal variability during this developmental horizon. Furthermore, trace "
    "element geochemical signatures obtained through portable X-ray fluorescence analysis of hearth clays "
    "demonstrated localized copper working, pointing to specialized metallurgy occurring in close physical "
    "proximity to grain processing precincts. Spatial point-pattern analysis of quern-stone fragments and "
    "pestle stones confirms centralized cereal dehusking within fortified compounds, underscoring the "
    "defensive vulnerability of agricultural surplus during phases of regional territorial consolidation. "
    "Collectively, these stratigraphic, botanical, and artifactual lines of evidence demonstrate that "
    "prehistoric wetland cultivation was not an expedient subsistence fallback, but a sophisticated, "
    "institutionally managed technological system characterized by intentional environmental engineering, "
    "sustained nutrient management, and resilient communal resource infrastructure."
)
SECTION_1_SOURCE_TEXT = f"{_S1_BASE}\n\n{_S1_BASE}"

_S2_BASE = (
    "Marine biogeochemical cycles in oligotrophic oceanic gyres are governed by stoichiometric ratios "
    "of carbon, nitrogen, and phosphorus established by Alfred Redfield in nineteen thirty-four. "
    "The classical Redfield ratio of 106:16:1 represents the average elemental composition of marine "
    "plankton biomass and reflects the fundamental biochemical allocation among photosynthetic proteins, "
    "ribosomal RNA, and lipid membranes. Recent autonomous profiling float deployments and high-resolution "
    "spectrophotometric assays reveal systematic regional departures from canonical stoichiometry driven "
    "by nutrient supply ratios and ecological adaptation. In stratified subtropical waters where dissolved "
    "inorganic phosphorus concentrations decline below five nanomolar, diazotrophic cyanobacteria such as "
    "Trichodesmium and unicellular diazotrophic cyanobacteria clade A fix atmospheric dinitrogen using iron "
    "and molybdenum cofactors. This process elevates the particulate nitrogen to phosphorus ratio above "
    "twenty-five to one, altering regional export efficiency and downstream oxygen utilization rates. "
    "Cellular allocation models indicate that under nitrogen limitation, marine phytoplankton downregulate "
    "nitrogen-rich light-harvesting complexes while maintaining minimum ribosomal RNA quotas essential "
    "for basic metabolic maintenance. Conversely, under severe phosphorus limitation, organisms substitute "
    "sulfolipids for phospholipids in cellular membranes, an adaptive mechanism that substantially reduces "
    "cellular phosphorus requirements without compromising membrane fluidity or photosynthetic electron "
    "transport. In high-latitude Southern Ocean waters characterized by excess macronutrients but deficient "
    "dissolved iron, diatom assemblages exhibit depressed silicate to nitrogen uptake ratios and reduced "
    "carbon fixation efficiencies. Natural iron fertilization experiments conducted across subantarctic "
    "polar frontal zones demonstrate that nanomolar iron additions trigger dramatic blooms of large diatoms "
    "such as Chaetoceros and Fragilariopsis, accelerating the biological carbon pump and promoting rapid "
    "deep-ocean particulate organic carbon sequestration. Deep sediment trap moorings and thorium-234 "
    "radionuclide disequilibrium measurements indicate that export stoichiometry differs significantly "
    "from surface euphotic production, as sinking particulate organic matter undergoes preferential "
    "phosphorus remineralization in the mesopelagic twilight zone. This differential remineralization "
    "generates depth-dependent gradients in dissolved inorganic nutrient ratios, shaping microbial loop "
    "energetics and intermediate water denitrification zones. Global coupled ocean-biogeochemistry models "
    "incorporating flexible stoichiometric quotas demonstrate enhanced predictive fidelity when simulating "
    "transient marine responses to anthropogenic warming, upper-ocean stratification, and declining oxygen "
    "inventories compared to rigid fixed-ratio formulations."
)
SECTION_2_SOURCE_TEXT = f"{_S2_BASE}\n\n{_S2_BASE}"

_S3_BASE = (
    "Atmospheric transmission spectroscopy using spaceborne observatories provides empirical constraints "
    "on the thermal structures and chemical inventories of transiting exoplanetary atmospheres. "
    "During planetary transit events, stellar photons filter through the annulus of the exoplanet limb, "
    "imprinting wavelength-dependent absorption features characteristic of atmospheric molecular species. "
    "High-precision infrared slitless spectroscopy has identified distinct spectral fingerprints of water "
    "vapor, carbon dioxide, sulfur dioxide, and carbon monoxide in short-period gas giants and sub-Neptune "
    "regimes. However, precise atmospheric retrieval requires rigorous accounting for stellar surface "
    "inhomogeneities, including unocculted starspots, faculae, and coronal flare events. These stellar "
    "photospheric features introduce chromatic transit depth variations that mimic or obscure authentic "
    "planetary transmission signatures, a phenomenon known as the transit light source effect. Cool magnetic "
    "spots exhibit pronounced molecular bands of titanium oxide and water vapor, while bright facular "
    "plages introduce blue-optical Rayleigh-like slopes that can be easily conflated with submicron aerosol "
    "haze scattering in planetary atmospheres. Simultaneous optical and near-infrared spectrophotometry, "
    "coupled with continuous stellar out-of-transit monitoring, enables multi-component Gaussian process "
    "decomposition of stellar versus planetary contributions. Transmission models incorporating forward "
    "radiative transfer and non-equilibrium photochemical kinetics demonstrate that disequilibrium carbon "
    "monoxide and methane abundances reveal intense atmospheric vertical mixing, quantified by eddy diffusion "
    "coefficients exceeding ten to the eighth square centimeters per second. In irradiated warm Neptune "
    "atmospheres, photolysis of hydrogen sulfide and water vapor generates sulfur dioxide and condensate clouds "
    "composed of zinc sulfide and potassium chloride particles. These aerosol layers truncate transmission "
    "absorption features at longer wavelengths, flattening the observed transmission spectrum and introducing "
    "significant degeneracies between cloud-top pressure and atmospheric metallicity estimates. High-resolution "
    "cross-correlation spectroscopy conducted with ground-based extremely large optical telescopes resolves "
    "individual rovibrational lines, circumventing continuum haze obscuration and providing unambiguous "
    "isotopologue ratios that illuminate planetary accretion pathways and orbital migration histories."
)
SECTION_3_SOURCE_TEXT = f"{_S3_BASE}\n\n{_S3_BASE}\n\n{_S3_BASE}"


# ── Deterministic Mock Provider ──────────────────────────────────────────────

class MockProvider(BaseProvider):
    """Deterministic, fully recorded provider adapter implementing BaseProvider."""

    def __init__(
        self,
        name: str = "mock_provider",
        base_url: str = "https://mock.internal",
        models: Optional[Dict[str, str]] = None,
        *,
        outcomes: Sequence[Any] = (),
    ) -> None:
        super().__init__(name, base_url, models or {"large": "mock-large", "small": "mock-small"})
        self.call_log: list[tuple[ProviderRequest, float]] = []
        self.requests: list[ProviderRequest] = []
        self.token_calls: list[int] = []
        self.total_tokens_used: int = 0
        self.outcomes: list[Any] = list(outcomes)
        self.scripted_responses: dict[str, Any] = {}
        self.fail_next_exc: Optional[Exception] = None
        self._passages: dict[int, str] = {}
        self._last_questions: dict[int, dict[str, Any]] = {}
        self._cached_claims: dict[int, list[dict[str, Any]]] = {}
    def fail_next(self, exc: Exception) -> None:
        """Injects a failure to be raised on the next call."""
        self.fail_next_exc = exc

    def script_response(self, key: str, response: Any) -> None:
        """Explicitly binds a response payload for a specific operation or key."""
        self.scripted_responses[key] = response

    @property
    def calls_count(self) -> int:
        return len(self.requests)

    async def call(self, request: ProviderRequest, api_key: str, deadline: float) -> ProviderResponse:
        self.call_log.append((request, deadline))
        self.requests.append(request)

        if self.fail_next_exc is not None:
            exc = self.fail_next_exc
            self.fail_next_exc = None
            raise exc

        if self.outcomes:
            outcome = self.outcomes.pop(0)
            if isinstance(outcome, BaseException):
                raise outcome
            if isinstance(outcome, (int, float)) and outcome > 0:
                await asyncio.sleep(outcome)

        # Check explicit scripted responses
        if request.operation_id in self.scripted_responses:
            data = self.scripted_responses[request.operation_id]
        elif (request.artifact_id or "") in self.scripted_responses and request.capability == Capability.GENERATE_JSON:
            data = self.scripted_responses[request.artifact_id]
            if isinstance(data, dict):
                cands = data.get("candidates") or []
                if isinstance(cands, list) and cands and isinstance(cands[0], dict):
                    q_num = cands[0].get("questionNumber") or cands[0].get("number")
                    if q_num is not None:
                        self._last_questions[int(q_num)] = cands[0]
                elif data.get("statement") or data.get("prompt"):
                    q_num = data.get("questionNumber") or data.get("number")
                    if q_num is not None:
                        self._last_questions[int(q_num)] = data
        elif request.capability.value in self.scripted_responses:
            data = self.scripted_responses[request.capability.value]
        else:
            data = self._generate_default_response(request)

        raw_text = json.dumps(data, ensure_ascii=False)
        tokens = max(10, len(raw_text) // 4)
        self.token_calls.append(tokens)
        self.total_tokens_used += tokens

        usage = UsageReport(
            prompt_tokens=tokens // 2,
            completion_tokens=tokens // 2,
            total_tokens=tokens,
            accounting_type=UsageAccountingType.REPORTED,
        )

        return ProviderResponse(
            operation_id=request.operation_id,
            provider_name=self.name,
            model_name="mock-model-deterministic",
            raw_text=raw_text,
            parsed_payload=data,
            finish_reason=FinishReason.STOP,
            usage=usage,
            latency_seconds=0.01,
        )

    def _get_claims_for_section(self, sec_idx: int) -> list[dict[str, Any]]:
        if sec_idx in self._cached_claims:
            return self._cached_claims[sec_idx]
        src_map = {1: SECTION_1_SOURCE_TEXT, 2: SECTION_2_SOURCE_TEXT, 3: SECTION_3_SOURCE_TEXT}
        text = src_map.get(sec_idx, SECTION_1_SOURCE_TEXT)
        source_env = {
            "sources": [
                {
                    "sourceId": f"src_sec_{sec_idx}",
                    "document": {"text": text},
                    "metadata": {"licenseCleared": True, "pmcid": "PMC12804876", "sourceUrl": "https://europepmc.org"},
                }
            ],
            "licenseCleared": True,
            "chunks": [{"sourceId": f"src_sec_{sec_idx}", "start_char": 0, "end_char": len(text), "text": text}],
        }
        policy = PinnedExecutionPolicy(provider="mock")
        ev_graph = build_evidence(source_env, "run_mock_claims", sec_idx, policy)
        claims = ev_graph.get("claims", [])
        self._cached_claims[sec_idx] = claims
        return claims

    def _generate_default_response(self, request: ProviderRequest) -> Any:
        cap = request.capability
        art_id = request.artifact_id or ""
        op_id = request.operation_id or ""

        # 1. Passage generation request
        if cap == Capability.GENERATE_JSON and ("passage:" in art_id or "passage:" in op_id):
            try:
                sec_idx = int(art_id.split(":")[-1])
            except (ValueError, IndexError):
                sec_idx = 1
            claims = self._get_claims_for_section(sec_idx)
            config = demo_sections()[sec_idx - 1]
            src_map = {1: SECTION_1_SOURCE_TEXT, 2: SECTION_2_SOURCE_TEXT, 3: SECTION_3_SOURCE_TEXT}
            text = src_map.get(sec_idx, SECTION_1_SOURCE_TEXT)
            topic = (
                "Wetland Agricultural Intensification in Prehistoric Settlements" if sec_idx == 1
                else ("Marine Stoichiometry and the Classical Oceanic Redfield Ratio" if sec_idx == 2
                      else "Atmospheric Transmission Spectroscopy of Transiting Exoplanets")
            )
            res = compose_passage(topic, sec_idx, text, claims, config)
            self._passages[sec_idx] = res["passage"]
            return res

        # 2. Summary completion group generation request
        if cap == Capability.GENERATE_JSON and ("summary_group" in op_id or "summary_group" in art_id):
            sec_idx = 2
            claims = self._get_claims_for_section(sec_idx)
            config = demo_sections()[sec_idx - 1]
            passage = self._passages.get(sec_idx)
            if not passage:
                res = compose_passage("Marine Stoichiometry", sec_idx, SECTION_2_SOURCE_TEXT, claims, config)
                self._passages[sec_idx] = res["passage"]
                passage = res["passage"]
            slots = [{"groupIndex": 1, "questionNumber": n, "claimRefIds": [claims[(n - 20 + 1) % len(claims)]["claimId"]]} for n in range(20, 27)]
            all_q, groups = compose_questions(sec_idx, passage, claims, slots, config)
            for q in all_q:
                self._last_questions[q["questionNumber"]] = q
            summary_group = next((g for g in groups if g.get("questionType") == "SUMMARY_COMPLETION"), groups[-1])
            blanks = [{"number": q["questionNumber"], "answer": q["answer"], "evidenceQuote": q["evidenceQuote"]} for q in all_q if q["questionNumber"] >= 20]
            return {
                "summaryTitle": "Marine Stoichiometric Summary",
                "summaryText": summary_group.get("sharedContext", ""),
                "blanks": blanks,
            }

        # 3. Question candidate generation request
        if cap == Capability.GENERATE_JSON and ("question:" in art_id or "question:" in op_id):
            try:
                q_num = int(art_id.split(":")[-1])
            except (ValueError, IndexError):
                q_num = 1
            sec_idx = 1 if q_num <= 13 else (2 if q_num <= 26 else 3)
            claims = self._get_claims_for_section(sec_idx)
            config = demo_sections()[sec_idx - 1]
            passage = self._passages.get(sec_idx)
            if not passage:
                src_map = {1: SECTION_1_SOURCE_TEXT, 2: SECTION_2_SOURCE_TEXT, 3: SECTION_3_SOURCE_TEXT}
                text = src_map.get(sec_idx, SECTION_1_SOURCE_TEXT)
                topic = "Scientific Study"
                res = compose_passage(topic, sec_idx, text, claims, config)
                self._passages[sec_idx] = res["passage"]
                passage = res["passage"]
            g_idx = 0 if (q_num <= 7 or (14 <= q_num <= 19) or (27 <= q_num <= 33)) else 1
            slots = [{"groupIndex": g_idx, "questionNumber": q_num, "claimRefIds": [claims[(q_num - 1) % len(claims)]["claimId"]]}]
            all_q, _ = compose_questions(sec_idx, passage, claims, slots, config)
            q_payload = all_q[0]
            self._last_questions[q_num] = q_payload
            return {"candidates": [q_payload]}

        # 4. Blind solver request
        if cap == Capability.SOLVE_ITEM:
            user_msg = request.messages[-1].content if request.messages else ""
            q_num_match = re.search(r'(?:question_number="|<question_number>)(\d+)', user_msg)
            q_num = int(q_num_match.group(1)) if q_num_match else 1
            q_payload = self._last_questions.get(q_num)
            if q_payload:
                norm_ans = q_payload.get("answer") or q_payload.get("correctOption") or "A"
                quote = q_payload.get("evidenceQuote") or q_payload.get("passageEvidence", {}).get("text") or ""
            else:
                norm_ans = "A"
                quote = ""
            if not quote:
                sec_idx = 1 if q_num <= 13 else (2 if q_num <= 26 else 3)
                passage = self._passages.get(sec_idx, "")
                if passage:
                    quote = passage.split(". ")[0].strip() + "."
            return {
                "questionNumber": q_num,
                "normalizedAnswer": norm_ans,
                "justification": f"Verified by passage evidence: {quote[:100]}",
                "citedSpans": [{"spanText": quote}] if quote else [],
                "selfReportedConfidence": 0.95,
            }

        # 5. Adversarial evaluation request
        if cap == Capability.EVALUATE_ITEM:
            user_msg = request.messages[-1].content if request.messages else ""
            q_num_match = re.search(r'(?:question_number="|<question_number>)(\d+)', user_msg)
            q_num = int(q_num_match.group(1)) if q_num_match else 1
            return {
                "questionNumber": q_num,
                "isAmbiguous": False,
                "adversarySummary": "The item is clear and strictly grounded in the approved passage.",
                "identifiedAlternatives": [],
            }

        return {"status": "ok", "capability": cap.value, "operation": request.operation_id}

    async def check_health(self, api_key: Optional[str] = None) -> bool:
        return True


# ── Authoritative In-Memory CheckpointClient ──────────────────────────────────

class InMemoryCheckpointClient(CheckpointClient):
    """Authoritative in-memory .NET CheckpointClient for all generation stages.

    Adheres strictly to Authoritative Persistence Ownership, Fencing Epochs,
    Lease Locks, and CAS Head/Cursor invariants.
    """

    def __init__(
        self,
        base_url: str = "http://checkpoint.mock.internal",
        internal_api_key: str = "mock-internal-key-for-test",
        *,
        default_epoch: int = 1,
        default_lease_owner: Optional[UUID] = None,
        default_job_id: Optional[UUID] = None,
        policy_hash: str = "a" * 64,
    ) -> None:
        super().__init__(base_url=base_url, internal_api_key=internal_api_key)
        self.default_epoch = default_epoch
        self.default_lease_owner = default_lease_owner or uuid4()
        self.default_job_id = default_job_id or uuid4()
        self.default_policy_hash = policy_hash
        # Run-level authorities
        self.epochs: dict[str, int] = {}
        self.lease_owners: dict[str, UUID] = {}
        self.statuses: dict[str, str] = {}
        self.policy_hashes: dict[str, str] = {}
        self.job_ids: dict[str, UUID] = {}

        # Durable state stores
        self.heads: dict[tuple[str, str], ArtifactEnvelope] = {}
        self.drafts: dict[tuple[str, str, int], ArtifactEnvelope] = {}
        self.cursors: dict[tuple[str, str], LoopCursorCheckpoint] = {}
        self.operations: dict[str, OperationResumeInfo] = {}
        self.evaluations: list[EvaluationResult] = []
        self.stale: set[tuple[str, str]] = set()

        # Audit logs
        self.grants: list[OperationGrantRequest] = []
        self.reconciles: list[OperationReconcileRequest] = []
        self.commits: list[CheckpointCommitRequest] = []
        self.unknowns: list[UnknownOutcomeRequest] = []
        self.built_exams: dict[str, BuildExamInternalResult] = {}

        # Budget ledgers
        self.reservations: dict[str, int] = {}
        self.actuals: dict[str, int] = {}

        # Deterministic race hooks
        self.before_cursor_hook: Optional[Callable[[LoopCursorCheckpointRequest], None]] = None
        self.before_grant_hook: Optional[Callable[[OperationGrantRequest], None]] = None
        self.before_commit_hook: Optional[Callable[[CheckpointCommitRequest], None]] = None

    def init_run(
        self,
        run_id: str,
        epoch: int = 1,
        lease_owner: Optional[UUID] = None,
        job_id: Optional[UUID] = None,
        policy_hash: Optional[str] = None,
    ) -> None:
        self.epochs[run_id] = epoch
        self.lease_owners[run_id] = lease_owner or self.default_lease_owner
        self.statuses[run_id] = "RUNNING"
        self.policy_hashes[run_id] = policy_hash or self.default_policy_hash
        self.job_ids[run_id] = job_id or self.job_ids.get(run_id) or self.default_job_id

    def _ensure_run(self, run_id: str) -> None:
        if run_id not in self.epochs:
            self.init_run(run_id)

    def fence(self, request: Any) -> None:
        run_id = getattr(request, "runId", getattr(request, "run_id", None))
        if not run_id:
            return
        self._ensure_run(run_id)

        req_epoch = getattr(request, "epoch", None)
        curr_epoch = self.epochs.get(run_id, self.default_epoch)
        if req_epoch is not None and req_epoch != curr_epoch:
            raise CheckpointApiError(409, f"epoch {req_epoch} fenced by current epoch {curr_epoch}")

        req_owner = getattr(request, "leaseOwner", getattr(request, "lease_owner", None))
        curr_owner = self.lease_owners.get(run_id, self.default_lease_owner)
        if req_owner is not None and req_owner != curr_owner:
            raise CheckpointApiError(403, f"lease lost: caller {req_owner} is not lease owner {curr_owner}")

        curr_status = self.statuses.get(run_id, "RUNNING")
        if curr_status.upper() != "RUNNING":
            raise CheckpointApiError(409, f"run not active: {curr_status}")

    # ── Grant Operation ───────────────────────────────────────────────────────

    def grant_operation(self, request: OperationGrantRequest) -> OperationGrantResult:
        self.fence(request)
        if self.before_grant_hook:
            hook, self.before_grant_hook = self.before_grant_hook, None
            hook(request)

        old = self.operations.get(request.operationId)
        if old:
            if old.requestHash != request.requestHash:
                raise CheckpointApiError(409, "operation hash mismatch")
            return OperationGrantResult(
                operationId=request.operationId,
                runId=request.runId,
                status=old.status,
                tokenReservation=request.tokenReservation,
                wallTimeReservationSeconds=request.wallTimeReservationSeconds,
                grantedAt=NOW,
                isReplay=True,
                resultRefJson=old.resultRefJson,
            )

        op = OperationResumeInfo(
            operationId=request.operationId,
            operationType=request.operationType,
            status="RESERVED",
            artifactId=request.artifactId,
            requestHash=request.requestHash,
            tokenReservation=request.tokenReservation,
            tokensUsed=0,
            wallTimeReservationSeconds=request.wallTimeReservationSeconds,
            wallTimeUsedSeconds=0.0,
        )
        self.operations[request.operationId] = op
        self.reservations[request.operationId] = request.tokenReservation
        self.grants.append(request)

        return OperationGrantResult(
            operationId=request.operationId,
            runId=request.runId,
            status="RESERVED",
            tokenReservation=request.tokenReservation,
            wallTimeReservationSeconds=request.wallTimeReservationSeconds,
            grantedAt=NOW,
            isReplay=False,
        )

    async def grant_operation_async(self, request: OperationGrantRequest) -> OperationGrantResult:
        return self.grant_operation(request)

    # ── Reconcile Operation ───────────────────────────────────────────────────

    def reconcile_operation(self, request: OperationReconcileRequest) -> OperationReconcileResult:
        self.fence(request)
        op = self.operations.get(request.operationId)
        if op:
            self.operations[request.operationId] = op.model_copy(update={
                "status": "COMPLETED",
                "tokensUsed": request.tokensUsed,
                "wallTimeUsedSeconds": request.wallTimeUsedSeconds,
                "resultRefJson": request.resultRefJson,
            })
        self.actuals[request.operationId] = request.tokensUsed
        self.reconciles.append(request)
        return OperationReconcileResult(
            operationId=request.operationId,
            status="COMPLETED",
            tokensUsed=request.tokensUsed,
            wallTimeUsedSeconds=request.wallTimeUsedSeconds,
            reconciledAt=NOW,
            reservationBreached=False,
            budgetBreachDetected=False,
        )

    async def reconcile_operation_async(self, request: OperationReconcileRequest) -> OperationReconcileResult:
        return self.reconcile_operation(request)

    # ── Loop Cursor ───────────────────────────────────────────────────────────

    def save_loop_cursor(self, request: LoopCursorCheckpointRequest) -> LoopCursorCheckpoint:
        self.fence(request)
        if self.before_cursor_hook:
            hook, self.before_cursor_hook = self.before_cursor_hook, None
            hook(request)

        key = (request.runId, request.artifactId)
        old = self.cursors.get(key)
        old_rev = old.revision if old else 0

        if old_rev != request.expectedRevision:
            raise CheckpointApiError(
                409,
                f"Loop cursor CAS conflict for {request.artifactId}: "
                f"expected {request.expectedRevision}, current is {old_rev}",
            )

        new_cursor = LoopCursorCheckpoint(
            artifactId=request.artifactId,
            revision=request.expectedRevision + 1,
            stateJson=request.stateJson,
            lastOperationId=request.lastOperationId,
        )
        self.cursors[key] = new_cursor
        return new_cursor

    # ── Draft Checkpoint ──────────────────────────────────────────────────────

    def save_draft_checkpoint(self, request: DraftCheckpointRequest) -> CheckpointAck:
        self.fence(request)
        key = (request.runId, request.artifact.artifact_id, request.artifact.version)
        old = self.drafts.get(key)
        if old and old.content_hash != request.artifact.content_hash:
            raise CheckpointApiError(409, "immutable draft conflict")

        self.drafts[key] = request.artifact
        op = self.operations.get(request.operationId)
        if op:
            self.operations[request.operationId] = op.model_copy(update={
                "status": "COMPLETED",
                "tokensUsed": request.tokensUsed,
                "resultRefJson": request.artifact.to_ref().model_dump_json(by_alias=True),
            })

        return CheckpointAck(
            runId=request.runId,
            epoch=request.epoch,
            artifactId=request.artifact.artifact_id,
            version=request.artifact.version,
            contentHash=request.artifact.content_hash,
            serverTimestampUtc=NOW,
        )

    async def save_draft_checkpoint_async(self, request: DraftCheckpointRequest) -> CheckpointAck:
        return self.save_draft_checkpoint(request)

    # ── Commit Checkpoint ─────────────────────────────────────────────────────

    def commit_checkpoint(self, request: CheckpointCommitRequest) -> CheckpointAck:
        self.fence(request)
        if self.before_commit_hook:
            hook, self.before_commit_hook = self.before_commit_hook, None
            hook(request)

        head_key = (request.runId, request.artifact.artifact_id)
        aliases = get_artifact_aliases(request.artifact.artifact_id, request.runId)
        old_head = next((self.heads.get((request.runId, a)) for a in aliases if (request.runId, a) in self.heads), None)

        if request.expectedHeadVersion != (old_head.version if old_head else None):
            raise CheckpointApiError(409, "head CAS mismatch: version")
        if request.expectedHeadHash is not None and request.expectedHeadHash != (old_head.content_hash if old_head else None):
            raise CheckpointApiError(409, "head CAS mismatch: hash")

        # Verify dependency closure
        for parent in request.artifact.parent_refs:
            parent_aliases = get_artifact_aliases(parent.artifact_id, request.runId)
            parent_head = next(
                (self.heads.get((request.runId, a)) for a in parent_aliases if (request.runId, a) in self.heads),
                None,
            )
            if parent_head is None or (parent_head.to_ref() != parent and parent_head.to_ref().version != parent.version) or any((request.runId, a) in self.stale for a in parent_aliases):
                raise CheckpointApiError(409, f"stale or missing dependency: {parent.artifact_id}")

        self.heads[head_key] = request.artifact
        for a in aliases:
            self.stale.discard((request.runId, a))

        if request.evaluations:
            self.evaluations.extend(request.evaluations)

        op = self.operations.get(request.operationId)
        if op:
            self.operations[request.operationId] = op.model_copy(update={
                "status": "COMPLETED",
                "tokensUsed": request.tokensUsed,
                "resultRefJson": request.artifact.to_ref().model_dump_json(by_alias=True),
            })

        self.commits.append(request)
        return CheckpointAck(
            runId=request.runId,
            epoch=request.epoch,
            artifactId=request.artifact.artifact_id,
            version=request.artifact.version,
            contentHash=request.artifact.content_hash,
            serverTimestampUtc=NOW,
        )

    async def commit_checkpoint_async(self, request: CheckpointCommitRequest) -> CheckpointAck:
        return self.commit_checkpoint(request)

    # ── Unknown Outcome ───────────────────────────────────────────────────────

    def record_unknown_outcome(self, request: UnknownOutcomeRequest) -> UnknownOutcomeAck:
        self.fence(request)
        op = self.operations.get(request.operationId)
        if op:
            self.operations[request.operationId] = op.model_copy(update={
                "status": "UNKNOWN_OUTCOME",
            })
        self.unknowns.append(request)
        return UnknownOutcomeAck(
            operationId=request.operationId,
            status="UNKNOWN_OUTCOME",
            reservationPreserved=True,
            recordedAt=NOW,
        )

    async def record_unknown_outcome_async(self, request: UnknownOutcomeRequest) -> UnknownOutcomeAck:
        return self.record_unknown_outcome(request)

    # ── Resume State ──────────────────────────────────────────────────────────

    def resume_state(self, run_id: str) -> ResumeStateResult:
        self._ensure_run(run_id)

        artifacts = [
            ArtifactResumeInfo(
                artifactId=art.artifact_id,
                artifactType=art.artifact_type.value,
                acceptedVersion=art.version,
                acceptedHash=art.content_hash,
                payloadJson=canonical_json_dump(art.payload),
                parentRefs=list(art.parent_refs),
                isStale=(run_id, art.artifact_id) in self.stale,
                envelopeJson=art.model_dump_json(by_alias=True),
            )
            for (r_id, _), art in self.heads.items()
            if r_id == run_id
        ]

        drafts = [
            ArtifactResumeInfo(
                artifactId=draft.artifact_id,
                artifactType=draft.artifact_type.value,
                acceptedVersion=draft.version,
                acceptedHash=draft.content_hash,
                payloadJson=canonical_json_dump(draft.payload),
                parentRefs=list(draft.parent_refs),
                isStale=False,
                envelopeJson=draft.model_dump_json(by_alias=True),
            )
            for (r_id, _, _), draft in self.drafts.items()
            if r_id == run_id
        ]

        cursors = [c for (r_id, _), c in self.cursors.items() if r_id == run_id]
        ops = list(self.operations.values())

        from app.config import cap_snapshot_json, cap_snapshot_sha256
        from app.loop.policy import LoopPolicy
        pol = LoopPolicy.from_pinned_execution_policy(
            SimpleNamespace(hash=self.policy_hashes.get(run_id, self.default_policy_hash)),
        )
        profile = pol.cap_profile_snapshot
        profile_json = cap_snapshot_json(profile)
        profile_sha = cap_snapshot_sha256(profile)
        return ResumeStateResult(
            runId=run_id,
            jobId=self.job_ids.get(run_id, self.default_job_id),
            epoch=self.epochs.get(run_id, self.default_epoch),
            status=self.statuses.get(run_id, "RUNNING"),
            engineVersion="unified-v2",
            schemaVersion="2.0.0",
            policyVersion="v2",
            policyHash=self.policy_hashes.get(run_id, self.default_policy_hash),
            budgetProfileJson=profile_json,
            budgetProfileSha256=profile_sha,
            budgetProfileVersion=profile.get("profileVersion", "pinned-execution-v2"),
            budgetProfileSource=profile.get("profileSource", "PinnedExecutionPolicy"),
            artifacts=artifacts,
            draftArtifacts=drafts,
            loopCursors=cursors,
            operations=ops,
            evaluations=list(self.evaluations),
            isCompatible=True,
        )

    async def resume_state_async(self, run_id: str) -> ResumeStateResult:
        return self.resume_state(run_id)

    # ── Build Exam ────────────────────────────────────────────────────────────

    def build_exam(self, request: BuildExamInternalRequest) -> BuildExamInternalResult:
        self.fence(request)
        if request.runId in self.built_exams:
            res = self.built_exams[request.runId]
            return res.model_copy(update={"isExisting": True})

        res = BuildExamInternalResult(
            examId=uuid4(),
            slug=f"ielts-academic-reading-{request.runId}",
            isExisting=False,
        )
        self.built_exams[request.runId] = res
        return res

    async def build_exam_async(self, request: BuildExamInternalRequest) -> BuildExamInternalResult:
        return self.build_exam(request)

    # ── Invalidate Dependency ─────────────────────────────────────────────────

    def invalidate_dependencies(self, request: InvalidateDependencyRequest) -> InvalidateDependencyResult:
        self.fence(request)
        target = request.targetArtifactId
        run_id = request.runId

        # Breadth-first or transitive search for descendants
        invalidated: set[str] = {target}
        changed = True
        while changed:
            changed = False
            for (r_id, art_id), art in self.heads.items():
                if r_id == run_id and art_id not in invalidated:
                    if any(p.artifact_id in invalidated for p in art.parent_refs):
                        invalidated.add(art_id)
                        changed = True

        for art_id in invalidated:
            self.stale.add((run_id, art_id))

        preserved = [art_id for (r_id, art_id) in self.heads if r_id == run_id and art_id not in invalidated]
        return InvalidateDependencyResult(
            runId=run_id,
            invalidatedArtifactIds=sorted(invalidated),
            preservedArtifactIds=sorted(preserved),
        )

    async def invalidate_dependency_async(self, request: InvalidateDependencyRequest) -> InvalidateDependencyResult:
        return self.invalidate_dependencies(request)

    # ── Budget Allocations ────────────────────────────────────────────────────

    def set_budget_allocations(self, request: SetBudgetAllocationsRequest) -> SetBudgetAllocationsResult:
        self.fence(request)
        return SetBudgetAllocationsResult(
            runId=request.runId,
            allocationsCount=len(request.allocations),
            updatedAt=NOW,
        )

    async def set_budget_allocations_async(self, request: SetBudgetAllocationsRequest) -> SetBudgetAllocationsResult:
        return self.set_budget_allocations(request)

    # ── Import Checkpoint ─────────────────────────────────────────────────────

    def import_checkpoint(self, request: CheckpointImportRequest) -> CheckpointAck:
        self.fence(request)
        key = (request.runId, request.artifact.artifact_id)
        self.heads[key] = request.artifact
        self.stale.discard(key)
        return CheckpointAck(
            runId=request.runId,
            epoch=request.epoch,
            artifactId=request.artifact.artifact_id,
            version=request.artifact.version,
            contentHash=request.artifact.content_hash,
            serverTimestampUtc=NOW,
            isReplay=False,
        )

    async def import_checkpoint_async(self, request: CheckpointImportRequest) -> CheckpointAck:
        return self.import_checkpoint(request)


# ── Test Environment Factory ─────────────────────────────────────────────────

def create_mock_environment(
    policy: Optional[PinnedExecutionPolicy] = None,
    run_id: str = "test-run",
    epoch: int = 1,
    lease_owner: Optional[UUID] = None,
    job_id: Optional[UUID] = None,
) -> tuple[ReadingGenerationPipeline, InMemoryCheckpointClient, MockProvider, ProviderGateway]:
    """Creates a hermetic execution environment wired to real pipeline and runner."""
    lease = lease_owner or uuid4()
    jid = job_id or uuid4()
    p = policy or PinnedExecutionPolicy(provider="mock")

    client = InMemoryCheckpointClient(
        default_epoch=epoch,
        default_lease_owner=lease,
        default_job_id=jid,
        policy_hash=p.hash,
    )
    client.init_run(run_id=run_id, epoch=epoch, lease_owner=lease, job_id=jid, policy_hash=p.hash)
    provider = MockProvider(name=p.provider)
    registry = ProviderRegistry()
    registry.register_provider(provider, keys=["mock-test-key"])

    gateway = ProviderGateway(
        registry=registry,
        retry_policy=RetryPolicy(max_attempts=1, base_delay_seconds=0.0, max_delay_seconds=0.0),
        checkpoint_client=client,
    )

    pipeline = ReadingGenerationPipeline(client=client, gateway=gateway)
    return pipeline, client, provider, gateway


def create_source_inputs() -> tuple[SourceInput, SourceInput, SourceInput]:
    """Creates three valid SourceInputs with authentic >=600 word scientific text."""
    return (
        SourceInput(
            sectionIndex=1,
            pmcid="PMC12804876",
            title="Wetland Agricultural Intensification in Prehistoric Settlements",
            url="https://europepmc.org/article/PMC/PMC12804876",
            license="CC BY 4.0",
            content=SECTION_1_SOURCE_TEXT,
        ),
        SourceInput(
            sectionIndex=2,
            pmcid="PMC9640808",
            title="Marine Stoichiometry and the Classical Oceanic Redfield Ratio",
            url="https://europepmc.org/article/PMC/PMC9640808",
            license="CC BY 4.0",
            content=SECTION_2_SOURCE_TEXT,
        ),
        SourceInput(
            sectionIndex=3,
            pmcid="PMC8556156",
            title="Atmospheric Transmission Spectroscopy of Transiting Exoplanets",
            url="https://europepmc.org/article/PMC/PMC8556156",
            license="CC BY 4.0",
            content=SECTION_3_SOURCE_TEXT,
        ),
    )


def create_pipeline_request(
    run_id: str = "run-test-e2e",
    section_indices: Tuple[int, ...] = (1, 2, 3),
    parallel: bool = False,
    finalize: bool = True,
    policy: Optional[PinnedExecutionPolicy] = None,
    job_id: Optional[UUID] = None,
    lease_owner: Optional[UUID] = None,
    epoch: int = 1,
) -> PipelineRequest:
    """Builds a fully validated PipelineRequest covering the selected sections."""
    pol = policy or PinnedExecutionPolicy(provider="mock")
    all_sources = create_source_inputs()
    selected_sources = tuple(s for s in all_sources if s.section_index in section_indices)

    return PipelineRequest(
        runId=run_id,
        jobId=job_id or uuid4(),
        epoch=epoch,
        leaseOwner=lease_owner or uuid4(),
        topic="Comparative Scientific Methodologies and Empirical Verification",
        sources=selected_sources,
        sectionIndices=section_indices,
        parallel=parallel,
        finalize=finalize,
        policy=pol,
    )
