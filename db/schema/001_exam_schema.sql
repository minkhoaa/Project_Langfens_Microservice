-- ============================================================
-- Langfens Exam Service — Consolidated Schema
-- Generated from EF Core migrations through AddWordListToExamQuestion
-- Applies all migrations: InitDb → AddQuestionAnswerMetadata →
-- AddSectionAudioFields → AddPassageMdToSection → AddImageUrl →
-- AddWordListToExamQuestion + exam_question_groups (from ExamDbContext)
-- ============================================================

-- Exams
CREATE TABLE IF NOT EXISTS exams (
    Id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    Slug            text        NOT NULL UNIQUE,
    Title           text        NOT NULL,
    DescriptionMd   text,
    Category        text        NOT NULL,
    Level           text        NOT NULL,
    Status          text        NOT NULL,
    DurationMin     integer     NOT NULL,
    CreatedAt       timestamptz NOT NULL DEFAULT now(),
    UpdatedAt       timestamptz,
    ImageUrl        text
);

CREATE UNIQUE INDEX IF NOT EXISTS IX_exams_Slug ON exams (Slug);

-- Exam Sections
CREATE TABLE IF NOT EXISTS exam_sections (
    Id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    ExamId          uuid        NOT NULL REFERENCES exams(Id) ON DELETE CASCADE,
    Idx             integer     NOT NULL,
    Title           text        NOT NULL,
    InstructionsMd  text,
    PassageMd       text,
    AudioUrl        text,
    TranscriptMd    text
);

CREATE INDEX IF NOT EXISTS IX_exam_sections_ExamId_Idx ON exam_sections (ExamId, Idx);

-- Question Groups (grouped instruction headers)
CREATE TABLE IF NOT EXISTS exam_question_groups (
    Id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    SectionId       uuid        NOT NULL REFERENCES exam_sections(Id) ON DELETE CASCADE,
    Idx             integer     NOT NULL,
    StartIdx        integer     NOT NULL,
    EndIdx          integer     NOT NULL,
    InstructionMd   text        NOT NULL
);

CREATE INDEX IF NOT EXISTS IX_exam_question_groups_SectionId_Idx ON exam_question_groups (SectionId, Idx);

-- Exam Questions
CREATE TABLE IF NOT EXISTS exam_questions (
    Id                      uuid                PRIMARY KEY DEFAULT gen_random_uuid(),
    SectionId               uuid                NOT NULL REFERENCES exam_sections(Id) ON DELETE CASCADE,
    GroupId                 uuid                REFERENCES exam_question_groups(Id) ON DELETE SET NULL,
    Idx                     integer             NOT NULL,
    Type                    text                NOT NULL,
    Skill                   text                NOT NULL,
    Difficulty              integer             NOT NULL DEFAULT 1,
    PromptMd                text                NOT NULL,
    ExplanationMd           text,
    -- JSONB columns for type-specific question data
    BlankAcceptTexts        jsonb,
    BlankAcceptRegex        jsonb,
    MatchPairs              jsonb,
    -- Array columns
    OrderCorrects           text[],
    ShortAnswerAcceptTexts  text[],
    ShortAnswerAcceptRegex  text[],
    -- Model/sample answers for ESSAY/WRITING
    ModelAnswers            jsonb,
    -- Structured word list for MATCHING_INFORMATION
    WordList                jsonb
);

CREATE INDEX IF NOT EXISTS IX_exam_questions_SectionId_Idx ON exam_questions (SectionId, Idx);
CREATE INDEX IF NOT EXISTS IX_exam_questions_GroupId ON exam_questions (GroupId);

-- Exam Options (for MCQ)
CREATE TABLE IF NOT EXISTS exam_options (
    Id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    QuestionId  uuid        NOT NULL REFERENCES exam_questions(Id) ON DELETE CASCADE,
    Idx         integer     NOT NULL,
    ContentMd   text        NOT NULL,
    IsCorrect   boolean     NOT NULL DEFAULT false
);

CREATE INDEX IF NOT EXISTS IX_exam_options_QuestionId_Idx ON exam_options (QuestionId, Idx);
