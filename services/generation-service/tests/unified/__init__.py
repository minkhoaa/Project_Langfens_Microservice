"""Mock E2E acceptance fixtures and tests for the unified Reading generation rebuild.

This package owns the EXCLUSIVE mock E2E lane:
- An authoritative in-process HTTP mock of the .NET CheckpointService.
- A deterministic physical provider adapter that emits recorded responses
  keyed by the explicit READING_TASK prompt stage (NOT echoed from a hidden
  fixture into the consumer tests).
- Pytest cases exercising the REAL ``ReadingGenerationPipeline``,
  ``SectionRunner``, ``StageExecutor`` and ``ProviderGateway``.

Nothing in ``app/`` is edited by this lane. The parent integration owner
selects which checkpoint/commit/import endpoints run on which uri.
"""
