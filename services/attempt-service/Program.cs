using System.Text.Json;
using System.Text.Json.Serialization;
using Aspire.Npgsql.EntityFrameworkCore.PostgreSQL;
using HealthChecks.RabbitMQ;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Shared.Bootstrap;
using attempt_service.Features.Analytics;
using attempt_service.Features.Attempt;
using attempt_service.Features.Attempt.AttemptEndpoint;
using attempt_service.Features.Bookmarks;
using attempt_service.Features.Helpers;
using attempt_service.Features.Helpers.Listening;
using attempt_service.Features.Helpers.RagExplainer;
using attempt_service.Features.Helpers.Reading;
using attempt_service.Features.Notes;
using attempt_service.Features.RabbitMq;
using attempt_service.Features.StudyPlan;
using attempt_service.Infrastructure.Persistence;
using MassTransit;
using Shared.Grpc.ExamInternal;

// ── HTTP/2 cleartext (h2c) support — MUST be set before any HttpClient/gRPC setup ──
AppContext.SetSwitch("System.Net.Http.SocketsHttpHandler.Http2UnencryptedSupport", true);

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

// ── gRPC client ───────────────────────────────────────────────────────────────
var examGrpcAddress = Environment.GetEnvironmentVariable("ExamService__GrpcAddress")
    ?? "http://exam-service:8081";
builder.Services
    .AddGrpcClient<ExamInternal.ExamInternalClient>(o =>
    {
        o.Address = new Uri(examGrpcAddress);
    })
    .ConfigurePrimaryHttpMessageHandler(() => new SocketsHttpHandler
    {
        EnableMultipleHttp2Connections = true,
        // Required for cleartext HTTP/2 (h2c) inside Docker without TLS
        // AppContext switch alone is not reliable after runtime init
        PooledConnectionIdleTimeout = TimeSpan.FromMinutes(5),
    });


// ── Internal HTTP client ─────────────────────────────────────────────────────
var internalApiKey = Environment.GetEnvironmentVariable("EXAMSERVICE__INTERNAL__API__KEY")
    ?? throw new InvalidOperationException("EXAMSERVICE__INTERNAL__API__KEY is required");
builder.Services.AddHttpClient("ExamServiceInternal", (sp, http) =>
{
    http.BaseAddress = new Uri(EnvOrDefault("EXAMSERVICE__EXAM__ADDRESS", "http://exam-service:8080"));
    http.DefaultRequestHeaders.Add("X-Internal-Key", internalApiKey);
});

// ── AI service (RAG explainers) ──────────────────────────────────────────
// When run via Aspire, AI_SERVICE_URL is set by AppHost to the internal
// docker-network endpoint (http://ai-service:8080). When run standalone
// via `dotnet run`, the URL is dynamic — Aspire allocates a different
// host port per launch. Auto-discover it by asking the Docker socket
// for the running ai-service container's host port. The user can still
// override by setting AI_SERVICE_URL explicitly.
var aiServiceUrl = EnvOrDefault("AI_SERVICE_URL", null) ?? DiscoverAiServiceUrl();
if (string.IsNullOrEmpty(aiServiceUrl))
{
    aiServiceUrl = "http://localhost:8092";
}
Console.WriteLine($"[INFO] AI service URL: {aiServiceUrl}");
builder.Services.AddHttpClient<IReadingExplainerClient, ReadingExplainerClient>(http =>
{
    http.BaseAddress = new Uri(aiServiceUrl);
    http.Timeout = TimeSpan.FromSeconds(10);
});
builder.Services.AddHttpClient<IListeningExplainerClient, ListeningExplainerClient>(http =>
{
    http.BaseAddress = new Uri(aiServiceUrl);
    http.Timeout = TimeSpan.FromSeconds(10);
});

// ── RabbitMQ ───────────────────────────────────────────────────────────────────
var rabbitHost = EnvOrDefault("RABBITMQ__HOST", "localhost");
var rabbitUser = Environment.GetEnvironmentVariable("RABBITMQ__USERNAME")
    ?? throw new InvalidOperationException("RABBITMQ__USERNAME is required");
var rabbitPass = Environment.GetEnvironmentVariable("RABBITMQ__PASSWORD")
    ?? throw new InvalidOperationException("RABBITMQ__PASSWORD is required");
var rabbitVhost = EnvOrDefault("RABBITMQ__VHOST", "/");
var rabbitPort = ushort.TryParse(Environment.GetEnvironmentVariable("RABBITMQ__PORT"), out var port) ? port : (ushort)5672;

// ── Database (Aspire) ──────────────────────────────────────────────────────────
// Disable retrying execution strategy because Submit uses explicit transactions
builder.AddNpgsqlDbContext<AttemptDbContext>("attempt-db", configureDbContextOptions: opts =>
{
    opts.UseNpgsql(npgsqlOpts => npgsqlOpts.ExecutionStrategy(deps => new NonRetryingExecutionStrategy(deps)));
});

// ── Health checks ───────────────────────────────────────────────────────────
var attemptConnectionString = builder.Configuration.GetConnectionString("attempt-db")
    ?? throw new InvalidOperationException("attempt-db connection string is required");

var amqpUri = new Uri($"amqp://{rabbitUser}:{rabbitPass}@{rabbitHost}:{rabbitPort}/{rabbitVhost}");

builder.Services.AddHealthChecks()
    .AddNpgSql(attemptConnectionString, name: "attempt-db", failureStatus: HealthStatus.Unhealthy, tags: new[] { "db", "postgresql" })
    .AddRabbitMQ(o => o.ConnectionUri = amqpUri, name: "rabbitmq", failureStatus: HealthStatus.Unhealthy, tags: new[] { "messaging" });

// ── MassTransit (RabbitMQ) ────────────────────────────────────────────────────
builder.Services.AddMassTransit(cfg =>
{
    cfg.AddConsumer<WritingGradedConsumer>();
    cfg.AddConsumer<SpeakingGradedConsumer>();
    cfg.UsingRabbitMq((ctx, bus) =>
    {
        bus.Host(rabbitHost, rabbitPort, rabbitVhost, h =>
        {
            h.Username(rabbitUser);
            h.Password(rabbitPass);
        });
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

// ── DI: RAG explainer orchestrator ───────────────────────────────────────
builder.Services.AddSingleton<ISectionContextLookup, SectionContextLookup>();
builder.Services.AddScoped<ISkillRagExplainer, SkillRagExplainer>();

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

static string? DiscoverAiServiceUrl()
{
    // When attempt-service runs outside Aspire (e.g. `dotnet run` from VS
    // Code) the Aspire-allocated host port is not known to us. Probe the
    // Docker socket for a running ai-service container and extract the
    // host port bound to container port 8080. Returns null on any failure
    // so the caller falls back to the legacy localhost:8092 default.
    try
    {
        var socket = Environment.GetEnvironmentVariable("DOCKER_HOST") ?? "unix:///var/run/docker.sock";
        if (!socket.StartsWith("unix://")) return null;
        var sockPath = socket["unix://".Length..];

        // Use a short-lived curl probe via shell: docker inspect --format
        // is simpler and more portable than binding a Docker.DotNet client
        // for this single use case.
        var psi = new System.Diagnostics.ProcessStartInfo
        {
            FileName = "docker",
            ArgumentList = {
                "ps", "--filter", "ancestor=ai-service", "--filter", "status=running",
                "-q"
            },
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false,
        };
        using var p = System.Diagnostics.Process.Start(psi);
        if (p is null) return null;
        var cid = p.StandardOutput.ReadToEnd().Trim();
        p.WaitForExit(2000);
        if (string.IsNullOrEmpty(cid)) return null;

        var psi2 = new System.Diagnostics.ProcessStartInfo
        {
            FileName = "docker",
            ArgumentList = { "inspect", "--format", "{{index (indexOf .HostPort \"\") }}", cid },
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false,
        };
        // We actually need a JSON path; the cleanest cross-platform call is
        // `docker port <cid> 8080/tcp` which prints e.g. "0.0.0.0:32832".
        var psi3 = new System.Diagnostics.ProcessStartInfo
        {
            FileName = "docker",
            ArgumentList = { "port", cid, "8080/tcp" },
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false,
        };
        using var p3 = System.Diagnostics.Process.Start(psi3);
        if (p3 is null) return null;
        var portLine = p3.StandardOutput.ReadToEnd().Trim();
        p3.WaitForExit(2000);
        // Format: "127.0.0.1:32832" or "0.0.0.0:32832"
        var parts = portLine.Split('\n', StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length == 0) return null;
        var firstPort = parts[0].Trim();
        var colon = firstPort.LastIndexOf(':');
        if (colon < 0) return null;
        var port = firstPort[(colon + 1)..];
        return $"http://127.0.0.1:{port}";
    }
    catch
    {
        return null;
    }
}

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

app.MapHealthChecks("/health", new HealthCheckOptions
{
    ResponseWriter = async (context, report) =>
    {
        context.Response.ContentType = "application/json";
        var result = new
        {
            status = report.Status.ToString(),
            checks = report.Entries.Select(e => new
            {
                name = e.Key,
                status = e.Value.Status.ToString(),
                description = e.Value.Description,
                duration = e.Value.Duration.TotalMilliseconds
            })
        };
        await context.Response.WriteAsync(JsonSerializer.Serialize(result, new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase }));
    }
});

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

public partial class Program { }