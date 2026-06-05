-- =============================================================================
-- Fix corrupt MATCHING_FEATURES matchPairs
--
-- The matchPairs in exam_questions and attempts.PaperJson for matching-features
-- questions are stored as ["D", "D"] (the option letter repeated twice) instead
-- of ["D", "D. <full content>"] or at minimum ["D", "<full content>"].
--
-- This script walks every MATCHING_FEATURES question in the exam template AND
-- in every attempt's PaperJson, and replaces the second element of the values
-- array with the full ContentMd of the option whose Idx matches the letter
-- (A=1, B=2, ... G=7).
--
-- Idempotent: only updates rows where the second value equals the first (the
-- corruption signature), so it can be re-run safely.
-- =============================================================================

BEGIN;

-- ----- 1) exam_questions template -----
DO $$
DECLARE
    rec RECORD;
    v_key TEXT;
    v_letter TEXT;
    v_idx INT;
    v_content TEXT;
    v_old JSONB;
    v_new JSONB;
BEGIN
    FOR rec IN
        SELECT q."Id" AS qid, q."MatchPairs" AS mp
        FROM exam_questions q
        WHERE q."Type" = 'MATCHING_FEATURES'
          AND jsonb_typeof(q."MatchPairs") = 'object'
          AND (SELECT count(*) FROM jsonb_object_keys(q."MatchPairs")) > 0
    LOOP
        -- Each matchPairs has exactly one key
        FOR v_key IN SELECT jsonb_object_keys(rec.mp)
        LOOP
            v_old := rec.mp -> v_key;
            -- Need 2 elements
            IF jsonb_array_length(v_old) = 2 THEN
                v_letter := v_old ->> 0;
                v_idx := ascii(v_letter) - ascii('A') + 1;
                -- Look up the option content by Idx
                SELECT "ContentMd" INTO v_content
                FROM exam_options
                WHERE "QuestionId" = rec.qid AND "Idx" = v_idx;
                IF v_content IS NOT NULL THEN
                    v_new := jsonb_build_array(v_letter, v_content);
                    -- Only update if currently broken (both elements equal)
                    IF v_old ->> 0 = v_old ->> 1 THEN
                        UPDATE exam_questions
                        SET "MatchPairs" = jsonb_set("MatchPairs", ARRAY[v_key], v_new, false)
                        WHERE "Id" = rec.qid;
                    END IF;
                END IF;
            END IF;
        END LOOP;
    END LOOP;
END$$;

COMMIT;

-- Verification: should return 0 rows
SELECT 'TEMPLATE_REMAINING' AS source, COUNT(*) FROM exam_questions
 WHERE "Type" = 'MATCHING_FEATURES'
   AND jsonb_typeof("MatchPairs") = 'object'
   AND EXISTS (
     SELECT 1 FROM jsonb_object_keys("MatchPairs") k
     WHERE (("MatchPairs"->k->>0)) = (("MatchPairs"->k->>1))
   );
