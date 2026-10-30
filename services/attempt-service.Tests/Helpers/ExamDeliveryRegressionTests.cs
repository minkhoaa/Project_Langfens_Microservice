using System.Text.Json;
using exam_service.Application.Common;
using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
using exam_service.Features.Exams.AdminEndpoint.QuestionEndpoint;
using exam_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Shared.ExamDto.Contracts.Exam.Enums;
using Xunit;

namespace attempt_service.Tests.Helpers;

public class ExamDeliveryRegressionTests
{
    [Fact]
    public async Task Admin_creates_updates_and_clears_group_and_word_list_without_losing_other_fields()
    {
        // Only a new named disposable InMemory store; never production startup/migrations.
        var options = new DbContextOptionsBuilder<ExamDbContext>().UseInMemoryDatabase(Guid.NewGuid().ToString())
            .ConfigureWarnings(w => w.Ignore(InMemoryEventId.TransactionIgnoredWarning)).Options;
        await using var db = new OfflineExamDbContext(options);
        var exam = ExamServiceTestHost.Paper();
        db.Exams.Add(exam);
        await db.SaveChangesAsync();
        var section = exam.Sections[0];
        var group = section.QuestionGroups[0];
        var service = new AdminQuestionService(db, new ConfigurationBuilder().Build());
        var created = await service.AddAsync(default, new DtoAdmin.AdminQuestionUpsert(
            section.Id, null, QuestionType.MultipleChoiceSingle, "READING", 2, "New prompt", "Private explanation",
            GroupId: group.Id, WordList: ["word-a", "word-b"]));
        Assert.Equal(200, ((IStatusCodeHttpResult)created).StatusCode);
        db.ChangeTracker.Clear();
        var question = await db.ExamQuestions.SingleAsync(q => q.PromptMd == "New prompt");
        Assert.Equal(group.Id, question.GroupId);
        Assert.Equal(new[] { "word-a", "word-b" }, question.WordList);
        var updated = await service.UpdateAsync(default, new DtoAdmin.AdminQuestionUpdate(
            section.Id, 9, QuestionType.MultipleChoiceSingle, "READING", 3, "Updated prompt", "Private updated",
            GroupId: group.Id, WordList: ["word-c"]), question.Id);
        Assert.Equal(200, ((IStatusCodeHttpResult)updated).StatusCode);
        db.ChangeTracker.Clear();
        question = await db.ExamQuestions.SingleAsync(q => q.Id == question.Id);
        Assert.Equal(group.Id, question.GroupId);
        Assert.Equal(new[] { "word-c" }, question.WordList);
        Assert.Equal(9, question.Idx);
        Assert.Equal("Private updated", question.ExplanationMd);
        Assert.Equal(200, ((IStatusCodeHttpResult)await service.UpdateAsync(default, new DtoAdmin.AdminQuestionUpdate(
            section.Id, null, question.Type, question.Skill, 1, "Cleared", null), question.Id)).StatusCode);
        db.ChangeTracker.Clear();
        question = await db.ExamQuestions.SingleAsync(q => q.Id == question.Id);
        Assert.Null(question.GroupId);
        Assert.Null(question.WordList);
        Assert.Equal(9, question.Idx);
    }

    [Theory]
    [InlineData(false)]
    [InlineData(true)]
    public async Task Admin_rejects_unknown_and_cross_section_group_before_any_mutation(bool unknown)
    {
        await using var db = new OfflineExamDbContext(OfflineExamDbContext.Options(Guid.NewGuid().ToString()));
        var exam = ExamServiceTestHost.Paper();
        var foreign = ExamServiceTestHost.Paper();
        db.Exams.AddRange(exam, foreign);
        await db.SaveChangesAsync();
        var question = exam.Sections[0].Questions[0];
        var invalid = unknown ? Guid.NewGuid() : foreign.Sections[0].QuestionGroups[0].Id;
        var service = new AdminQuestionService(db, new ConfigurationBuilder().Build());
        var add = await service.AddAsync(default, new DtoAdmin.AdminQuestionUpsert(
            question.SectionId, null, question.Type, question.Skill, 1, "Rejected", null, GroupId: invalid));
        var update = await service.UpdateAsync(default, new DtoAdmin.AdminQuestionUpdate(
            question.SectionId, 1, question.Type, question.Skill, 1, "Rejected", null, GroupId: invalid), question.Id);
        Assert.Equal(400, ((IStatusCodeHttpResult)add).StatusCode);
        Assert.Equal(400, ((IStatusCodeHttpResult)update).StatusCode);
        Assert.Equal(2, await db.ExamQuestions.CountAsync());
        Assert.Equal("Public prompt", question.PromptMd);
    }

    [Fact]
    public async Task Public_internal_http_and_proto_agree_on_explicit_membership_and_preserve_legacy_and_unassigned()
    {
        await using var host = await ExamServiceTestHost.Start();
        using var scope = host.App.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        var exam = await db.Exams.Include(e => e.Sections).ThenInclude(s => s.Questions).ThenInclude(q => q.Options)
            .Include(e => e.Sections).ThenInclude(s => s.QuestionGroups).SingleAsync(e => e.Id == host.ExamId);
        var section = exam.Sections[0];
        var first = section.QuestionGroups[0];
        var second = new ExamQuestionGroup
        {
            Id = Guid.NewGuid(), SectionId = section.Id, Idx = 2, StartIdx = 8, EndIdx = 9, InstructionMd = "Second instruction"
        };
        section.QuestionGroups.Add(second);
        db.ExamQuestionGroups.Add(second);
        // Explicit first member lies in the other group's bounds. It must not move or duplicate.
        section.Questions[0].Idx = 9;
        var legacy = NewQuestion(section, 8, "Legacy", null);
        var unassigned = NewQuestion(section, 30, "Unassigned", null);
        section.Questions.AddRange([legacy, unassigned]);
        db.ExamQuestions.AddRange(legacy, unassigned);
        await db.SaveChangesAsync();
        var originalIndices = section.Questions.Select(q => q.Idx).ToArray();
        var proto = ProtoHelper.MapToProto(exam, false);
        var groups = proto.Sections[0].QuestionGroups;
        Assert.Equal(3, groups.Count);
        Assert.Equal("Public prompt", Assert.Single(groups[0].Questions).PromptMd);
        Assert.Equal("Legacy", Assert.Single(groups[1].Questions).PromptMd);
        Assert.Equal("Unassigned", Assert.Single(groups[2].Questions).PromptMd);
        Assert.Equal(new[] { 1, 2, 3 }, groups.SelectMany(g => g.Questions).Select(q => q.Idx));
        Assert.Equal(originalIndices, section.Questions.Select(q => q.Idx));
        host.Http.DefaultRequestHeaders.Add("X-Internal-Key", ExamServiceTestHost.Key);
        foreach (var url in new[] { $"/api/public/exam/getby/{exam.Slug}", $"/api/internal/exams/{exam.Id}/delivery?showAnswers=false" })
        {
            var response = await host.Http.GetAsync(url);
            response.EnsureSuccessStatusCode();
            using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
            var delivered = document.RootElement.GetProperty("data").GetProperty("sections")[0];
            Assert.Empty(delivered.GetProperty("questions").EnumerateArray());
            var httpGroups = delivered.GetProperty("questionGroups").EnumerateArray().ToArray();
            Assert.Equal(3, httpGroups.Length);
            for (var i = 0; i < 3; i++)
            {
                Assert.Equal(groups[i].Id, httpGroups[i].GetProperty("id").GetString());
                Assert.Equal(groups[i].StartIdx, httpGroups[i].GetProperty("startIdx").GetInt32());
                Assert.Equal(groups[i].Questions[0].PromptMd, Assert.Single(httpGroups[i].GetProperty("questions").EnumerateArray()).GetProperty("promptMd").GetString());
            }
        }
    }

    [Fact]
    public void Overlapping_legacy_bounds_do_not_duplicate_questions_or_override_explicit_membership()
    {
        var exam = ExamServiceTestHost.Paper();
        var section = exam.Sections[0];
        section.QuestionGroups.Add(new ExamQuestionGroup { Id = Guid.NewGuid(), SectionId = section.Id, Idx = 2, StartIdx = 1, EndIdx = 1 });
        section.Questions.Add(NewQuestion(section, 1, "Ambiguous legacy", null));
        var groups = ExamDeliveryLayout.Groups(section);
        Assert.Equal("Public prompt", Assert.Single(groups[0].Questions).PromptMd);
        Assert.Empty(groups[1].Questions);
        Assert.Equal("Ambiguous legacy", Assert.Single(groups[2].Questions).PromptMd);
        Assert.Equal(2, groups.SelectMany(g => g.Questions).Select(q => q.Id).Distinct().Count());
    }

    [Fact]
    public async Task Public_rest_flow_bank_is_solution_order_independent_and_published_only()
    {
        await using var host = await ExamServiceTestHost.Start();
        using var scope = host.App.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        var exam = await db.Exams.Include(e => e.Sections).ThenInclude(s => s.Questions).SingleAsync(e => e.Id == host.ExamId);
        var question = exam.Sections[0].Questions[0];
        question.Type = QuestionType.FlowChart;
        question.OrderCorrects = ["step-c", "step-a", "step-b"];
        await db.SaveChangesAsync();
        async Task<string> Bank()
        {
            var response = await host.Http.GetAsync($"/api/public/exam/getby/{exam.Slug}");
            response.EnsureSuccessStatusCode();
            var text = await response.Content.ReadAsStringAsync();
            Assert.DoesNotContain("private-", text);
            Assert.DoesNotContain("orderCorrects", text);
            using var json = JsonDocument.Parse(text);
            var delivered = json.RootElement.GetProperty("data").GetProperty("sections")[0].GetProperty("questionGroups")[0].GetProperty("questions")[0];
            Assert.Equal("public-word", delivered.GetProperty("wordList")[0].GetString());
            var nodes = delivered.GetProperty("flowChartNodes");
            Assert.Equal(new[] { "step-a", "step-b", "step-c" }, nodes.EnumerateArray().Select(n => n.GetProperty("key").GetString()));
            return nodes.GetRawText();
        }
        var before = await Bank();
        question.OrderCorrects.Reverse();
        db.Entry(question).Property(q => q.OrderCorrects).IsModified = true;
        await db.SaveChangesAsync();
        Assert.Equal(before, await Bank());
        exam.Status = ExamStatus.Draft;
        await db.SaveChangesAsync();
        Assert.Equal(System.Net.HttpStatusCode.NotFound, (await host.Http.GetAsync($"/api/public/exam/getby/{exam.Slug}")).StatusCode);
    }

    [Fact]
    public async Task Exam_producer_snapshot_survives_attempt_resume_autosave_submit_and_result_offline_gate()
    {
        await using var fixture = await AttemptAnswerFixture.Create(seedAnswer: false);
        var exam = ExamServiceTestHost.Paper();
        var section = exam.Sections[0];
        section.Id = fixture.SectionId;
        var group = section.QuestionGroups[0];
        group.SectionId = section.Id;
        group.StartIdx = 40; // Deliberately stale bounds must not discard explicit members.
        group.EndIdx = 45;
        var question = section.Questions[0];
        question.Id = fixture.QuestionId;
        question.SectionId = section.Id;
        question.Options[0].Id = fixture.OptionId;
        question.Options[0].QuestionId = question.Id;
        var proto = ProtoHelper.MapToProto(exam, true);
        using var snapshot = JsonDocument.Parse(Google.Protobuf.JsonFormatter.Default.Format(proto));
        var raw = snapshot.RootElement.GetRawText();
        var attempt = await fixture.Db.Attempts.SingleAsync();
        attempt.ExamId = exam.Id;
        attempt.PaperJson = snapshot;
        await fixture.Db.SaveChangesAsync();
        fixture.Db.ChangeTracker.Clear();
        var resumed = await fixture.Service.StartAttempt(new(exam.Id), default);
        Assert.Equal(200, ((IStatusCodeHttpResult)resumed).StatusCode);
        var publicResponse = JsonSerializer.Serialize(((IValueHttpResult)resumed).Value);
        Assert.DoesNotContain("private-", publicResponse);
        Assert.Equal(200, ((IStatusCodeHttpResult)await fixture.Service.Autosave(fixture.AttemptId,
            new([new(fixture.QuestionId, Guid.NewGuid(), [fixture.OptionId], null)], null), default)).StatusCode);
        Assert.Equal(200, ((IStatusCodeHttpResult)await fixture.Service.Submit(fixture.AttemptId, default)).StatusCode);
        var answer = await fixture.ReadAnswer();
        Assert.Equal(fixture.SectionId, answer.SectionId);
        Assert.True(answer.IsCorrect);
        Assert.Equal(1m, answer.AwardedPoints);
        Assert.Equal(200, ((IStatusCodeHttpResult)await fixture.Service.GetResult(fixture.AttemptId, default)).StatusCode);
        Assert.Equal(raw, (await fixture.Db.Attempts.AsNoTracking().SingleAsync()).PaperJson!.RootElement.GetRawText());
    }

    private static ExamQuestion NewQuestion(ExamSection section, int idx, string prompt, Guid? groupId) => new()
    {
        Id = Guid.NewGuid(), SectionId = section.Id, Idx = idx, GroupId = groupId,
        Type = QuestionType.MultipleChoiceSingle, Skill = "READING", PromptMd = prompt
    };
}
