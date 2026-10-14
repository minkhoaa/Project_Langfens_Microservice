# Historical inputs — context only, not current-source facts

## User-approved KLTN outline (2026)

Vietnamese title: **Phát triển hệ thống học tiếng Anh tích hợp trợ lý AI hội thoại và tự động tạo nội dung bằng đa tác nhân**. English title: **Developing an English Learning System Integrated with Conversational AI Assistant and Multi-Agent Automated Test Generation**. No title change is permitted by this baseline.

Section 2.2.e and method 4.e promise a multi-agent system that generates and verifies English exercises with bounded review/repair, anchored in representative passage-based Reading and grammar exercises with reference answers. RQ2 calls for comparison A direct LLM vs B same-model sequential self-review vs C proposed multi-agent, quality and costs; methods 4.g propose 25–40 benchmark tasks per domain plus independent, partially blind human review. Product objective 2.2.f includes history and learning progress. Speaking/acoustic pronunciation is RQ1, not implicitly part of this extension.

## Reading V2 handoff, reported only

Production-like architecture: admin portal / gateway / .NET exam-service/PostgreSQL / Python FastAPI generation-service / provider model. Handoff names `MiniMax-Text-01`, approved runtime profile `phase13-production-v1`, Historical content measured code HEAD `aa1a1b234eca8473056513b4977a9f5abfcb989f`, acceptance-documentation commit `b69d34d2a4cc9d646c2c150461e66f7d9f9c20d6`. Neither hash proves the new repository HEAD. Historical three full Reading jobs are reported persisted, 120/120 questions semantic PASS and frontend rendered Q1–Q40; raw audit independent reinspection not performed here. Operational production canary / full rollback remain UNVERIFIED. The history mentions bounded repair limits `3/3/2/5`, whose exact runtime owners/meaning must be checked in RG01.

System hazards from earlier debugging include stale accepted heads, hash divergence Python/.NET, inadequate JSON DTO recovery, answer/word-limit enum casing mismatches, invalid repair closure, unpinned MiniMax fallback, lost cumulative cap policy, nondeterministic retry IDs, legacy synchronization on title not source identity and false verbatim matching. They become regression hypotheses, not claims newly tested on the current baseline.

The historical handoff originally requested documentation cleanup as a separate context-specific task. **No cleanup, branch/commit mutation or production operation is authorized by this research baseline.**
