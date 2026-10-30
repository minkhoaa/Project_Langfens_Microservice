using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using exam_service.Domains.Entities;
using exam_service.Features.Exams.InternalEndpoint;
using exam_service.Features.Exams.PublicEndpoint;
using exam_service.Features.QuestionBank;
using exam_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.TestHost;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using Shared.ExamDto.Contracts.Exam.Enums;
using Shared.Security.Claims;

namespace attempt_service.Tests.Helpers;

// No service Program, migrations, network database, or startup seeders are run.
internal sealed class ExamServiceTestHost : IAsyncDisposable
{
    public WebApplication App { get; }
    public HttpClient Http { get; }
    public Guid ExamId { get; }
    public const string Key = "offline-internal-key";
    private readonly string signingKey;

    private ExamServiceTestHost(WebApplication app, Guid examId, string signingKey)
    {
        this.signingKey = signingKey;
        App = app;
        Http = app.GetTestClient();
        ExamId = examId;
    }

    public static async Task<ExamServiceTestHost> Start(string? configuredKey = Key, bool grouped = true)
    {
        var builder = WebApplication.CreateBuilder();
        builder.WebHost.UseTestServer();
        builder.Logging.ClearProviders();
        builder.Configuration.AddInMemoryCollection(new Dictionary<string, string?>
        {
            ["EXAMSERVICE:INTERNAL:API:KEY"] = configuredKey
        });
        var database = Guid.NewGuid().ToString();
        builder.Services.AddScoped<ExamDbContext>(_ => new OfflineExamDbContext(OfflineExamDbContext.Options(database)));
        builder.Services.AddScoped<IInternalExamService, InternalExamService>();
        builder.Services.AddScoped<IExamService, exam_service.Features.Exams.PublicEndpoint.ExamService>();
        builder.Services.AddScoped<IQuestionBankService, QuestionBankService>();
        builder.Services.AddGrpc();
        var signingKey = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64));
        builder.Services.AddLangfensAuth(key => key switch
        {
            "JwtSettings__Issuer" => "offline-issuer",
            "JwtSettings__Audience" => "offline-audience",
            "JwtSettings__SignKey" => signingKey,
            _ => null
        });
        builder.Services.AddExamAuthorization();
        var app = builder.Build();
        app.UseAuthentication();
        app.UseAuthorization();
        app.MapInternalExamEndpoint();
        app.MapPublicExamEndpoints();
        app.MapGrpcService<ExamInternalGrpcService>().RequireAuthorization(InternalExamAccess.Policy);
        app.MapQuestionBankEndpoints();
        var exam = Paper();
        if (!grouped)
        {
            exam.Sections[0].QuestionGroups.Clear();
            exam.Sections[0].Questions[0].GroupId = null;
            exam.Sections[0].Questions[0].Group = null;
        }
        using (var scope = app.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            db.Exams.AddRange(exam, Paper(ExamStatus.Draft), Paper(ExamStatus.Archived, "DRAFT_ONLY_TYPE"));
            await db.SaveChangesAsync();
        }
        await app.StartAsync();
        return new ExamServiceTestHost(app, exam.Id, signingKey);
    }

    public string Jwt(string role) => new JwtSecurityTokenHandler().WriteToken(new JwtSecurityToken(
        "offline-issuer", "offline-audience", [new Claim(CustomClaims.Roles, role)],
        expires: DateTime.UtcNow.AddMinutes(5),
        signingCredentials: new SigningCredentials(new SymmetricSecurityKey(Encoding.UTF8.GetBytes(signingKey)),
            SecurityAlgorithms.HmacSha256)));

    public static Exam Paper(string status = ExamStatus.Published, string type = QuestionType.MultipleChoiceSingle)
    {
        var exam = new Exam { Id = Guid.NewGuid(), Slug = Guid.NewGuid().ToString(), Title = status, Status = status };
        var section = new ExamSection { Id = Guid.NewGuid(), ExamId = exam.Id, Idx = 1, Title = "Section", Exam = exam };
        var question = new ExamQuestion
        {
            Id = Guid.NewGuid(), SectionId = section.Id, Section = section, Idx = 1,
            Type = type, Skill = "READING", PromptMd = "Public prompt", ExplanationMd = "private-explanation",
            ModelAnswers = ["private-model"], WordList = ["public-word"],
            BlankAcceptTexts = new() { ["1"] = ["private-blank"] },
            BlankAcceptRegex = new() { ["1"] = ["private-regex"] },
            MatchPairs = new() { ["1"] = ["private-match", "display"] },
            OrderCorrects = ["step-b", "step-a"],
            ShortAnswerAcceptTexts = ["private-short"], ShortAnswerAcceptRegex = ["private-short-regex"]
        };
        question.Options.Add(new ExamOption { Id = Guid.NewGuid(), QuestionId = question.Id, Idx = 1, ContentMd = "Public option", IsCorrect = true });
        section.Questions.Add(question);
        var group = new ExamQuestionGroup
        {
            Id = Guid.NewGuid(), SectionId = section.Id, Idx = 1, StartIdx = 1, EndIdx = 1,
            InstructionMd = "Public instruction", Questions = [question]
        };
        question.GroupId = group.Id;
        question.Group = group;
        section.QuestionGroups.Add(group);
        exam.Sections.Add(section);
        return exam;
    }

    public async ValueTask DisposeAsync()
    {
        Http.Dispose();
        await App.DisposeAsync();
    }
}
