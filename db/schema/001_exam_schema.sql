CREATE TABLE IF NOT EXISTS "__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL,
    CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId")
);

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251223074931_AddModelAnswersToExamQuestion') THEN
    ALTER TABLE exam_questions ADD "ModelAnswers" jsonb;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251223074931_AddModelAnswersToExamQuestion') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20251223074931_AddModelAnswersToExamQuestion', '10.0.7');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251223075428_SyncModelAnswers') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20251223075428_SyncModelAnswers', '10.0.7');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251224070546_AddQuestionGroup') THEN
    ALTER TABLE exam_questions ADD "GroupId" uuid;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251224070546_AddQuestionGroup') THEN
    CREATE TABLE exam_question_groups (
        "Id" uuid NOT NULL,
        "SectionId" uuid NOT NULL,
        "Idx" integer NOT NULL,
        "StartIdx" integer NOT NULL,
        "EndIdx" integer NOT NULL,
        "InstructionMd" text NOT NULL,
        CONSTRAINT "PK_exam_question_groups" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_exam_question_groups_exam_sections_SectionId" FOREIGN KEY ("SectionId") REFERENCES exam_sections ("Id") ON DELETE CASCADE
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251224070546_AddQuestionGroup') THEN
    CREATE INDEX "IX_exam_questions_GroupId" ON exam_questions ("GroupId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251224070546_AddQuestionGroup') THEN
    CREATE INDEX "IX_exam_question_groups_SectionId_Idx" ON exam_question_groups ("SectionId", "Idx");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251224070546_AddQuestionGroup') THEN
    ALTER TABLE exam_questions ADD CONSTRAINT "FK_exam_questions_exam_question_groups_GroupId" FOREIGN KEY ("GroupId") REFERENCES exam_question_groups ("Id") ON DELETE SET NULL;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251224070546_AddQuestionGroup') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20251224070546_AddQuestionGroup', '10.0.7');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251224070940_addquestiongroupLatest') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20251224070940_addquestiongroupLatest', '10.0.7');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260521173406_Init') THEN
    CREATE TABLE exams (
        "Id" uuid NOT NULL,
        "Slug" text NOT NULL,
        "Title" text NOT NULL,
        "DescriptionMd" text,
        "Category" text NOT NULL,
        "Level" text NOT NULL,
        "Status" text NOT NULL,
        "DurationMin" integer NOT NULL,
        "ImageUrl" text,
        "CreatedAt" timestamp with time zone NOT NULL DEFAULT (now()),
        "UpdatedAt" timestamp with time zone,
        CONSTRAINT "PK_exams" PRIMARY KEY ("Id")
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260521173406_Init') THEN
    CREATE TABLE exam_sections (
        "Id" uuid NOT NULL,
        "ExamId" uuid NOT NULL,
        "Idx" integer NOT NULL,
        "Title" text NOT NULL,
        "InstructionsMd" text,
        "PassageMd" text,
        "AudioUrl" text,
        "TranscriptMd" text,
        CONSTRAINT "PK_exam_sections" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_exam_sections_exams_ExamId" FOREIGN KEY ("ExamId") REFERENCES exams ("Id") ON DELETE CASCADE
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260521173406_Init') THEN
    CREATE TABLE exam_question_groups (
        "Id" uuid NOT NULL,
        "SectionId" uuid NOT NULL,
        "Idx" integer NOT NULL,
        "StartIdx" integer NOT NULL,
        "EndIdx" integer NOT NULL,
        "InstructionMd" text NOT NULL,
        CONSTRAINT "PK_exam_question_groups" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_exam_question_groups_exam_sections_SectionId" FOREIGN KEY ("SectionId") REFERENCES exam_sections ("Id") ON DELETE CASCADE
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260521173406_Init') THEN
    CREATE TABLE exam_questions (
        "Id" uuid NOT NULL,
        "SectionId" uuid NOT NULL,
        "GroupId" uuid,
        "Idx" integer NOT NULL,
        "Type" text NOT NULL,
        "Skill" text NOT NULL,
        "Difficulty" integer NOT NULL,
        "PromptMd" text NOT NULL,
        "ExplanationMd" text,
        "BlankAcceptTexts" jsonb,
        "BlankAcceptRegex" jsonb,
        "MatchPairs" jsonb,
        "OrderCorrects" text[],
        "ShortAnswerAcceptTexts" text[],
        "ShortAnswerAcceptRegex" text[],
        "ModelAnswers" jsonb,
        "WordList" jsonb,
        CONSTRAINT "PK_exam_questions" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_exam_questions_exam_question_groups_GroupId" FOREIGN KEY ("GroupId") REFERENCES exam_question_groups ("Id") ON DELETE SET NULL,
        CONSTRAINT "FK_exam_questions_exam_sections_SectionId" FOREIGN KEY ("SectionId") REFERENCES exam_sections ("Id") ON DELETE CASCADE
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260521173406_Init') THEN
    CREATE TABLE exam_options (
        "Id" uuid NOT NULL,
        "QuestionId" uuid NOT NULL,
        "Idx" integer NOT NULL,
        "ContentMd" text NOT NULL,
        "IsCorrect" boolean NOT NULL,
        CONSTRAINT "PK_exam_options" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_exam_options_exam_questions_QuestionId" FOREIGN KEY ("QuestionId") REFERENCES exam_questions ("Id") ON DELETE CASCADE
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260521173406_Init') THEN
    CREATE INDEX "IX_exam_options_QuestionId_Idx" ON exam_options ("QuestionId", "Idx");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260521173406_Init') THEN
    CREATE INDEX "IX_exam_question_groups_SectionId_Idx" ON exam_question_groups ("SectionId", "Idx");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260521173406_Init') THEN
    CREATE INDEX "IX_exam_questions_GroupId" ON exam_questions ("GroupId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260521173406_Init') THEN
    CREATE INDEX "IX_exam_questions_SectionId_Idx" ON exam_questions ("SectionId", "Idx");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260521173406_Init') THEN
    CREATE INDEX "IX_exam_sections_ExamId_Idx" ON exam_sections ("ExamId", "Idx");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260521173406_Init') THEN
    CREATE UNIQUE INDEX "IX_exams_Slug" ON exams ("Slug");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260521173406_Init') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260521173406_Init', '10.0.7');
    END IF;
END $EF$;
COMMIT;

