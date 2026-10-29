# Passive synthetic v1 test vectors

- `canonical-questions.v1.json`: 19 private authoring shape fixtures, one per registry type.
- `grading-cases.v1.json`: 82 correct, incorrect, empty, cleared and partial answer cases; `expected` is the original fixture's intended grading result, **not a new actual-.NET result**. Each case contains its private Question and wire-shaped answer.

The JSON files are self-contained; no Reading implementation is needed to read them. Question and option IDs are synthetic UUIDs; section/group identities and media paths are placeholders, not persisted or authorized assets.

The schema at `../question-types.v1.schema.json` is the only authority. These fixtures exercise structural shapes and grading inputs, not every normative semantic requirement. They are not publishable IELTS content, student bundles, consumer compatibility evidence or full renderer/ingestion/semantic tests. Never expose private Questions or answer-bearing cases to a blind solver.

Actual-.NET grading verification requires separately scoped offline consumer tests against the production graders. These vectors alone do not establish grading parity or justify changes to backend contracts.
