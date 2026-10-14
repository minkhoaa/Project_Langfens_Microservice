# Required fields for source-to-contract audit record

`requirement_id,phase_id,capability,repository_relative_path,line_or_symbol,service_owner,observed_status,observed_behavior,code_commit_sha,tests_and_results,config_or_schema_refs,contract_delta,disposition,confidence,notes`.

Observed status ∈ `VERIFIED`, `PARTIAL`, `MISSING`, `UNKNOWN`, `CONFLICT`. `MISSING` requires credible scoped source search, not a single absent filename. Current code paths are unknown to this target design; do not fabricate paths to fill the matrix.
