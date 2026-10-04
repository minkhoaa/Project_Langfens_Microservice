# ADR-002: Fencing Tokens, Epoch Numbers, and Checkpoint Acknowledgement

**Status:** Accepted  
**Date:** 2026-09-30  
**Phase:** Phase 01  
**Deciders:** Langfens Engineering Team  

---

## 1. Context

Generation jobs in Langfens are long-running operations (spanning multiple minutes across 3 reading sections). `ReadingPaperWorker` operates under a distributed lease mechanism (3-minute lease, 30-second heartbeat renewal).

In distributed systems, worker processes can experience garbage collection pauses, network partitions, or temporary CPU stalls. If a worker process pauses and its lease expires, a second worker may claim the job and increment generation progress. When the stalled worker resumes (becoming a "zombie worker"), any uncoordinated write back to storage would overwrite newer progress or corrupt state (split-brain anomaly).

## 2. Decision

We enforce fencing tokens, monotonic epochs, and explicit checkpoint acknowledgements:

1. **Monotonically Increasing Epochs:**
   - Every `reading_paper_jobs` row possesses an `Epoch` integer column (starting at 1).
   - Whenever a worker claims a pending job or reclaims an expired lease, the database transaction increments `Epoch = Epoch + 1` and updates `LeaseOwner`.
   - The active `(RunId, Epoch, LeaseOwner)` tuple forms the immutable `RunIdentity` passed to `generation-service`.

2. **Fenced Checkpoint API Requests:**
   - Every checkpoint write call sent from `generation-service` to `exam-service` must include the `RunId`, `Epoch`, and `LeaseOwner`.
   - `exam-service` validates the incoming epoch inside a serializable/optimistic concurrency transaction:
     ```sql
     UPDATE reading_paper_jobs 
     SET completed_sections = @completedSections, sections_json = @sectionsJson
     WHERE id = @jobId AND epoch = @epoch AND lease_owner = @leaseOwner;
     ```
   - If the database returns 0 affected rows (indicating a stale epoch or changed lease owner), `exam-service` immediately rejects the write with **HTTP 409 Conflict**.
   - Upon receiving HTTP 409 Conflict, `generation-service` immediately aborts the active loop, cleans up resources, and logs `STALE_DEPENDENCY`.

3. **Explicit Synchronous Acknowledgement (Ack):**
   - Checkpoint commits must be synchronously acknowledged by `exam-service`.
   - The acknowledgement response includes the committed `ArtifactRef`, `Epoch`, and server timestamp.
   - The generation runtime cannot advance to the next section or transition to `COMPLETED` until it has received a valid `CheckpointAck` for the current section.

## 3. Consequences

### Positive:
- **Zero Split-Brain Commits:** Stale or delayed workers cannot overwrite data committed by a newer active lease owner.
- **Fail-Fast Semantics:** Zombie workers abort immediately without burning unnecessary LLM tokens.
- **Auditable Linear History:** Every checkpoint transaction is tied to a specific epoch.

### Negative / Trade-offs:
- Checkpoints require synchronous coordination; the generation runtime cannot buffer writes asynchronously without awaiting acknowledgement.
- Clock drift or network jitter between heartbeat cycles must be accounted for by keeping the heartbeat interval (30s) significantly shorter than the lease duration (3m).
