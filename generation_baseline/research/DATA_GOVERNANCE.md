# Dataset/gold/provenance access contract

Four disjoint use-categories: DEV (generator development), CALIBRATION (judge tuning), JUDGE_HOLDOUT (frozen judge audit) and FINAL_EVAL (RQ2), with source-family and near-duplicate checks as necessary. Published educational materials must be licensed/eligible. Annotators label at question level and record ambiguity, valid variants, source spans, source version, adjudication rationale and reviewer independence; absence of evidence must not be misclassified as a gold NOT GIVEN without relevant context audit.

Gold labels and assignment→arm mapping are restricted; blind reviewers see neutral outputs in randomized order. Reviewers may see allowed source/passage needed to assess groundedness, but never arm labels or internal self-scores. Store consent and access restrictions for learners; product attempts are not automatically added to research gold. De-identify examples and remove secrets/private provider payload from export.

Mutation to frozen final dataset or labels requires new version and explicit audit trail; never silently patch a failed/failing benchmark example. License or privacy failures prevent source use; log only safe hashes and redacted pointers when raw payload contains personal data.
