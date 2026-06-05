-- =============================================================================
-- Fix corrupt MATCHING_FEATURES matchPairs in attempts.PaperJson
--
-- Walks every attempt's sections.questionGroups.questions and replaces the
-- second element of the values array with the full ContentMd of the option
-- whose Idx matches the letter (A=1, B=2, ... G=7).
--
-- Run on attempt-db (port 5435), NOT exam-db.
-- =============================================================================

BEGIN;

DO $$
DECLARE
    attempt_rec RECORD;
    q_node JSONB;
    q_type TEXT;
    q_id TEXT;
    q_mp JSONB;
    v_letter TEXT;
    v_idx INT;
    v_content TEXT;
    v_new JSONB;
    patched BOOLEAN;
    new_sections JSONB;
    sec_node JSONB;
    grp_node JSONB;
    new_groups JSONB;
    new_questions JSONB;
BEGIN
    FOR attempt_rec IN SELECT "Id", "PaperJson" FROM attempts WHERE "PaperJson" IS NOT NULL
    LOOP
        patched := false;
        new_sections := '[]'::jsonb;

        FOR sec_node IN SELECT * FROM jsonb_array_elements(attempt_rec."PaperJson"->'sections')
        LOOP
            new_groups := '[]'::jsonb;
            FOR grp_node IN SELECT * FROM jsonb_array_elements(sec_node->'questionGroups')
            LOOP
                new_questions := '[]'::jsonb;
                FOR q_node IN SELECT * FROM jsonb_array_elements(grp_node->'questions')
                LOOP
                    q_type := upper(coalesce(q_node->>'type', q_node->>'questionType', ''));
                    q_mp := q_node->'matchPairs';
                    IF q_type = 'MATCHING_FEATURES' AND q_mp IS NOT NULL AND jsonb_typeof(q_mp) = 'array' THEN
                        -- Stored shape: [{promptKey, acceptedValues:[l,c]}]
                        IF jsonb_array_length(q_mp) = 1 AND (q_mp->0->'acceptedValues') IS NOT NULL
                           AND jsonb_array_length(q_mp->0->'acceptedValues') = 2
                           AND (q_mp->0->'acceptedValues'->>0) = (q_mp->0->'acceptedValues'->>1) THEN
                            v_letter := q_mp->0->'acceptedValues'->>0;
                            v_idx := ascii(v_letter) - ascii('A') + 1;
                            v_content := NULL;
                            -- Look up the option content from the question's own options array
                            SELECT o->>'contentMd' INTO v_content
                            FROM jsonb_array_elements(q_node->'options') o
                            WHERE (o->>'idx')::int = v_idx
                            LIMIT 1;
                            IF v_content IS NOT NULL THEN
                                v_new := jsonb_build_array(v_letter, v_content);
                                q_node := jsonb_set(
                                    q_node,
                                    '{matchPairs,0,acceptedValues}',
                                    v_new,
                                    false
                                );
                                patched := true;
                            END IF;
                        END IF;
                    END IF;
                    new_questions := new_questions || jsonb_build_array(q_node);
                END LOOP;
                grp_node := jsonb_set(grp_node, '{questions}', new_questions, false);
                new_groups := new_groups || jsonb_build_array(grp_node);
            END LOOP;
            sec_node := jsonb_set(sec_node, '{questionGroups}', new_groups, false);
            new_sections := new_sections || jsonb_build_array(sec_node);
        END LOOP;

        IF patched THEN
            UPDATE attempts
            SET "PaperJson" = jsonb_set("PaperJson", '{sections}', new_sections, false)
            WHERE "Id" = attempt_rec."Id";
        END IF;
    END LOOP;
END$$;

COMMIT;

-- Verification: should return 0 rows
SELECT 'ATTEMPT_REMAINING' AS source, COUNT(*) FROM attempts a,
    jsonb_array_elements("PaperJson"->'sections') sec,
    jsonb_array_elements(sec->'questionGroups') grp,
    jsonb_array_elements(grp->'questions') q
 WHERE q->>'type' = 'MATCHING_FEATURES'
   AND (q->'matchPairs'->0->'acceptedValues'->>0) = (q->'matchPairs'->0->'acceptedValues'->>1);
