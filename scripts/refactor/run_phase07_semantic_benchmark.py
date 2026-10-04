#!/usr/bin/env python3
"""Executable Semantic Benchmark Runner for Phase 07 (Gate G07).

Executes the real live evaluator pipeline (deterministic + semantic + live ProviderGateway)
against the frozen, family-disjoint evaluation corpus.

Features:
- Live ProviderGateway execution through actual MiniMax/Groq adapters.
- Complete bounded chunked coverage for passage-wide relation checking.
- Checkpoint persistence and resume: reconciles per-case progress to avoid repeating paid calls.
- Repetitions for critical semantic fixtures (>= 3 runs), reporting aggregate and worst run.
- Accurate confusion matrices, recall per type, ambiguity recall, false rejection rate.
- Sanitized outputs: zero secret leakage, token usage, latency, and call tracking.
"""

from __future__ import annotations

import argparse
import asyncio
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import sys
import time
from typing import Any, Dict, List, Optional, Tuple
from uuid import uuid4

BASE_DIR = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(BASE_DIR / "services" / "generation-service"))

from app.config import settings
from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueSeverity
from app.evaluators.deterministic import (
    AnswerVerbatimAndLengthEvaluator,
    DuplicateAndShingleEvaluator,
    EvidenceOffsetEvaluator,
    QuestionStructureEvaluator,
)
from app.evaluators.semantic import (
    AmbiguityAndDistractorEvaluator,
    GroundingFidelityEvaluator,
    NotGivenSemanticsEvaluator,
)
from app.loop.context import AuthorityGrant, LoopContext
from app.persistence.models import BudgetAllocationItem
from app.providers.gateway import ProviderGateway
from app.providers.registry import ProviderRegistry
from tests.test_t03_providers import MockCheckpointClient
from app.evaluators.metrics import (
    calculate_semantic_benchmark_metrics,
    METRIC_ENGINE_VERSION,
    METRIC_ENGINE_HASH,
)

CORPUS_DIR = BASE_DIR / "artifacts" / "refactor" / "phase-07" / "corpus"
ARTIFACTS_DIR = BASE_DIR / "artifacts" / "refactor" / "phase-07"
ARTIFACTS_DIR.mkdir(parents=True, exist_ok=True)
CAMPAIGNS_DIR = ARTIFACTS_DIR / "campaigns"
CAMPAIGNS_DIR.mkdir(parents=True, exist_ok=True)




def compute_question_input_hash(passage_text: str, q_type: str, q_data: Dict[str, Any]) -> str:
    raw = {
        "passage": passage_text,
        "questionType": q_type,
        "prompt": q_data.get("prompt"),
        "answer": q_data.get("answer"),
        "options": q_data.get("options", []),
        "evidenceQuote": q_data.get("evidenceQuote", ""),
    }
    return hashlib.sha256(json.dumps(raw, sort_keys=True).encode("utf-8")).hexdigest()[:16]


def compute_fidelity_input_hash(passage: str, source: str, claims: list) -> str:
    raw = {"passage": passage, "source": source, "claims": claims}
    return hashlib.sha256(json.dumps(raw, sort_keys=True).encode("utf-8")).hexdigest()[:16]


def compute_file_sha256(path: Path) -> str:
    with open(path, "rb") as f:
        return hashlib.sha256(f.read()).hexdigest()


def make_bench_context(
    run_id: str,
    target_id: str,
    owner_id: Optional[uuid4] = None,
    section_id: Optional[int] = 1,
) -> LoopContext:
    owner = owner_id or uuid4()
    return LoopContext(
        runId=run_id,
        targetArtifactId=target_id,
        targetArtifactType=ArtifactType.QUESTION,
        scope="QUESTION",
        sectionId=section_id,
        authority=AuthorityGrant(leaseOwner=owner, epoch=1),
    )


class BenchmarkCheckpointClient(MockCheckpointClient):
    """Authoritative in-memory checkpoint client strictly bound to production Settings caps.

    Enforces ADR-001, ADR-002, and ADR-004 reservation and reconciliation without bypassing
    or raising production runtime caps:
    - run_tokens_cap = settings.loop_max_total_tokens (60,000)
    - run_calls_cap = settings.loop_max_total_calls (15)
    - run_wall_time_cap = int(settings.loop_max_wall_time_seconds) (300)
    - artifact tokenCap = settings.evaluator_max_tokens_per_evaluation (1,500)
    - artifact callCap = 4
    - artifact wallTimeCap = int(settings.evaluator_semantic_timeout_seconds) (30)
    """

    def __init__(self):
        super().__init__(
            run_tokens_cap=settings.loop_max_total_tokens,
            run_calls_cap=settings.loop_max_total_calls,
            run_wall_time_cap=int(settings.loop_max_wall_time_seconds),
        )

    async def grant_operation_async(self, request):
        sec_str = str(request.sectionId) if request.sectionId else None
        if sec_str and sec_str not in self.allocations:
            self.allocations[sec_str] = BudgetAllocationItem(
                scopeType="SECTION",
                scopeId=sec_str,
                parentScopeId=None,
                tokenCap=settings.loop_max_total_tokens,
                callCap=settings.loop_max_total_calls,
                wallTimeCapSeconds=int(settings.loop_max_wall_time_seconds),
            )
        if request.artifactId and request.artifactId not in self.allocations:
            self.allocations[request.artifactId] = BudgetAllocationItem(
                scopeType="ARTIFACT",
                scopeId=request.artifactId,
                parentScopeId=sec_str,
                tokenCap=settings.evaluator_max_tokens_per_evaluation,
                callCap=4,
                wallTimeCapSeconds=int(settings.evaluator_semantic_timeout_seconds),
            )
        return await super().grant_operation_async(request)


class SemanticBenchmarkRunner:
    def __init__(
        self,
        partition: str = "holdout",
        concurrency: int = 4,
        campaign_id: Optional[str] = None,
        fresh: bool = False,
        checkpoint_file: Optional[Path] = None,
    ):
        self.partition = partition
        self.concurrency = concurrency
        self.fresh = fresh
        self.campaign_id = campaign_id or f"camp_g07_{datetime.now(timezone.utc).strftime('%Y%m%d_%H%M%S')}_{uuid4().hex[:6]}"
        self.checkpoint_file = checkpoint_file or (CAMPAIGNS_DIR / f"{self.campaign_id}_checkpoint.json")
        self.results_file = CAMPAIGNS_DIR / f"{self.campaign_id}_results.json"
        self.confusion_file = CAMPAIGNS_DIR / f"{self.campaign_id}_confusion_matrices.json"
        self.manifest_file = CAMPAIGNS_DIR / f"{self.campaign_id}_manifest.json"

        # Initialize real providers
        self.registry = ProviderRegistry()
        self.registry.initialize_from_settings()
        self.provider_name = "minimax"
        self.model_name = "MiniMax-Text-01"

        # Evaluator components
        self.det_structure = QuestionStructureEvaluator()
        self.det_length = AnswerVerbatimAndLengthEvaluator()
        self.det_offsets = EvidenceOffsetEvaluator()
        self.det_duplicate = DuplicateAndShingleEvaluator()
        self.sem_grounding = GroundingFidelityEvaluator()
        self.sem_ambiguity = AmbiguityAndDistractorEvaluator()
        self.total_tokens_used = 0
        self.total_calls_made = 0
        self.deterministic_pipeline = [
            self.det_structure,
            self.det_length,
            self.det_offsets,
            self.det_duplicate,
            self.sem_grounding,
            self.sem_ambiguity,
        ]

        # Fidelity evaluator pipeline
        self.fidelity_pipeline = [self.sem_grounding]

        # Dynamically derive evaluator versions and pipeline hash from components
        self.evaluator_versions = {
            self.det_structure.__class__.__name__: self.det_structure.metadata.evaluator_version,
            self.det_length.__class__.__name__: self.det_length.metadata.evaluator_version,
            self.det_offsets.__class__.__name__: self.det_offsets.metadata.evaluator_version,
            self.det_duplicate.__class__.__name__: self.det_duplicate.metadata.evaluator_version,
            self.sem_grounding.__class__.__name__: self.sem_grounding.metadata.evaluator_version,
            self.sem_ambiguity.__class__.__name__: self.sem_ambiguity.metadata.evaluator_version,
            "NotGivenSemanticsEvaluator": NotGivenSemanticsEvaluator().metadata.evaluator_version,
        }
        self.evaluator_pipeline_hash = hashlib.sha256(
            json.dumps(self.evaluator_versions, sort_keys=True).encode("utf-8")
        ).hexdigest()[:16]
        # Load checkpoints if existing and not fresh
        self.completed_cases: Dict[str, Dict[str, Any]] = {}
        self.started_at: Optional[str] = None
        if not fresh and self.checkpoint_file.exists():
            try:
                with open(self.checkpoint_file, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    self.completed_cases = data.get("cases", {})
                    if not campaign_id and data.get("campaignId"):
                        self.campaign_id = data["campaignId"]
                    if data.get("startedAt"):
                        self.started_at = data["startedAt"]
                    print(f"[*] Reconciled {len(self.completed_cases)} existing cases from checkpoint {self.campaign_id}.")
            except Exception as e:
                print(f"[!] Warning loading checkpoint: {e}")
        elif fresh:
            print(f"[*] Fresh campaign requested; writing to new checkpoint: {self.checkpoint_file.name}")

    def save_checkpoint(self):
        with open(self.checkpoint_file, "w", encoding="utf-8") as f:
            json.dump(
                {
                    "campaignId": self.campaign_id,
                    "partition": self.partition,
                    "updatedAt": datetime.now(timezone.utc).isoformat(),
                    "totalCompleted": len(self.completed_cases),
                    "cases": self.completed_cases,
                },
                f,
                indent=2,
            )

    async def evaluate_single_question(
        self,
        case_id: str,
        q_type: str,
        is_valid: bool,
        q_data: Dict[str, Any],
        passage_text: str,
        sem: asyncio.Semaphore,
    ) -> Dict[str, Any]:
        input_hash = compute_question_input_hash(passage_text, q_type, q_data)
        if case_id in self.completed_cases:
            cached = self.completed_cases[case_id]
            if (
                cached.get("inputHash") == input_hash
                and cached.get("evaluatorPipelineHash") == self.evaluator_pipeline_hash
                and cached.get("modelUsed") == self.model_name
            ):
                return cached
            else:
                print(f"[*] Cache invalidated for {case_id} (input/version mismatch); re-evaluating...")
        async with sem:
            target_id = f"q_{case_id}"
            case_store = BenchmarkCheckpointClient()
            case_gateway = ProviderGateway(registry=self.registry, checkpoint_client=case_store)
            sem_not_given = NotGivenSemanticsEvaluator(gateway=case_gateway)
            sem_ambiguity = AmbiguityAndDistractorEvaluator(gateway=case_gateway)

            case_pipeline = [
                self.det_structure,
                self.det_length,
                self.det_offsets,
                self.det_duplicate,
                self.sem_grounding,
                sem_ambiguity,
                sem_not_given,
            ]
            ctx = make_bench_context(
                run_id=f"run_{self.campaign_id}_{case_id}",
                target_id=target_id,
                section_id=1,
            )

            payload = {
                "passage": passage_text,
                "questionNumber": q_data.get("number", 1),
                "questionType": q_type,
                "prompt": q_data.get("prompt"),
                "answer": q_data.get("answer"),
                "options": q_data.get("options", []),
                "evidenceQuote": q_data.get("evidenceQuote", ""),
                "evidenceStart": q_data.get("evidenceStart"),
                "evidenceEnd": q_data.get("evidenceEnd"),
            }
            art = ArtifactEnvelope.create(
                artifact_id=target_id,
                artifact_type=ArtifactType.QUESTION,
                version=1,
                payload=payload,
                run_id=f"run_{self.campaign_id}_{case_id}",
                producer_version="2.0.0",
            )
            all_issues: List[Issue] = []
            start_t = time.perf_counter()

            per_evaluator_results = {}
            for ev in case_pipeline:
                ev_start = time.perf_counter()
                try:
                    res = await ev.evaluate(ctx, art, intent_id=case_id)
                    all_issues.extend(res.issues)
                    per_evaluator_results[ev.evaluator_id] = {
                        "evaluatorVersion": ev.evaluator_version,
                        "status": res.status.value,
                        "score": res.score,
                        "durationSeconds": round(time.perf_counter() - ev_start, 3),
                        "issues": [
                            {
                                "code": i.code.value if hasattr(i.code, "value") else str(i.code),
                                "severity": i.severity.value if hasattr(i.severity, "value") else str(i.severity),
                                "scope": i.scope.value if hasattr(i.scope, "value") else str(i.scope),
                                "message": i.message,
                                "evidence": i.evidence,
                                "supportingRefs": [str(r) for r in i.affected_refs],
                            }
                            for i in res.issues
                        ],
                    }
                except Exception as ex:
                    all_issues.append(
                        Issue.create(
                            issue_id=f"iss_err_{uuid4().hex[:8]}",
                            code=IssueCode.EVALUATION_ERROR,
                            severity=IssueSeverity.CRITICAL,
                            scope="QUESTION",
                            message=f"Evaluator error: {str(ex)[:150]}",
                            affected_refs=[art.to_ref()],
                            evaluator_id=ev.evaluator_id,
                        )
                    )
                    per_evaluator_results[ev.evaluator_id] = {
                        "evaluatorVersion": ev.evaluator_version,
                        "status": "ERROR",
                        "score": 0.0,
                        "durationSeconds": round(time.perf_counter() - ev_start, 3),
                        "error": str(ex),
                        "issues": [{"code": "EVALUATION_ERROR", "message": str(ex)[:150]}],
                    }

            duration = time.perf_counter() - start_t
            blocking = any(i.severity == IssueSeverity.CRITICAL or i.blocking for i in all_issues)
            issue_codes = [i.code.value if hasattr(i.code, "value") else str(i.code) for i in all_issues]

            actual_provider = self.provider_name
            actual_model = self.model_name
            if case_gateway.last_response:
                actual_provider = case_gateway.last_response.provider_name
                actual_model = case_gateway.last_response.model_name

            record = {
                "caseId": case_id,
                "questionType": q_type,
                "groundTruthValid": is_valid,
                "goldRefs": {
                    "sourceFamily": q_data.get("source_family"),
                    "expectedIssueCode": q_data.get("issue_code", ""),
                    "expectedExplanation": q_data.get("explanation", ""),
                    "criticalCanary": bool(q_data.get("critical_canary", False)),
                },
                "inputPayload": {
                    "prompt": q_data.get("prompt"),
                    "answer": q_data.get("answer"),
                    "options": q_data.get("options", []),
                    "evidenceQuote": q_data.get("evidenceQuote", ""),
                    "inputHash": input_hash,
                },
                "expectedIssueCode": q_data.get("issue_code", ""),
                "isBlocking": blocking,
                "issueCodes": issue_codes,
                "perEvaluatorResults": per_evaluator_results,
                "durationSeconds": round(duration, 3),
                "callsUsed": case_store.run_used_calls,
                "tokensUsed": case_store.run_used_tokens,
                "inputHash": input_hash,
                "evaluatorPipelineHash": self.evaluator_pipeline_hash,
                "evaluatorVersions": self.evaluator_versions,
                "modelUsed": actual_model,
                "providerUsed": actual_provider,
                "lastRawProviderResponse": case_gateway.last_response.raw_text if case_gateway.last_response else None,
                "completionStatus": "COMPLETED",
                "timestamp": datetime.now(timezone.utc).isoformat(),
            }
            if case_store.run_used_calls > 0:
                # Pacing delay to avoid provider RPM rate limits
                await asyncio.sleep(1.2)
            self.total_tokens_used += case_store.run_used_tokens
            self.total_calls_made += case_store.run_used_calls
            self.completed_cases[case_id] = record
            self.save_checkpoint()
            return record

    async def run_questions_benchmark(self) -> Dict[str, Any]:
        corpus_file = (
            CORPUS_DIR / "questions_holdout_corpus.json"
            if self.partition == "holdout"
            else CORPUS_DIR / "questions_corpus.json"
        )
        with open(corpus_file, "r", encoding="utf-8") as f:
            q_corpus = json.load(f)

        passages = q_corpus.get("passages", {})
        sem = asyncio.Semaphore(self.concurrency)
        tasks = []

        print(f"[*] Dispatching question items for partition '{self.partition}' (concurrency={self.concurrency})...")
        for q_type, type_data in q_corpus.get("types", {}).items():
            for idx, q in enumerate(type_data.get("valid", [])):
                src_fam = q.get("source_family", "deep_sea_hydrothermal")
                p_text = passages.get(src_fam, "")
                case_id = f"q_valid_{q_type}_{idx+1}"
                tasks.append(self.evaluate_single_question(case_id, q_type, True, q, p_text, sem))

            for idx, q in enumerate(type_data.get("invalid", [])):
                src_fam = q.get("source_family", "deep_sea_hydrothermal")
                p_text = passages.get(src_fam, "")
                case_id = f"q_invalid_{q_type}_{idx+1}"
                tasks.append(self.evaluate_single_question(case_id, q_type, False, q, p_text, sem))

        results = await asyncio.gather(*tasks)
        print(f"[+] Finished {len(results)} question items.")
        return results

    async def run_fidelity_benchmark(self) -> Dict[str, Any]:
        fidelity_file = CORPUS_DIR / "fidelity_corpus.json"
        with open(fidelity_file, "r", encoding="utf-8") as f:
            f_corpus = json.load(f)

        cases = f_corpus.get("cases", [])
        print(f"[*] Evaluating {len(cases)} fidelity cases...")

        fidelity_results = []
        for c in cases:
            case_id = c.get("id")
            p_text = c.get("passage", "") or c.get("claim_text", "")
            s_text = c.get("sourceText", "") or c.get("source_text", "")
            c_list = c.get("claims", []) or [{"claim": c.get("claim_text", ""), "claim_text": c.get("claim_text", "")}]
            f_hash = compute_fidelity_input_hash(p_text, s_text, c_list)

            if case_id in self.completed_cases:
                cached = self.completed_cases[case_id]
                if (
                    cached.get("inputHash") == f_hash
                    and cached.get("evaluatorPipelineHash") == self.evaluator_pipeline_hash
                ):
                    fidelity_results.append(cached)
                    continue
                else:
                    print(f"[*] Cache invalidated for fidelity {case_id}; re-evaluating...")

            target_id = f"fid_{case_id}"
            ctx = make_bench_context(
                run_id=f"run_fid_{case_id}",
                target_id=target_id,
            )
            art = ArtifactEnvelope.create(
                artifact_id=target_id,
                artifact_type=ArtifactType.PASSAGE,
                version=1,
                payload={
                    "passage": p_text,
                    "sourceText": s_text,
                    "claims": c_list,
                },
                run_id=f"run_fid_{case_id}",
                producer_version="2.0.0",
            )
            res = await self.sem_grounding.evaluate(ctx, art, intent_id=case_id)
            blocking = any(i.severity == IssueSeverity.CRITICAL or i.blocking for i in res.issues)
            issue_codes = [i.code.value if hasattr(i.code, "value") else str(i.code) for i in res.issues]

            record = {
                "caseId": case_id,
                "groundTruthValid": c.get("valid", False),
                "isCriticalCanary": c.get("critical_canary", False),
                "goldRefs": {
                    "sourceFamily": c.get("source_family"),
                    "expectedIssueCode": c.get("issue_code"),
                    "explanation": c.get("explanation"),
                },
                "inputPayload": {
                    "claims": c_list,
                    "inputHash": f_hash,
                },
                "isBlocking": blocking,
                "issueCodes": issue_codes,
                "perEvaluatorResults": {
                    self.sem_grounding.evaluator_id: {
                        "evaluatorVersion": self.sem_grounding.evaluator_version,
                        "status": res.status.value,
                        "score": res.score,
                        "issues": [
                            {
                                "code": i.code.value if hasattr(i.code, "value") else str(i.code),
                                "message": i.message,
                                "supportingRefs": [str(r) for r in i.affected_refs],
                            }
                            for i in res.issues
                        ],
                    }
                },
                "expectedIssueCode": c.get("issue_code"),
                "inputHash": f_hash,
                "evaluatorPipelineHash": self.evaluator_pipeline_hash,
                "completionStatus": "COMPLETED",
                "timestamp": datetime.now(timezone.utc).isoformat(),
            }
            self.completed_cases[case_id] = record
            fidelity_results.append(record)
            self.save_checkpoint()
        print(f"[+] Finished {len(fidelity_results)} fidelity cases.")
        return fidelity_results

    async def run_critical_canaries_multi_run(self, repeats: int = 3) -> Dict[str, Any]:
        """Runs critical canary fixtures >= 3 times, recording aggregate and worst run."""
        fidelity_file = CORPUS_DIR / "fidelity_corpus.json"
        with open(fidelity_file, "r", encoding="utf-8") as f:
            f_corpus = json.load(f)

        canaries = [c for c in f_corpus.get("cases", []) if c.get("critical_canary", False)]
        print(f"[*] Executing {len(canaries)} critical canaries across {repeats} repetitions...")

        run_rejection_rates = []
        per_canary_rejections: Dict[str, int] = {c["id"]: 0 for c in canaries}

        for r_idx in range(repeats):
            rejections_this_run = 0
            for c in canaries:
                case_id = c["id"]
                canary_key = f"canary_r{r_idx}_{case_id}"
                if canary_key in self.completed_cases:
                    rec = self.completed_cases[canary_key]
                    if rec.get("isBlocking", False):
                        rejections_this_run += 1
                        per_canary_rejections[case_id] += 1
                    continue

                target_id = f"canary_r{r_idx}_{case_id}"
                ctx = make_bench_context(
                    run_id=f"run_canary_{r_idx}_{case_id}",
                    target_id=target_id,
                )
                art = ArtifactEnvelope.create(
                    artifact_id=target_id,
                    artifact_type=ArtifactType.PASSAGE,
                    version=1,
                    payload={
                        "passage": c.get("passage", ""),
                        "sourceText": c.get("sourceText", ""),
                        "claims": c.get("claims", []),
                    },
                    run_id=f"run_canary_{r_idx}_{case_id}",
                    producer_version="2.0.0",
                )
                res = await self.sem_grounding.evaluate(ctx, art, intent_id=f"canary_{r_idx}")
                blocking = any(i.severity == IssueSeverity.CRITICAL or i.blocking for i in res.issues)
                if blocking:
                    rejections_this_run += 1
                    per_canary_rejections[case_id] += 1

                rec = {
                    "caseId": canary_key,
                    "canaryId": case_id,
                    "repetition": r_idx,
                    "isCriticalCanary": True,
                    "isBlocking": blocking,
                    "issueCodes": [i.code.value for i in res.issues],
                    "timestamp": datetime.now(timezone.utc).isoformat(),
                }
                self.completed_cases[canary_key] = rec
                self.save_checkpoint()

            rate = rejections_this_run / len(canaries) if canaries else 1.0
            run_rejection_rates.append(rate)
            print(f"    - Run {r_idx+1}/{repeats}: Rejection Rate = {rate:.1%} ({rejections_this_run}/{len(canaries)})")
        aggregate_rate = sum(run_rejection_rates) / len(run_rejection_rates)
        worst_run_rate = min(run_rejection_rates)
        return {
            "repetitions": repeats,
            "totalCanaries": len(canaries),
            "runRates": run_rejection_rates,
            "aggregateRate": aggregate_rate,
            "worstRunRate": worst_run_rate,
            "allPass": worst_run_rate == 1.0,
        }

    async def run_full_campaign(self) -> Dict[str, Any]:
        start_time = datetime.fromisoformat(self.started_at) if self.started_at else datetime.now(timezone.utc)
        print(f"\n{'='*70}\nSTARTING G07 SEMANTIC BENCHMARK CAMPAIGN: {self.campaign_id}\nPartition: {self.partition}\n{'='*70}")
        q_results = await self.run_questions_benchmark()
        f_results = await self.run_fidelity_benchmark()
        canary_report = await self.run_critical_canaries_multi_run(repeats=3)

        # ── Compute Metrics via Canonical Metric Engine ──────────────────────
        q_records = {k: v for k, v in self.completed_cases.items() if k.startswith("q_")}
        canary_records = [v for k, v in self.completed_cases.items() if "canary" in k]

        calc_result = calculate_semantic_benchmark_metrics(
            records=q_records,
            campaign_id=self.campaign_id,
            partition=self.partition,
            canary_records=canary_records,
            canary_repetitions=canary_report["repetitions"],
        )

        overall_blocking_recall = calc_result.overall.recall
        false_rejection_rate = calc_result.overall.false_rejection_rate
        ambiguity_recall = calc_result.ambiguity.recall if calc_result.ambiguity.recall is not None else 0.0
        per_type_recall = {qt: cm.recall for qt, cm in calc_result.per_type.items()}

        # Derive startedAt, finishedAt, and durationSeconds dynamically from completed cases timestamps
        ts_list = [c["timestamp"] for c in self.completed_cases.values() if "timestamp" in c]
        if ts_list:
            started_time = datetime.fromisoformat(min(ts_list))
            finished_time = datetime.fromisoformat(max(ts_list))
        else:
            started_time = datetime.now(timezone.utc)
            finished_time = started_time
        duration_sec = max(0.1, (finished_time - started_time).total_seconds())

        confusion_matrices = calc_result.to_canonical_summary(
            started_at=started_time.isoformat(),
            finished_at=finished_time.isoformat(),
            duration_seconds=duration_sec,
            provider=self.provider_name,
            model=self.model_name,
            quarantined_notice=None,
            fidelity_results=f_results,
        )

        # 1. Write run-scoped immutable outputs
        with open(self.confusion_file, "w", encoding="utf-8") as f:
            json.dump(confusion_matrices, f, indent=2)
        print(f"\n[+] Wrote campaign confusion matrices: {self.confusion_file}")

        # 2. Export Failure Table for all FN/FP/wrong-family/operational errors under campaign ID
        failure_table = []
        for cid in calc_result.overall.fn_cases:
            rec = self.completed_cases.get(cid, {})
            failure_table.append({
                "caseId": cid,
                "failureType": "FALSE_NEGATIVE",
                "partition": self.partition,
                "questionType": rec.get("questionType", "Unknown"),
                "groundTruthValid": False,
                "expectedIssueCode": rec.get("expectedIssueCode"),
                "observedIssueCodes": rec.get("issueCodes", []),
                "isWrongFamily": cid in calc_result.overall.wrong_family_cases,
                "durationSeconds": rec.get("durationSeconds"),
                "modelUsed": rec.get("modelUsed"),
            })
        for cid in calc_result.overall.fp_cases:
            rec = self.completed_cases.get(cid, {})
            failure_table.append({
                "caseId": cid,
                "failureType": "FALSE_POSITIVE",
                "partition": self.partition,
                "questionType": rec.get("questionType", "Unknown"),
                "groundTruthValid": True,
                "expectedIssueCode": None,
                "observedIssueCodes": rec.get("issueCodes", []),
                "durationSeconds": rec.get("durationSeconds"),
                "modelUsed": rec.get("modelUsed"),
            })
        for cid in calc_result.overall.operational_error_cases:
            rec = self.completed_cases.get(cid, {})
            failure_table.append({
                "caseId": cid,
                "failureType": "OPERATIONAL_ERROR",
                "partition": self.partition,
                "questionType": rec.get("questionType", "Unknown"),
                "groundTruthValid": rec.get("groundTruthValid"),
                "expectedIssueCode": rec.get("expectedIssueCode"),
                "observedIssueCodes": rec.get("issueCodes", []),
                "durationSeconds": rec.get("durationSeconds"),
                "modelUsed": rec.get("modelUsed"),
            })

        failures_file = CAMPAIGNS_DIR / f"{self.campaign_id}_failures.json"
        with open(failures_file, "w", encoding="utf-8") as f:
            json.dump(failure_table, f, indent=2)
        # 3. Write raw results file with all cases
        full_results = {
            "campaignId": self.campaign_id,
            "partition": self.partition,
            "startedAt": started_time.isoformat(),
            "finishedAt": finished_time.isoformat(),
            "durationSeconds": round(duration_sec, 3),
            "questionsResults": q_results,
            "fidelityResults": f_results,
            "canaryReport": canary_report,
            "allCases": self.completed_cases,
        }
        with open(self.results_file, "w", encoding="utf-8") as f:
            json.dump(full_results, f, indent=2)
        print(f"[+] Wrote campaign raw results: {self.results_file}")



        # 3. Write campaign manifest
        manifest = {
            "campaignId": self.campaign_id,
            "partition": self.partition,
            "status": "PASS" if calc_result.acceptance.get("status") else "FAIL",
            "startedAt": started_time.isoformat(),
            "finishedAt": finished_time.isoformat(),
            "durationSeconds": round(duration_sec, 3),
            "provider": self.provider_name,
            "model": self.model_name,
            "evaluatorVersions": self.evaluator_versions,
            "evaluatorPipelineHash": self.evaluator_pipeline_hash,
            "corpusHashes": {
                "questions_corpus.json": compute_file_sha256(CORPUS_DIR / "questions_corpus.json"),
                "questions_holdout_corpus.json": compute_file_sha256(CORPUS_DIR / "questions_holdout_corpus.json"),
                "fidelity_corpus.json": compute_file_sha256(CORPUS_DIR / "fidelity_corpus.json"),
            },
            "rates": confusion_matrices["rates"],
            "acceptance": confusion_matrices["acceptanceStatus"],
            "totalFailuresLogged": len(failure_table),
        }
        with open(self.manifest_file, "w", encoding="utf-8") as f:
            json.dump(manifest, f, indent=2)
        print(f"[+] Wrote campaign manifest: {self.manifest_file}")
        # Summary output
        print(f"\n{'='*70}\nCAMPAIGN RESULTS SUMMARY:\n{'='*70}")
        print(f"Overall Blocking Recall:   {overall_blocking_recall:.1%} (Target >= 95.0%) -> {'PASS' if overall_blocking_recall >= 0.95 else 'FAIL'}")
        print(f"Per-Type Recall Minimum:   {min(per_type_recall.values()):.1%} (Target >= 90.0%) -> {'PASS' if all(r >= 0.90 for r in per_type_recall.values()) else 'FAIL'}")
        for qt, r in per_type_recall.items():
            print(f"  - {qt:25}: {r:.1%}")
        print(f"Ambiguity Recall:          {ambiguity_recall:.1%} (Target >= 90.0%) -> {'PASS' if ambiguity_recall >= 0.90 else 'FAIL'}")
        print(f"False Rejection Rate:      {false_rejection_rate:.1%} (Target <= 10.0%) -> {'PASS' if false_rejection_rate <= 0.10 else 'FAIL'}")
        print(f"Critical Canaries (Worst): {canary_report['worstRunRate']:.1%} (Target == 100.0%) -> {'PASS' if canary_report['worstRunRate'] == 1.0 else 'FAIL'}")
        print(f"Overall Campaign Status:   {manifest['status']}")
        print(f"{'='*70}\n")

        return confusion_matrices


def main():
    parser = argparse.ArgumentParser(description="Phase 07 Semantic Benchmark Runner")
    parser.add_argument("--partition", choices=["dev", "holdout"], default="holdout", help="Partition to benchmark")
    parser.add_argument("--concurrency", type=int, default=2, help="Concurrency limit for live API calls")
    parser.add_argument("--fresh", action="store_true", help="Start fresh campaign with a unique campaign ID without modifying existing checkpoints")
    parser.add_argument("--campaign-id", type=str, default=None, help="Explicit campaign ID to resume or assign")
    parser.add_argument("--checkpoint-file", type=str, default=None, help="Explicit path to checkpoint file to resume")
    args = parser.parse_args()

    cp_path = Path(args.checkpoint_file) if args.checkpoint_file else None
    runner = SemanticBenchmarkRunner(
        partition=args.partition,
        concurrency=args.concurrency,
        campaign_id=args.campaign_id,
        fresh=args.fresh,
        checkpoint_file=cp_path,
    )
    asyncio.run(runner.run_full_campaign())
if __name__ == "__main__":
    main()
