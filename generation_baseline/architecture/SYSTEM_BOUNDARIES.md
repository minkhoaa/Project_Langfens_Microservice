# System topology, authority and trust boundaries

```text
Admin/Student Next.js UI
        │ public AuthN/AuthZ via Gateway
.NET Gateway/API → .NET Exam Service/Worker ↔ PostgreSQL authoritative state
                         │ authenticated internal checkpoint APIs
                  Python FastAPI Generation Service
                         │ provider adapter/model pinning
                    LLM Provider (historically MiniMax)
                         └→ source/KB retrieval adapter (vector backend not assumed)

Separate: Research A/B/C runner → neutral outputs → sealed Independent Evaluator
                                                    ↘ human blind review / metrics
```

- Production Draft, PublishedSnapshot, grader, StudentAttempt, learner history owned by authenticated backend boundaries.
- Source and retrieved grammar rules are **untrusted inputs**, even with provenance; reject SSRF, unsafe URLs, wrong license/tenant and prompt instructions masquerading as policy.
- Candidate content is untrusted until required semantic and deterministic checks pass. Keep raw provider payload/credentials out of student/solver/reviewer views.
- DB authority for accepted heads and checkpoint fencing is not delegated to Python loops or LLM agents.
- Existing stack is a **historical reported architecture**. RG01 must identify actual ports, routes, modules and deployed topologies by reading code; do not assume Python writes directly to PostgreSQL.
