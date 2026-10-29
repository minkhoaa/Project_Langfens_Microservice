using System.Net;
using System.Net.Http.Headers;
using Grpc.Core;
using Grpc.Net.Client;
using Microsoft.AspNetCore.TestHost;
using Shared.Grpc.ExamInternal;
using Shared.Security.Roles;
using Xunit;

namespace attempt_service.Tests.Helpers;

public class InternalExamSecurityTests
{
    public static IEnumerable<object?[]> AccessCases()
    {
        foreach (var showAnswers in new[] { false, true })
        {
            yield return [null, null, ExamServiceTestHost.Key, showAnswers, false];
            yield return [Roles.User, null, ExamServiceTestHost.Key, showAnswers, false];
            yield return [Roles.User, "wrong", ExamServiceTestHost.Key, showAnswers, false];
            yield return [null, "wrong", ExamServiceTestHost.Key, showAnswers, false];
            yield return [null, ExamServiceTestHost.Key, ExamServiceTestHost.Key, showAnswers, true];
            yield return [Roles.User, ExamServiceTestHost.Key, ExamServiceTestHost.Key, showAnswers, true];
            yield return [Roles.Admin, null, ExamServiceTestHost.Key, showAnswers, true];
            yield return [null, ExamServiceTestHost.Key, null, showAnswers, false];
            yield return [null, " ", " ", showAnswers, false];
            yield return [Roles.User, null, null, showAnswers, false];
            yield return [Roles.Admin, null, null, showAnswers, true];
        }
    }

    [Theory]
    [MemberData(nameof(AccessCases))]
    public async Task Http_requires_configured_key_or_Admin_even_without_answers(
        string? role, string? suppliedKey, string? configuredKey, bool showAnswers, bool allowed)
    {
        await using var host = await ExamServiceTestHost.Start(configuredKey);
        if (role != null) host.Http.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", host.Jwt(role));
        if (suppliedKey != null) host.Http.DefaultRequestHeaders.Add("X-Internal-Key", suppliedKey);
        var response = await host.Http.GetAsync($"/api/internal/exams/{host.ExamId}/delivery?showAnswers={showAnswers}");
        Assert.Equal(allowed ? HttpStatusCode.OK : role == null ? HttpStatusCode.Unauthorized : HttpStatusCode.Forbidden,
            response.StatusCode);
        var json = await response.Content.ReadAsStringAsync();
        if (allowed)
        {
            Assert.Equal(showAnswers, json.Contains("private-explanation"));
            Assert.Equal(showAnswers, json.Contains("private-model"));
            Assert.Equal(showAnswers, json.Contains("private-blank"));
            Assert.Equal(showAnswers, json.Contains("private-regex"));
            Assert.Equal(showAnswers, json.Contains("private-match"));
            Assert.Equal(showAnswers, json.Contains("private-short"));
        }
        else Assert.DoesNotContain("private-", json);
    }

    [Theory]
    [MemberData(nameof(AccessCases))]
    public async Task Grpc_delivery_and_list_require_configured_key_or_Admin(
        string? role, string? suppliedKey, string? configuredKey, bool showAnswers, bool allowed)
    {
        await using var host = await ExamServiceTestHost.Start(configuredKey);
        using var channel = GrpcChannel.ForAddress("http://localhost", new GrpcChannelOptions { HttpHandler = host.App.GetTestServer().CreateHandler() });
        var client = new ExamInternal.ExamInternalClient(channel);
        var headers = new Metadata();
        if (role != null) headers.Add("authorization", $"Bearer {host.Jwt(role)}");
        if (suppliedKey != null) headers.Add("x-internal-key", suppliedKey);
        var request = new GetInternalExamRequest { ExamId = host.ExamId.ToString(), ShowAnswers = showAnswers };
        if (!allowed)
        {
            var error = await Assert.ThrowsAsync<RpcException>(async () => await client.GetInternalExamAsync(request, headers));
            Assert.Equal(role == null ? StatusCode.Unauthenticated : StatusCode.PermissionDenied, error.StatusCode);
            var listError = await Assert.ThrowsAsync<RpcException>(async () => await client.GetExamListAsync(new(), headers));
            Assert.Equal(error.StatusCode, listError.StatusCode);
            return;
        }
        var paper = await client.GetInternalExamAsync(request, headers);
        var question = Assert.Single(Assert.Single(Assert.Single(paper.Sections).QuestionGroups).Questions);
        Assert.Equal(showAnswers ? "private-explanation" : "", question.ExplanationMd);
        Assert.Equal(showAnswers, Assert.Single(question.Options).HasIsCorrect);
        Assert.Equal(showAnswers, question.CompletionAccepts.Count > 0);
        Assert.Equal(showAnswers, question.MatchPairs.Count > 0);
        Assert.Equal(showAnswers, question.OrderCorrects.Count > 0);
        Assert.Equal(showAnswers, question.ShortAnswerAcceptTexts.Count > 0);
        Assert.Equal(showAnswers, question.ShortAnswerAcceptRegex.Count > 0);
        Assert.NotEmpty((await client.GetExamListAsync(new(), headers)).Exams);
    }
}
