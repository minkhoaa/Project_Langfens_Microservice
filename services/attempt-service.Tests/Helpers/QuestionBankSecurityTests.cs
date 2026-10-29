using System.Net;
using System.Net.Http.Headers;
using System.Text.Json;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Shared.Security.Roles;
using Xunit;

namespace attempt_service.Tests.Helpers;

public class QuestionBankSecurityTests
{
    [Fact]
    public async Task Student_practice_is_authenticated_published_only_and_has_no_private_fields()
    {
        await using var host = await ExamServiceTestHost.Start();
        var urls = new[]
        {
            "/api/question-bank/types",
            "/api/question-bank/questions?type=MULTIPLE_CHOICE_SINGLE",
            "/api/question-bank/exams?type=MULTIPLE_CHOICE_SINGLE"
        };
        foreach (var url in urls)
            Assert.Equal(HttpStatusCode.Unauthorized, (await host.Http.GetAsync(url)).StatusCode);

        host.Http.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", host.Jwt(Roles.User));
        foreach (var url in urls)
        {
            var response = await host.Http.GetAsync(url);
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
            var json = await response.Content.ReadAsStringAsync();
            Assert.DoesNotContain("Draft", json);
            Assert.DoesNotContain("Archived", json);
            Assert.DoesNotContain("DRAFT_ONLY_TYPE", json);
            Assert.DoesNotContain("private-", json);
            using var doc = JsonDocument.Parse(json);
            var data = doc.RootElement.GetProperty("data");
            if (url.Contains("/types"))
                Assert.Equal(1, Assert.Single(data.EnumerateArray()).GetProperty("count").GetInt32());
            else if (url.Contains("/exams"))
                Assert.Equal(host.ExamId, Assert.Single(data.EnumerateArray()).GetProperty("id").GetGuid());
            else
            {
                Assert.Equal(1, data.GetProperty("totalCount").GetInt32());
                var question = Assert.Single(data.GetProperty("items").EnumerateArray());
                Assert.Equal(host.ExamId, question.GetProperty("examId").GetGuid());
                foreach (var field in new[] { "explanationMd", "matchPairs", "blankAcceptTexts", "blankAcceptRegex", "orderCorrects", "shortAnswerAcceptTexts", "shortAnswerAcceptRegex" })
                    Assert.Equal(JsonValueKind.Null, question.GetProperty(field).ValueKind);
                Assert.False(question.TryGetProperty("modelAnswers", out _));
                Assert.Equal(JsonValueKind.Null, Assert.Single(question.GetProperty("options").EnumerateArray()).GetProperty("isCorrect").ValueKind);
            }
        }
        using var scope = host.App.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        var original = await db.ExamQuestions.Include(q => q.Options).SingleAsync(q => q.Section.ExamId == host.ExamId);
        Assert.Equal("private-explanation", original.ExplanationMd);
        Assert.Equal("private-model", Assert.Single(original.ModelAnswers!));
        Assert.True(Assert.Single(original.Options).IsCorrect);
        Assert.Equal("private-blank", original.BlankAcceptTexts!["1"]![0]);
    }

    [Theory]
    [InlineData(false)]
    [InlineData(true)]
    public async Task Http_delivery_redacts_both_flat_and_grouped_questions_without_changing_keys(bool grouped)
    {
        await using var host = await ExamServiceTestHost.Start(grouped: grouped);
        host.Http.DefaultRequestHeaders.Add("X-Internal-Key", ExamServiceTestHost.Key);
        foreach (var showAnswers in new[] { false, true, false })
        {
            var response = await host.Http.GetAsync($"/api/internal/exams/{host.ExamId}/delivery?showAnswers={showAnswers}");
            response.EnsureSuccessStatusCode();
            using var doc = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
            var section = Assert.Single(doc.RootElement.GetProperty("data").GetProperty("sections").EnumerateArray());
            Assert.Empty(section.GetProperty("questions").EnumerateArray());
            var deliveryQuestion = Assert.Single(Assert.Single(section.GetProperty("questionGroups").EnumerateArray()).GetProperty("questions").EnumerateArray());
            foreach (var question in new[] { deliveryQuestion })
            {
                Assert.Equal(showAnswers ? JsonValueKind.String : JsonValueKind.Null, question.GetProperty("explanationMd").ValueKind);
                foreach (var field in new[] { "modelAnswers", "orderCorrects", "shortAnswerAcceptTexts", "shortAnswerAcceptRegex" })
                    Assert.Equal(showAnswers ? JsonValueKind.Array : JsonValueKind.Null, question.GetProperty(field).ValueKind);
                foreach (var field in new[] { "blankAcceptTexts", "blankAcceptRegex", "matchPairs" })
                    Assert.Equal(showAnswers ? JsonValueKind.Object : JsonValueKind.Null, question.GetProperty(field).ValueKind);
                Assert.Equal(showAnswers ? JsonValueKind.True : JsonValueKind.Null,
                    Assert.Single(question.GetProperty("options").EnumerateArray()).GetProperty("isCorrect").ValueKind);
                Assert.Equal("public-word", Assert.Single(question.GetProperty("wordList").EnumerateArray()).GetString());
            }
        }
    }
}
