using System.Text.Json;
using exam_service.Features.ReadingPaper.Contracts;
using Xunit;

namespace exam_service.Tests;

public class Phase01ContractTests
{
    private static readonly string FixturesDir = Path.GetFullPath(
        Path.Combine(AppContext.BaseDirectory, "../../../../../artifacts/refactor/phase-01/fixtures")
    );

    [Fact]
    public void T01_01_Deserialize_ArtifactEnvelope_PreservesUnicodeNullsAndHashes()
    {
        var filePath = Path.Combine(FixturesDir, "artifact_envelope.json");
        Assert.True(File.Exists(filePath), $"Fixture file not found: {filePath}");

        var json = File.ReadAllText(filePath);
        var envelope = JsonSerializer.Deserialize<ArtifactEnvelope>(json, LoopEngineJson.Options);

        Assert.NotNull(envelope);
        Assert.Equal("art_passage_001", envelope.ArtifactId);
        Assert.Equal(ArtifactType.Passage, envelope.ArtifactType);
        Assert.Equal(1, envelope.Version);
        Assert.Equal("run_test_001", envelope.RunId);
        Assert.Equal(1, envelope.SectionId);
        Assert.Single(envelope.ParentRefs);
        Assert.Equal("art_evidence_001", envelope.ParentRefs[0].ArtifactId);
        Assert.Equal(ArtifactType.EvidenceGraph, envelope.ParentRefs[0].ArtifactType);

        // Verify Unicode preservation (Vietnamese accents + scientific symbols)
        var title = envelope.Payload.GetProperty("title").GetString();
        Assert.Contains("khí quyển cổ đại", title);
        var symbols = envelope.Payload.GetProperty("scientificSymbols").GetString();
        Assert.Contains("λ = 532 nm, ΔT = 1.5°C", symbols);

        // Verify null preservation
        Assert.Equal(JsonValueKind.Null, envelope.Payload.GetProperty("nullField").ValueKind);

        // Roundtrip serialization within .NET
        var reserialized = JsonSerializer.Serialize(envelope, LoopEngineJson.Options);
        var roundtrip = JsonSerializer.Deserialize<ArtifactEnvelope>(reserialized, LoopEngineJson.Options);
        Assert.NotNull(roundtrip);
        Assert.Equal(envelope.ContentHash, roundtrip.ContentHash);
        Assert.Equal(envelope.CreatedAt, roundtrip.CreatedAt);

        // Export .NET-serialized JSON for Python true roundtrip verification
        var outPath = Path.Combine(FixturesDir, "dotnet_roundtrip_envelope.json");
        File.WriteAllText(outPath, reserialized);
    }

    [Fact]
    public void T01_01_Deserialize_ReadingPaper_PreservesStructure()
    {
        var filePath = Path.Combine(FixturesDir, "reading_paper_valid.json");
        var json = File.ReadAllText(filePath);
        var paper = JsonSerializer.Deserialize<ReadingPaperDto>(json, LoopEngineJson.Options);

        Assert.NotNull(paper);
        Assert.Equal(40, paper.TotalQuestions);
        Assert.Equal(3, paper.Sections.Count);
        Assert.Equal(750, paper.Sections[0].WordCount);
        Assert.Equal(780, paper.Sections[1].WordCount);
        Assert.Equal(820, paper.Sections[2].WordCount);
        Assert.Equal(2350, paper.TotalWordCount);

        // Verify section 1 has 2 groups: 7 TFNG + 6 Sentence Completion
        Assert.Equal(2, paper.Sections[0].Groups.Count);
        Assert.Equal(QuestionType.TRUE_FALSE_NOT_GIVEN, paper.Sections[0].Groups[0].QuestionType);
        Assert.Equal(7, paper.Sections[0].Groups[0].Questions.Count);
        Assert.Equal(QuestionType.SENTENCE_COMPLETION, paper.Sections[0].Groups[1].QuestionType);
        Assert.Equal(6, paper.Sections[0].Groups[1].Questions.Count);

        // Export .NET-serialized JSON for Python true roundtrip verification
        var reserialized = JsonSerializer.Serialize(paper, LoopEngineJson.Options);
        var outPath = Path.Combine(FixturesDir, "dotnet_roundtrip_paper.json");
        File.WriteAllText(outPath, reserialized);
    }

    [Fact]
    public void T01_02_Deserialize_InvalidEnum_ThrowsJsonException()
    {
        var invalidJson = """
        {
            "artifactId": "art_001",
            "artifactType": "INVALID_UNKNOWN_TYPE",
            "version": 1,
            "runId": "run_01",
            "contentHash": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            "createdAt": "2026-09-30T12:00:00Z",
            "producerVersion": "1.0",
            "payload": {},
            "parentRefs": []
        }
        """;

        Assert.Throws<JsonException>(() =>
            JsonSerializer.Deserialize<ArtifactEnvelope>(invalidJson, LoopEngineJson.Options)
        );
    }

    [Fact]
    public void T01_02_Deserialize_UnknownField_ThrowsJsonException()
    {
        var unknownFieldJson = """
        {
            "artifactId": "art_001",
            "artifactType": "Passage",
            "version": 1,
            "contentHash": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            "unexpectedInjectedProperty": "forbidden"
        }
        """;

        Assert.Throws<JsonException>(() =>
            JsonSerializer.Deserialize<ArtifactRef>(unknownFieldJson, LoopEngineJson.Options)
        );
    }

    [Fact]
    public void T01_03_ArtifactHash_ChangesWhenPayloadChanges()
    {
        using var doc1 = JsonDocument.Parse("""{"temperature": 1.5, "note": "Observation"}""");
        using var doc2 = JsonDocument.Parse("""{"temperature": 1.6, "note": "Observation"}""");

        var hash1 = ArtifactEnvelope.ComputeContentHash(doc1.RootElement);
        var hash2 = ArtifactEnvelope.ComputeContentHash(doc2.RootElement);

        Assert.NotEqual(hash1, hash2);
        Assert.Equal(64, hash1.Length);
        Assert.Equal(64, hash2.Length);

        // Changing parent ref version or hash strictly produces a different artifact content hash
        var parentV1 = new ArtifactRef("art_parent", ArtifactType.EvidenceGraph, 1, "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef");
        var parentV2 = new ArtifactRef("art_parent", ArtifactType.EvidenceGraph, 2, "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef");

        var hashParentV1 = ArtifactEnvelope.ComputeContentHash(doc1.RootElement, new[] { parentV1 });
        var hashParentV2 = ArtifactEnvelope.ComputeContentHash(doc1.RootElement, new[] { parentV2 });
        Assert.NotEqual(hashParentV1, hashParentV2);
        Assert.NotEqual(hash1, hashParentV1);
    }

    [Fact]
    public void T01_04_EvaluatorErrorAndCriticalIssue_BlocksPass()
    {
        var errorFilePath = Path.Combine(FixturesDir, "evaluation_error.json");
        var errorJson = File.ReadAllText(errorFilePath);
        var evalError = JsonSerializer.Deserialize<EvaluationResult>(errorJson, LoopEngineJson.Options);

        Assert.NotNull(evalError);
        Assert.Equal(EvaluationStatus.ERROR, evalError.Status);
        Assert.False(evalError.IsPass);
        Assert.Single(evalError.Issues);
        Assert.Equal(IssueCode.EVALUATOR_UNAVAILABLE, evalError.Issues[0].Code);
        Assert.Equal(IssueSeverity.CRITICAL, evalError.Issues[0].Severity);

        // PASS evaluation result fixture
        var passFilePath = Path.Combine(FixturesDir, "evaluation_result.json");
        var passJson = File.ReadAllText(passFilePath);
        var evalPass = JsonSerializer.Deserialize<EvaluationResult>(passJson, LoopEngineJson.Options);

        Assert.NotNull(evalPass);
        Assert.Equal(EvaluationStatus.PASS, evalPass.Status);
        Assert.True(evalPass.IsPass);

        // If PASS status has an attached CRITICAL OPEN issue, IsPass must be FALSE
        var fakePassWithCritical = evalPass with
        {
            Issues = [evalError.Issues[0]]
        };
        Assert.False(fakePassWithCritical.IsPass);

        // Fail-closed decision validation:
        var passDecision = new LoopDecision(
            "dec_001",
            "run_01",
            DecisionType.PASS,
            LoopState.EVALUATING,
            LoopState.COMPLETED,
            "Evaluation passed",
            IssueScope.SECTION,
            null,
            null,
            evalPass.EvaluationId,
            DateTime.UtcNow
        );

        // 1. Missing evaluation: must be rejected fail-closed
        var (validNull, errNull) = LoopDecision.ValidateDecision(passDecision, null);
        Assert.False(validNull);
        Assert.Contains("Fail-closed rejection", errNull);

        // 2. Evaluator error: must be rejected fail-closed
        var (validErr, errErr) = LoopDecision.ValidateDecision(passDecision, evalError);
        Assert.False(validErr);
        Assert.Contains("cannot decide PASS", errErr);

        // 3. Open critical issue: must be rejected fail-closed
        var (validCrit, errCrit) = LoopDecision.ValidateDecision(passDecision, fakePassWithCritical);
        Assert.False(validCrit);
        Assert.Contains("open CRITICAL issues", errCrit);

        // 4. Mismatched evaluationRef: must be rejected fail-closed
        var mismatchedDecision = passDecision with { EvaluationRef = "eval_diff_id" };
        var (validMismatch, errMismatch) = LoopDecision.ValidateDecision(mismatchedDecision, evalPass);
        Assert.False(validMismatch);
        Assert.Contains("does not match", errMismatch);

        // 5. Valid matching passing evaluation: must pass
        var (validOk, errOk) = LoopDecision.ValidateDecision(passDecision, evalPass);
        Assert.True(validOk);
        Assert.Null(errOk);

        // Export .NET-serialized JSON for Python true roundtrip verification
        var reserialized = JsonSerializer.Serialize(evalPass, LoopEngineJson.Options);
        var outPath = Path.Combine(FixturesDir, "dotnet_roundtrip_eval.json");
        File.WriteAllText(outPath, reserialized);
    }

    [Fact]
    public void T01_05_AbsenceAssessment_NotGivenSemantics_Preserved()
    {
        var sampleFilePath = Path.Combine(FixturesDir, "question_types_sample.json");
        var json = File.ReadAllText(sampleFilePath);
        using var doc = JsonDocument.Parse(json);

        var ngElement = doc.RootElement.GetProperty("notGivenSample");
        var ngDto = JsonSerializer.Deserialize<TrueFalseNotGivenDto>(ngElement.GetRawText(), LoopEngineJson.Options);

        Assert.NotNull(ngDto);
        Assert.Equal("NOT_GIVEN", ngDto.Answer);
        Assert.Null(ngDto.EvidenceQuote);
        Assert.NotNull(ngDto.AbsenceAssessment);
        Assert.True(ngDto.AbsenceAssessment.AbsenceConfirmed);
        Assert.Contains("mentions nothing", ngDto.AbsenceAssessment.AbsenceReason);

        var compElement = doc.RootElement.GetProperty("completionSample");
        var compDto = JsonSerializer.Deserialize<SentenceCompletionDto>(compElement.GetRawText(), LoopEngineJson.Options);

        Assert.NotNull(compDto);
        Assert.Equal("ice cores", compDto.Answer);
        Assert.NotNull(compDto.EvidenceQuote);
        Assert.Contains("ice cores", compDto.EvidenceQuote);
    }

    [Fact]
    public void T01_06_QuestionTypeDistribution_MatchesIeltsAcademicPolicy()
    {
        var filePath = Path.Combine(FixturesDir, "reading_paper_valid.json");
        var json = File.ReadAllText(filePath);
        var paper = JsonSerializer.Deserialize<ReadingPaperDto>(json, LoopEngineJson.Options);

        Assert.NotNull(paper);
        // Section 1: 13 questions
        Assert.Equal(13, paper.Sections[0].Groups.Sum(g => g.Questions.Count));
        // Section 2: 13 questions
        Assert.Equal(13, paper.Sections[1].Groups.Sum(g => g.Questions.Count));
        // Section 3: 14 questions
        Assert.Equal(14, paper.Sections[2].Groups.Sum(g => g.Questions.Count));

        // Group counts [[7, 6], [6, 7], [7, 7]]
        Assert.Equal([7, 6], paper.Sections[0].Groups.Select(g => g.Questions.Count).ToArray());
        Assert.Equal([6, 7], paper.Sections[1].Groups.Select(g => g.Questions.Count).ToArray());
        Assert.Equal([7, 7], paper.Sections[2].Groups.Select(g => g.Questions.Count).ToArray());
    }
}
