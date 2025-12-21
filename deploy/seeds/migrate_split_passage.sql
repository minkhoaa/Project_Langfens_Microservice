-- Migration: Split PassageMd from InstructionsMd
-- This script extracts passage paragraphs (starting with **Paragraph A.**)
-- from InstructionsMd and moves them to the new PassageMd column.

-- Pattern: Everything from "**Paragraph A.**" onwards goes to PassageMd
-- Everything before "**Paragraph A.**" stays in InstructionsMd

-- Step 1: Update PassageMd with passage content (from **Paragraph A.** onwards)
UPDATE exam_sections
SET "PassageMd" = (
    CASE 
        WHEN "InstructionsMd" LIKE '%**Paragraph A.**%' THEN
            SUBSTRING("InstructionsMd" FROM POSITION('**Paragraph A.**' IN "InstructionsMd"))
        WHEN "InstructionsMd" LIKE '%Paragraph A.%' THEN
            SUBSTRING("InstructionsMd" FROM POSITION('Paragraph A.' IN "InstructionsMd"))
        WHEN "InstructionsMd" LIKE '%# Passage%' THEN
            SUBSTRING("InstructionsMd" FROM POSITION('# Passage' IN "InstructionsMd"))
        ELSE NULL
    END
)
WHERE "PassageMd" IS NULL 
  AND ("InstructionsMd" LIKE '%**Paragraph A.**%'
       OR "InstructionsMd" LIKE '%Paragraph A.%'
       OR "InstructionsMd" LIKE '%# Passage%');

-- Step 2: Update InstructionsMd to remove passage content
UPDATE exam_sections
SET "InstructionsMd" = (
    CASE 
        WHEN "InstructionsMd" LIKE '%**Paragraph A.**%' THEN
            TRIM(BOTH FROM SUBSTRING("InstructionsMd" FROM 1 FOR POSITION('**Paragraph A.**' IN "InstructionsMd") - 1))
        WHEN "InstructionsMd" LIKE '%Paragraph A.%' THEN
            TRIM(BOTH FROM SUBSTRING("InstructionsMd" FROM 1 FOR POSITION('Paragraph A.' IN "InstructionsMd") - 1))
        WHEN "InstructionsMd" LIKE '%# Passage%' THEN
            TRIM(BOTH FROM SUBSTRING("InstructionsMd" FROM 1 FOR POSITION('# Passage' IN "InstructionsMd") - 1))
        ELSE "InstructionsMd"
    END
)
WHERE "PassageMd" IS NOT NULL;

-- Verify the split
SELECT 
    "Id",
    "Title",
    LEFT("InstructionsMd", 100) as "instructions_preview",
    LEFT("PassageMd", 100) as "passage_preview"
FROM exam_sections
WHERE "PassageMd" IS NOT NULL
LIMIT 5;
