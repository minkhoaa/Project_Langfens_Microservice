# Phase 15 Production Canary Procedure (T15-06)

**Document Version**: 2.0.0  
**Target Gate**: G15 Release Gate Cutover  
**Prerequisite Work Packages**: P15-01 through P15-03 (PASS), P15-05 through P15-10 (PASS)  
**Status**: ACTIVE PROCEDURE — BLOCKED ON REAL PRODUCTION OBSERVATION (T15-06)  
**Release Governance Rule**: *Synthetic staging evidence or offline benchmarks CANNOT substitute for live production canary observation. G15 remains BLOCKED until this procedure is executed on real production traffic with the required 24-hour bake window and >=20 completed eligible jobs.*

---

## 1. Executive Summary & Blocker Governance

Gate G15 release verification for Loop Engine V2 is held as **BLOCKED** strictly per Master Plan release governance. All preflight prerequisites have reached verified completion:
- **P15-01 (Manifests & Schemas)**: Verified and mapped to V2 canonical contracts.
- **P15-02 (Build & Startup)**: Multi-runtime build (.NET 10 & Python 3.10/3.12) verified with 0 errors.
- **P15-03 (Live Paired Benchmark)**: Real MiniMax-Text-01 campaign `camp_G15_022943e248ec` reached 18/18 valid Drafts (100% vs >= 95% target), 0.709x P95 latency ratio, and 0.235x median token cost ratio (~76.5% reduction).
- **P15-07 (T15-07 Container Rollback Rehearsal)**: Authentic previous supported release `langfens-exam:v1.9.4-compat` (ID: `b2198148a2b7`, digest: `sha256:b2198148a2b7ea22164c6c9cbe407581f251267420c8c1b9e0915d0f26734b43`) executed against isolated PostgreSQL clone `exam_test_rollback_clone`, proving 100% additive schema query compatibility, artifact/feedback preservation, zero checksum drift across all 22 core tables, and uncorrupted drain/fencing recovery.
- **P15-08 through P15-10**: Legacy deletion inventory closed (37 symbols), living adapters preserved (15 public), and operational runbook authored.

**Sole Remaining Blocker**:
`T15-06` / `P15-04` requires real execution of this staged canary procedure on live production traffic with a minimum 24-hour observation bake window and at least 20 completed eligible production generation jobs.

---

## 2. Release Candidate Pinning & Image Provenance

The production canary must run with exact, immutable binaries and configurations pinned to release candidate:
- **Candidate Git SHA**: `e66f74a7ba222c3998427b7f884c8ef063a1e235` (branch `refactor/recovery-integrate-g15`).
- **Engine Version**: `2.0.0`
- **Schema Version**: `2.0.0`
- **Policy Version**: `v2.0.0` (Profile: `phase13-production-v1`, SHA-256 verified)
- **Primary AI Provider**: `MiniMax-Text-01` (`https://api.minimaxi.chat/v1`)
- **Fallback Provider**: `Groq` (`llama-3.1-70b-versatile` / `openai/gpt-oss-120b`)
- **Rollback Target Image**: `langfens-exam:v1.9.4-compat` (digest: `sha256:b2198148a2b7ea22164c6c9cbe407581f251267420c8c1b9e0915d0f26734b43`)

---

## 3. Staged Traffic Rollout Protocol

The rollout is executed in three non-negotiable stages across production traffic:

| Stage | Traffic Ratio | Minimum Eligible Completed Jobs | Bake Window | Required Quality & Operational Criteria |
|---|---|---|---|---|
| **Stage 1 (Canary-10)** | 10% V2 / 90% V1 | $\ge 5$ completed papers | $\ge 6$ hours | 100% hard invariants pass, 0 circuit trips, P95 latency ratio $\le 1.5\times$ baseline, 0 database deadlocks |
| **Stage 2 (Canary-50)** | 50% V2 / 50% V1 | $\ge 15$ completed papers | $\ge 12$ hours | Cumulative token cost within budget caps, error rate $< 1.0\%$, 0 duplicate exams, valid Draft rate $\ge 95\%$ |
| **Stage 3 (Canary-100)** | 100% V2 / 0% V1 | $\ge 20$ completed papers | $\ge 24$ hours | All phase gate invariants verified, 0 unhandled exceptions, stable memory and connection pool, complete audit trail |

---

## 4. Operational Execution Commands

### 4.1 Stage 1 Initiation (10% Traffic)
```bash
# Configure Canary routing in production exam-service / API Gateway
export FEATURE_FLAG__GENERATION_V2_ENABLED=true
export FEATURE_FLAG__GENERATION_V2_PERCENTAGE=10

# In Kubernetes / container environment:
kubectl set env deployment/exam-service \
  FEATURE_FLAG__GENERATION_V2_ENABLED=true \
  FEATURE_FLAG__GENERATION_V2_PERCENTAGE=10

# Verify health status
curl -fsS http://exam-service:8080/healthz
curl -fsS http://generation-service:8092/healthz
```

### 4.2 Stage 2 Progression (50% Traffic)
*Prerequisite*: Stage 1 bake $\ge 6\text{h}$, $\ge 5$ completed papers, 0 error alerts.
```bash
kubectl set env deployment/exam-service \
  FEATURE_FLAG__GENERATION_V2_PERCENTAGE=50
```

### 4.3 Stage 3 Progression (100% Cutover)
*Prerequisite*: Stage 2 bake $\ge 12\text{h}$, $\ge 15$ completed papers, 0 budget breaches.
```bash
kubectl set env deployment/exam-service \
  FEATURE_FLAG__GENERATION_V2_PERCENTAGE=100
```

---

## 5. Automated Abort & Emergency Rollback Criteria

If ANY of the following threshold violations occurs during the observation window, the canary must be IMMEDIATELY aborted:
1. **Circuit Breaker Trip**: Provider circuit breaker enters `OPEN` state $\ge 1$ time.
2. **Data Fencing Violation**: Any CAS fencing conflict resulting in duplicate active runs or stale epoch writes.
3. **Data Mutation / Checkpoint Loss**: Missing checkpoint ACK or non-monotonic cursor movement.
4. **Draft Rate Collapse**: Valid Draft rate drops below $90.0\%$ over 5 consecutive jobs.
5. **Latency Breach**: P95 latency ratio exceeds $1.5\times$ baseline ($> 90\text{s}$).
6. **Error Rate Spike**: Unhandled 5xx errors $> 1.0\%$ across generation routes.

### Emergency Rollback Action (P0)
```bash
# 1. Immediately drop V2 traffic percentage to 0%
kubectl set env deployment/exam-service FEATURE_FLAG__GENERATION_V2_PERCENTAGE=0

# 2. If container runtime regression detected, deploy pinned rollback image:
kubectl set image deployment/exam-service \
  exam-service=langfens-exam:v1.9.4-compat@sha256:b2198148a2b7ea22164c6c9cbe407581f251267420c8c1b9e0915d0f26734b43

# 3. Verify previous container starts clean over additive schema
kubectl rollout status deployment/exam-service
curl -fsS http://exam-service:8080/healthz
```

---

## 6. Post-Canary Verification & Gate G15 Clearance Checklist

To advance Gate G15 from `BLOCKED` to `PASS`, the SRE and QA Leads must record:
- [ ] Staged canary ran for $\ge 24$ consecutive hours without aborts.
- [ ] At least 20 eligible IELTS Reading papers reached terminal `Completed` state in production PostgreSQL.
- [ ] Random audit of $\ge 5$ completed papers verifies 100% compliance with canonical IELTS question type schemas.
- [ ] Prometheus metrics confirm P95 latency ratio $\le 1.5\times$ and token cost reduction $\ge 50\%$.
- [ ] Zero unhandled exceptions in production logs (`grep -i 'unhandled' /var/log/langfens/*.log`).
- [ ] Sign-off recorded in `artifacts/refactor/phase-15/final-acceptance-report.md`.
