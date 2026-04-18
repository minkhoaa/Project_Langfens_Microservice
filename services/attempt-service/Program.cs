using System.Text.Json;
using System.Text.Json.Serialization;
using Shared.Bootstrap;
using Microsoft.EntityFrameworkCore;
using attempt_service.Features.Analytics;
using attempt_service.Features.Attempt;
using attempt_service.Features.Attempt.AttemptEndpoint;
using attempt_service.Features.Bookmarks;
using attempt_service.Features.Helpers;
using attempt_service.Features.Notes;
using attempt_service.Features.RabbitMq;
using attempt_service.Features.StudyPlan;
using attempt_service.Infrastructure.Persistence;
using MassTransit;
using Shared.Grpc.ExamInternal;

var builder = WebApplication.CreateBuilder(args);

// ── Helpers ───────────────────────────────────────────────────────────────────
static string EnvOrDefault(string key, string fallback) =>
    Environment.GetEnvironmentVariable(key) ?? fallback;

// ── Shared bootstrap (JWT, CORS, Swagger, JSON) ───────────────────────────────
builder.Services.AddLangfensAuth(key => Environment.GetEnvironmentVariable(key));
builder.Services.AddAttemptAuthorization();
builder.Services.AddLangfensCors();
builder.Services.AddLangfensSwagger("Attempt Service");
builder.Services.AddLangfensJson();

// ── HTTP/2 for gRPC ──────────────────────────────────────────────────────────
AppContext.SetSwitch("System.Net.Http.SocketsHttpHandler.Http2UnencryptedSupport", true);

// ── gRPC client ───────────────────────────────────────────────────────────────
builder.Services
    .AddGrpcClient<ExamInternal.ExamInternalClient>(o =>
    {
        o.Address = new Uri("http://exam-service:8081");
    })
    .ConfigurePrimaryHttpMessageHandler(() => new SocketsHttpHandler
    {
        EnableMultipleHttp2Connections = true
    });

// ── Internal HTTP client ─────────────────────────────────────────────────────
var internalApiKey = Environment.GetEnvironmentVariable("EXAMSERVICE__INTERNAL__API__KEY")
    ?? throw new InvalidOperationException("EXAMSERVICE__INTERNAL__API__KEY is required");
builder.Services.AddHttpClient("ExamServiceInternal", (sp, http) =>
{
    http.BaseAddress = new Uri(EnvOrDefault("EXAMSERVICE__EXAM__ADDRESS", "http://exam-service:8080"));
    http.DefaultRequestHeaders.Add("X-Internal-Key", internalApiKey);
});

// ── Database ─────────────────────────────────────────────────────────────────
builder.Services.AddDbContext<AttemptDbContext>(opts =>
    opts.UseNpgsql(EnvOrDefault("CONNECTIONSTRING__ATTEMPT",
        "Host=attempt-database;Port=5432;Database=attempt-db;Username=attempt;Password=attempt")));

// ── RabbitMQ ───────────────────────────────────────────────────────────────────
var rabbitConfig = LangfensBootstrapExtensions.BuildRabbitMqConfig(
    key => Environment.GetEnvironmentVariable(key));
builder.Services.AddMassTransit(cfg =>
{
    cfg.AddConsumer<WritingGradedConsumer>();
    cfg.AddConsumer<SpeakingGradedConsumer>();
    cfg.UsingRabbitMq((ctx, bus) =>
    {
        bus.ConfigureRabbitMqHost(rabbitConfig);
        bus.ReceiveEndpoint("writing-graded-response", e => e.ConfigureConsumer<WritingGradedConsumer>(ctx));
        bus.ReceiveEndpoint("speaking-graded-response", e => e.ConfigureConsumer<SpeakingGradedConsumer>(ctx));
    });
});

// ── DI: Domain services ──────────────────────────────────────────────────────
builder.Services.AddScoped<IAttemptService, AttemptService>();
builder.Services.AddScoped<IExamGateway, ExamGateway>();
builder.Services.AddScoped<IUserContext, UserContext>();
builder.Services.AddScoped<IAnalyticsService, AnalyticsService>();
builder.Services.AddScoped<IBandPredictorService, BandPredictorService>();
builder.Services.AddScoped<IRecommendationService, RecommendationService>();
builder.Services.AddScoped<IStudyPlanService, StudyPlanService>();
builder.Services.AddScoped<BookmarkService>();
builder.Services.AddScoped<NoteService>();

// ── DI: Graders ───────────────────────────────────────────────────────────────
builder.Services.AddSingleton<IAnswerKeyBuilder, AnswerKeyBuilder>();
builder.Services.AddSingleton<IBuildQuestionIdSet, BuildQuestionIdSet>();
builder.Services.AddSingleton<IQuestionIndex, QuestionIndex>();
builder.Services.AddSingleton<IIndexBuilder, IndexBuilder>();
builder.Services.AddSingleton<IAnswerValidator, AnswerValidator>();

builder.Services.AddSingleton<SingleChoiceGrader>();
builder.Services.AddSingleton<MultipleChoiceGrader>();
builder.Services.AddSingleton<CompletionGrader>();
builder.Services.AddSingleton<LabelGrader>();
builder.Services.AddSingleton<MatchingHeadingGrader>();
builder.Services.AddSingleton<FlowChartGrader>();
builder.Services.AddSingleton<ShortAnswerGrader>();

builder.Services.AddSingleton<IQuestionGraderRegistration, SingleChoiceGraderRegistration>();
builder.Services.AddSingleton<IQuestionGraderRegistration, MultipleChoiceGraderRegistration>();
builder.Services.AddSingleton<IQuestionGraderRegistration, CompletionGraderRegistration>();
builder.Services.AddSingleton<IQuestionGraderRegistration, LabelGraderRegistration>();
builder.Services.AddSingleton<IQuestionGraderRegistration, MatchingHeadingGraderRegistration>();
builder.Services.AddSingleton<IQuestionGraderRegistration, FlowChartGraderRegistration>();
builder.Services.AddSingleton<IQuestionGraderRegistration, ShortAnswerGraderRegistration>();
builder.Services.AddSingleton<IQuestionGraderFactory, QuestionGraderFactory>();
builder.Services.AddScoped<IPlacementWorkflow, PlacementWorkflow>();

// ── DI: Azure OpenAI (optional) ───────────────────────────────────────────────
var azureEndpoint = Environment.GetEnvironmentVariable("AZURE_OPENAI__ENDPOINT");
var azureApiKey   = Environment.GetEnvironmentVariable("AZURE_OPENAI__APIKEY");
var azureDeployment = EnvOrDefault("AZURE_OPENAI__DEPLOYMENT", "gpt-4o-mini");
if (!string.IsNullOrEmpty(azureEndpoint) && !string.IsNullOrEmpty(azureApiKey))
{
    builder.Services.AddSingleton(_ => new OpenAI.Chat.ChatClient(
        model: azureDeployment,
        credential: new System.ClientModel.ApiKeyCredential(azureApiKey),
        options: new OpenAI.OpenAIClientOptions { Endpoint = new Uri(azureEndpoint) }
    ));
    builder.Services.AddScoped<IAiInsightsService, AiInsightsService>();
    Console.WriteLine($"[INFO] Azure OpenAI enabled with deployment: {azureDeployment}");
}
else
{
    Console.WriteLine("[WARN] Azure OpenAI not configured, AI insights will be disabled");
}

builder.Services.AddHttpContextAccessor();
builder.Services.AddResponseCompression();

// ── App ──────────────────────────────────────────────────────────────────────
var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AttemptDbContext>();
    var all     = db.Database.GetMigrations().ToList();
    var applied = (await db.Database.GetAppliedMigrationsAsync()).ToList();
    var pending = (await db.Database.GetPendingMigrationsAsync()).ToList();
    Console.WriteLine($"[EF] All:     {string.Join(", ", all)}");
    Console.WriteLine($"[EF] Applied: {string.Join(", ", applied)}");
    Console.WriteLine($"[EF] Pending: {string.Join(", ", pending)}");
    await db.Database.MigrateAsync();
}

app.UseResponseCompression();
app.UseCors("FE");
app.UseSwagger();
app.UseSwaggerUI();
app.UseAuthentication();
app.UseAuthorization();
app.MapAttemptEndpoint();
app.MapAdminEndpoint();
app.MapAnalyticsEndpoints();
app.MapStudyPlanEndpoints();
app.MapBookmarkEndpoints();
app.MapNoteEndpoints();
app.Run();
