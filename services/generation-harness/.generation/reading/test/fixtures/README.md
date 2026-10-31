# Offline stabilization replays

No provider access, database or external credentials. These are private generated test papers, not approved IELTS content.

- `pilot-r5.json`: byte-identical final `workspace/run-01/exam.json` from parent session `2026-10-31T06-56-24-810Z_01a190be-c8ea-7626-88a7-24e2ca2dd610.jsonl`. SHA-256 `a5b092d9219a5a43d922b087bb0cca8036f4ad4c2278d54cbd17d2d1bd94e5f3`. Mechanical 13 Question/slot/scoring-unit coverage only; independent review quality and runtime grading are NOT certified. In particular, q07's most/every inference remains disputed.
- `export-without-passage.json`: byte-identical earlier `workspace/exam-rewetting-the-north.json`, SHA-256 `4dcfb571fc0364ac96753e30864890170316bd6f47de62a3149036110b4491e9`. Ordinary canonical hierarchy accepts this companion-dependent export; pilot validation must reject its missing embedded passage.
- `pilot-r2-scoring-reconstruction.json`: replay of the retained `run-01/build_exam.py`, inspected before execution in a selected disposable temp directory with r5 as metadata/passage scaffold; `complete` explicitly set true for final validation. This reconstructs the recorded r2 scoring failure (four two-target matching Questions plus a two-selection Question: 18 slots/13 units), NOT a byte-identical historical r2 snapshot. The original mutable r2 Exam and backup were not retained. The test never executes historical scripts.

- `rejected-evidence.jsonl`: one actual assistant tool-call record (content narrowed to that call) and matching native rejection at `07:41:22.513Z` from r5 semantic child `2c02a536-de20-4dbc-8405-bb2525e43efd`; offsets are strings. Timestamps and call ID are retained for trace correlation.
- `pilot-spans.json`: r5 saved evidence's numeric UTF-16 spans only; author commentary/absence assertions removed. 16 exact spans cover 13 Questions (including context, not proof of NOT GIVEN). This is a mechanical replay, not independent semantic evidence.

Fixtures deliberately retain original defects and keys. Do not silently regenerate, repair or present them as quality-approved artifacts.
