using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper;
using exam_service.Features.ReadingPaper.Contracts;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Npgsql;
using Shared.ExamDto.Contracts.Exam.Enums;
using Xunit;

namespace exam_service.Tests;

public class FeedbackTestFixture : IAsyncLifetime
{
    private const string DefaultConn = "Host=localhost;Port=5433;Database=exam_test_phase14_feedback_b;Username=exam;Password=exam";
    public Phase14ExamApiFactory Factory { get; private set; } = default!;
    public HttpClient AdminClient { get; private set; } = default!;

    public async Task InitializeAsync()
    {
        var connection = Environment.GetEnvironmentVariable("READING_TEST_POSTGRES") ?? DefaultConn;
        var csb = new NpgsqlConnectionStringBuilder(connection);
        var targetDb = csb.Database;
        csb.Database = "postgres";

        await using (var mConn = new NpgsqlConnection(csb.ConnectionString))
        {
            await mConn.OpenAsync();
            await using var checkCmd = new NpgsqlCommand($"SELECT 1 FROM pg_database WHERE datname = '{targetDb}'", mConn);
            var exists = await checkCmd.ExecuteScalarAsync();
            if (exists == null)
            {
                await using var createCmd = new NpgsqlCommand($"CREATE DATABASE \"{targetDb}\"", mConn);
                await createCmd.ExecuteNonQueryAsync();
            }
        }

        await using (var conn = new NpgsqlConnection(connection))
        {
            await conn.OpenAsync();
            await using var cmd = new NpgsqlCommand("DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;", conn);
            await cmd.ExecuteNonQueryAsync();
        }

        Factory = new Phase14ExamApiFactory(connection);
        AdminClient = Factory.CreateAdminClient();
    }

    public async Task DisposeAsync()
    {
        AdminClient?.Dispose();
        if (Factory != null)
        {
            await Factory.DisposeAsync();
        }
    }
}

[Collection("DatabaseTests")]
public class Phase14FeedbackReviewTests : IClassFixture<FeedbackTestFixture>
{
    private readonly FeedbackTestFixture _fixture;

    public Phase14FeedbackReviewTests(FeedbackTestFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public void SmallEditPolicy_EvaluatesCorrectly()
    {
        // 1. Identical text
        var same = SmallEditPolicyHelper.Evaluate("The quick brown fox", "The quick brown fox");
        Assert.True(same.IsSmallEdit);
        Assert.False(same.ReasonsRequired);

        // 2. Minor edit (typo fix <= 10 char diff)
        var typo = SmallEditPolicyHelper.Evaluate("The quik brown fox", "The quick brown fox");
        Assert.True(typo.IsSmallEdit);
        Assert.False(typo.ReasonsRequired);

        // 3. Formatting-only change
        var fmt = SmallEditPolicyHelper.Evaluate("The **quick** brown fox.", "The quick brown fox");
        Assert.True(fmt.FormattingOnly);
        Assert.True(fmt.IsSmallEdit);
        Assert.False(fmt.ReasonsRequired);

        // 4. Substantive rewrite (> 10 char delta)
        var substantive = SmallEditPolicyHelper.Evaluate(
            "The passage describes coastal mangrove restoration initiatives.",
            "The passage outlines urban transportation strategies and mass transit.");
        Assert.False(substantive.IsSmallEdit);
        Assert.True(substantive.ReasonsRequired);
        Assert.True(substantive.ReasonsRecommended);
    }

    [Fact]
    public void CanonicalReasonTaxonomy_ContainsAllEightReasons()
    {
        Assert.Equal(8, FeedbackReasons.All.Count);
        Assert.True(FeedbackReasons.IsKnown("unsupported_claim"));
        Assert.True(FeedbackReasons.IsKnown("ambiguity"));
        Assert.True(FeedbackReasons.IsKnown("too_direct_or_easy"));
        Assert.True(FeedbackReasons.IsKnown("weak_distractor"));
        Assert.True(FeedbackReasons.IsKnown("style_or_grammar"));
        Assert.True(FeedbackReasons.IsKnown("typo_or_formatting"));
        Assert.True(FeedbackReasons.IsKnown("policy_violation"));
        Assert.True(FeedbackReasons.IsKnown("source_license_issue"));
        Assert.False(FeedbackReasons.IsKnown("non_existent_reason"));
    }

    [Theory]
    [InlineData(CurationStatuses.Raw, CurationStatuses.Annotated, true)]
    [InlineData(CurationStatuses.Raw, CurationStatuses.Rejected, true)]
    [InlineData(CurationStatuses.Annotated, CurationStatuses.Reviewed, true)]
    [InlineData(CurationStatuses.Annotated, CurationStatuses.Rejected, true)]
    [InlineData(CurationStatuses.Reviewed, CurationStatuses.Curated, true)]
    [InlineData(CurationStatuses.Reviewed, CurationStatuses.Rejected, true)]
    [InlineData(CurationStatuses.Raw, CurationStatuses.Curated, false)] // Direct promotion disallowed
    [InlineData(CurationStatuses.Raw, CurationStatuses.Reviewed, false)] // Skipping annotated disallowed
    [InlineData(CurationStatuses.Annotated, CurationStatuses.Curated, false)] // Skipping reviewed disallowed
    [InlineData(CurationStatuses.Curated, CurationStatuses.Raw, false)] // Demotion disallowed
    public void StateMachine_Transitions_ValidateStrictly(string currentStatus, string targetStatus, bool expectedValid)
    {
        bool isValid = (currentStatus, targetStatus) switch
        {
            (CurationStatuses.Raw, CurationStatuses.Annotated) => true,
            (CurationStatuses.Raw, CurationStatuses.Rejected) => true,
            (CurationStatuses.Annotated, CurationStatuses.Reviewed) => true,
            (CurationStatuses.Annotated, CurationStatuses.Rejected) => true,
            (CurationStatuses.Reviewed, CurationStatuses.Curated) => true,
            (CurationStatuses.Reviewed, CurationStatuses.Rejected) => true,
            _ when string.Equals(currentStatus, targetStatus, StringComparison.OrdinalIgnoreCase) => true,
            _ => false
        };

        Assert.Equal(expectedValid, isValid);
    }

    [Fact]
    public async Task ReviewFeedback_Endpoint_RejectsDirectRawToCurated_Returns400()
    {
        var examId = Guid.NewGuid();
        var feedbackId = $"fb-http-raw-{Guid.NewGuid():N}";

        using (var scope = _fixture.Factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            db.ReadingPaperHumanFeedbacks.Add(new ReadingPaperHumanFeedback
            {
                FeedbackId = feedbackId,
                ExamId = examId,
                TargetEntityType = "QUESTION",
                TargetEntityId = "q-test-1",
                ActionType = FeedbackActions.Update,
                CurationStatus = CurationStatuses.Raw,
                EditorId = "editor-admin-test",
                ReasonsJson = "[\"typo_or_formatting\"]",
                Comment = "Initial typo fix",
                IdempotencyKey = $"test-idemp-{feedbackId}"
            });
            await db.SaveChangesAsync();
        }

        // Direct RAW -> CURATED is disallowed
        var reviewReq = new FeedbackReviewRequest
        {
            CurationStatus = CurationStatuses.Curated,
            ReviewerNotes = "Attempt direct curation"
        };

        var response = await _fixture.AdminClient.PostAsJsonAsync($"/api/v2/reading/feedback/{feedbackId}/review", reviewReq);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);

        var body = await response.Content.ReadAsStringAsync();
        Assert.Contains("Invalid status transition", body);
    }

    [Fact]
    public async Task ReviewFeedback_Endpoint_FollowsProgressiveTransitions_Returns200()
    {
        var examId = Guid.NewGuid();
        var feedbackId = $"fb-http-prog-{Guid.NewGuid():N}";

        using (var scope = _fixture.Factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            db.ReadingPaperHumanFeedbacks.Add(new ReadingPaperHumanFeedback
            {
                FeedbackId = feedbackId,
                ExamId = examId,
                TargetEntityType = "QUESTION",
                TargetEntityId = "q-test-2",
                ActionType = FeedbackActions.Update,
                CurationStatus = CurationStatuses.Raw,
                EditorId = "editor-admin-test",
                ReasonsJson = "[\"ambiguity\"]",
                Comment = "Initial prompt ambiguity",
                IdempotencyKey = $"test-idemp-{feedbackId}"
            });
            await db.SaveChangesAsync();
        }

        // Step 1: RAW -> ANNOTATED (200 OK)
        var res1 = await _fixture.AdminClient.PostAsJsonAsync($"/api/v2/reading/feedback/{feedbackId}/review", new FeedbackReviewRequest
        {
            CurationStatus = CurationStatuses.Annotated,
            ReviewerNotes = "Annotated ambiguity"
        });
        Assert.Equal(HttpStatusCode.OK, res1.StatusCode);

        // Step 2: ANNOTATED -> REVIEWED (200 OK)
        var res2 = await _fixture.AdminClient.PostAsJsonAsync($"/api/v2/reading/feedback/{feedbackId}/review", new FeedbackReviewRequest
        {
            CurationStatus = CurationStatuses.Reviewed,
            ReviewerNotes = "Verified ambiguity fix"
        });
        Assert.Equal(HttpStatusCode.OK, res2.StatusCode);

        // Step 3: REVIEWED -> CURATED (200 OK)
        var res3 = await _fixture.AdminClient.PostAsJsonAsync($"/api/v2/reading/feedback/{feedbackId}/review", new FeedbackReviewRequest
        {
            CurationStatus = CurationStatuses.Curated,
            ReviewerNotes = "Curated into gold set"
        });
        Assert.Equal(HttpStatusCode.OK, res3.StatusCode);

        // Verify GET returns effective status CURATED
        var getRes = await _fixture.AdminClient.GetAsync($"/api/v2/reading/feedback/{feedbackId}");
        Assert.Equal(HttpStatusCode.OK, getRes.StatusCode);
        var dto = await getRes.Content.ReadFromJsonAsync<HumanFeedbackDto>();
        Assert.NotNull(dto);
        Assert.Equal(CurationStatuses.Curated, dto.CurationStatus);

        // Verify base feedback row was not mutated in place
        using (var scope = _fixture.Factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var raw = await db.ReadingPaperHumanFeedbacks.AsNoTracking().FirstAsync(f => f.FeedbackId == feedbackId);
            Assert.Equal(CurationStatuses.Raw, raw.CurationStatus); // Base evidence row remains RAW
            var curationCount = await db.ReadingPaperFeedbackCurationRecords.CountAsync(r => r.FeedbackId == feedbackId);
            Assert.Equal(3, curationCount); // 3 append-only audit rows
        }
    }

    [Fact]
    public async Task ReviewFeedback_Endpoint_IgnoresSpoofedBodyReviewerId_UsesAuthenticatedClaim()
    {
        var examId = Guid.NewGuid();
        var feedbackId = $"fb-http-spoof-{Guid.NewGuid():N}";

        using (var scope = _fixture.Factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            db.ReadingPaperHumanFeedbacks.Add(new ReadingPaperHumanFeedback
            {
                FeedbackId = feedbackId,
                ExamId = examId,
                TargetEntityType = "QUESTION",
                TargetEntityId = "q-test-spoof",
                ActionType = FeedbackActions.Update,
                CurationStatus = CurationStatuses.Raw,
                EditorId = "editor-admin-test",
                ReasonsJson = "[\"typo_or_formatting\"]",
                Comment = "Initial edit",
                IdempotencyKey = $"test-idemp-{feedbackId}"
            });
            await db.SaveChangesAsync();
        }

        // Request with spoofed ReviewerId in body
        var reviewReq = new FeedbackReviewRequest
        {
            CurationStatus = CurationStatuses.Annotated,
            ReviewerNotes = "Review with spoofed body ID",
            ReviewerId = "spoofed-attacker-456"
        };

        var response = await _fixture.AdminClient.PostAsJsonAsync($"/api/v2/reading/feedback/{feedbackId}/review", reviewReq);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        // Verify the persisted curation record has ReviewerId = "editor-admin-test" (from JWT claim), NOT "spoofed-attacker-456"
        using (var scope = _fixture.Factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var curation = await db.ReadingPaperFeedbackCurationRecords
                .Where(r => r.FeedbackId == feedbackId)
                .OrderByDescending(r => r.ReviewedAt)
                .FirstAsync();

            Assert.Equal("editor-admin-test", curation.ReviewerId);
            Assert.NotEqual("spoofed-attacker-456", curation.ReviewerId);
        }
    }

    [Fact]
    public async Task ReviewFeedback_Endpoint_CasConflict_Returns409()
    {
        var examId = Guid.NewGuid();
        var feedbackId = $"fb-http-cas-{Guid.NewGuid():N}";

        using (var scope = _fixture.Factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            db.ReadingPaperHumanFeedbacks.Add(new ReadingPaperHumanFeedback
            {
                FeedbackId = feedbackId,
                ExamId = examId,
                TargetEntityType = "QUESTION",
                TargetEntityId = "q-test-cas",
                ActionType = FeedbackActions.Update,
                CurationStatus = CurationStatuses.Raw,
                EditorId = "editor-admin-test",
                ReasonsJson = "[\"typo_or_formatting\"]",
                Comment = "Initial edit",
                IdempotencyKey = $"test-idemp-{feedbackId}"
            });
            await db.SaveChangesAsync();
        }

        // Send CAS with wrong expected status (expected ANNOTATED, but actual is RAW)
        var conflictReq = new FeedbackReviewRequest
        {
            CurationStatus = CurationStatuses.Annotated,
            ReviewerNotes = "Conflicting CAS attempt",
            ExpectedCurrentStatus = "ANNOTATED" // mismatch
        };

        var response = await _fixture.AdminClient.PostAsJsonAsync($"/api/v2/reading/feedback/{feedbackId}/review", conflictReq);
        Assert.Equal(HttpStatusCode.Conflict, response.StatusCode);

        // Send CAS with correct expected status (expected RAW, actual is RAW)
        var matchingReq = new FeedbackReviewRequest
        {
            CurationStatus = CurationStatuses.Annotated,
            ReviewerNotes = "Matching CAS attempt",
            ExpectedCurrentStatus = "RAW" // matches!
        };

        var okResponse = await _fixture.AdminClient.PostAsJsonAsync($"/api/v2/reading/feedback/{feedbackId}/review", matchingReq);
        Assert.Equal(HttpStatusCode.OK, okResponse.StatusCode);
    }

    [Fact]
    public async Task AcceptPaper_Endpoint_HeaderIdempotencyKey_ReplaysWithoutDuplicates()
    {
        var examId = Guid.NewGuid();
        using (var scope = _fixture.Factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            db.Exams.Add(new Exam
            {
                Id = examId,
                Slug = $"test-accept-exam-{Guid.NewGuid():N}",
                Title = "Acceptance Test Exam",
                Category = "IELTS",
                Level = "B2",
                Status = ExamStatus.Draft
            });
            await db.SaveChangesAsync();
        }

        var headerKey = $"accept-header-key-{Guid.NewGuid():N}";
        var req1 = new HttpRequestMessage(HttpMethod.Post, $"/api/v2/reading/papers/{examId}/accept")
        {
            Content = JsonContent.Create(new exam_service.Features.ReadingPaper.FeedbackEndpoints.AcceptPaperPayload(
                Reasons: new[] { "typo_or_formatting" },
                Comment: "Reviewed questions"
            ))
        };
        req1.Headers.Add("Idempotency-Key", headerKey);

        var res1 = await _fixture.AdminClient.SendAsync(req1);
        Assert.Equal(HttpStatusCode.OK, res1.StatusCode);

        // Replay with exact same Idempotency-Key header
        var req2 = new HttpRequestMessage(HttpMethod.Post, $"/api/v2/reading/papers/{examId}/accept")
        {
            Content = JsonContent.Create(new exam_service.Features.ReadingPaper.FeedbackEndpoints.AcceptPaperPayload(
                Reasons: new[] { "typo_or_formatting" },
                Comment: "Reviewed questions"
            ))
        };
        req2.Headers.Add("Idempotency-Key", headerKey);

        var res2 = await _fixture.AdminClient.SendAsync(req2);
        Assert.Equal(HttpStatusCode.OK, res2.StatusCode);

        // Verify only 1 feedback row and 1 outbox event exist for this key
        using (var scope = _fixture.Factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var fbCount = await db.ReadingPaperHumanFeedbacks.CountAsync(f => f.IdempotencyKey == headerKey);
            Assert.Equal(1, fbCount);

            var outboxCount = await db.ReadingPaperEventOutbox.CountAsync(e => e.IdempotencyKey == headerKey);
            Assert.Equal(1, outboxCount);
        }
    }

    [Fact]
    public async Task PublishPaper_Endpoint_PublishesExam_AndCreatesRawActionEvidence()
    {
        var examId = Guid.NewGuid();
        using (var scope = _fixture.Factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            db.Exams.Add(new Exam
            {
                Id = examId,
                Slug = $"test-publish-exam-{Guid.NewGuid():N}",
                Title = "Publish Test Exam",
                Category = "IELTS",
                Level = "B2",
                Status = ExamStatus.Draft
            });
            await db.SaveChangesAsync();
        }

        var headerKey = $"publish-header-key-{Guid.NewGuid():N}";
        var req = new HttpRequestMessage(HttpMethod.Post, $"/api/v2/reading/papers/{examId}/publish")
        {
            Content = JsonContent.Create(new exam_service.Features.ReadingPaper.FeedbackEndpoints.PublishPaperPayload(
                Comment: "Final verification pass complete"
            ))
        };
        req.Headers.Add("Idempotency-Key", headerKey);

        var res = await _fixture.AdminClient.SendAsync(req);
        Assert.Equal(HttpStatusCode.OK, res.StatusCode);

        // Verify exam status transitioned to Published
        using (var scope = _fixture.Factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var exam = await db.Exams.FirstAsync(e => e.Id == examId);
            Assert.Equal(ExamStatus.Published, exam.Status);

            // Verify ReadingPaperHumanFeedback is created with RAW status
            var fb = await db.ReadingPaperHumanFeedbacks.FirstAsync(f => f.IdempotencyKey == headerKey);
            Assert.Equal(FeedbackActions.Publish, fb.ActionType);
            Assert.Equal(CurationStatuses.Raw, fb.CurationStatus); // RAW action evidence

            // Verify atomic outbox event was created
            var outbox = await db.ReadingPaperEventOutbox.FirstOrDefaultAsync(e => e.IdempotencyKey == headerKey);
            Assert.NotNull(outbox);
            Assert.Equal("HUMAN_FEEDBACK_CAPTURED", outbox.EventType);
        }
    }
}
