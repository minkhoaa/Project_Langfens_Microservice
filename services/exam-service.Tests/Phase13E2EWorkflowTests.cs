using System.Data.Common;
using System.IdentityModel.Tokens.Jwt;
using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Security.Claims;
using System.Text;
using System.Text.Json;
using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper;
using exam_service.Features.ReadingPaper.Contracts;
using exam_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.IdentityModel.Tokens;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Exam.Enums;
using Xunit;

namespace exam_service.Tests;

public sealed class RunLoadPauseInterceptor : DbCommandInterceptor
{
    private int _paused;
    public TaskCompletionSource ReachedRunLoad { get; } = new(TaskCreationOptions.RunContinuationsAsynchronously);
    public TaskCompletionSource ResumeRunLoad { get; } = new(TaskCreationOptions.RunContinuationsAsynchronously);

    public override async ValueTask<DbDataReader> ReaderExecutedAsync(
        DbCommand command,
        CommandExecutedEventData eventData,
        DbDataReader result,
        CancellationToken cancellationToken = default)
    {
        if (command.CommandText.Contains("reading_paper_runs", StringComparison.OrdinalIgnoreCase) &&
            Interlocked.Exchange(ref _paused, 1) == 0)
        {
            ReachedRunLoad.TrySetResult();
            await ResumeRunLoad.Task.WaitAsync(cancellationToken);
        }

        return result;
    }
}


public sealed class Phase13ExamApiFactory : WebApplicationFactory<exam_service.Program>
{
    private readonly string _connection;
    private readonly DbCommandInterceptor? _dbInterceptor;
    private readonly HttpMessageHandler? _aiHandler;
    public const string TestSigningKey = "SuperSecretTestingKeyPhase13MustBe32BytesLong!";
    public const string TestInternalApiKey = "test-phase13-internal-api-key-32chars";

    static Phase13ExamApiFactory()
    {
        Environment.SetEnvironmentVariable("JwtSettings__Issuer", "https://auth.langfens.local");
        Environment.SetEnvironmentVariable("JwtSettings__Audience", "langfens-api");
        Environment.SetEnvironmentVariable("JwtSettings__SignKey", TestSigningKey);
        Environment.SetEnvironmentVariable("EXAMSERVICE__INTERNAL__API__KEY", TestInternalApiKey);
        LoadLoopCapsEnv(null);
    }

    private static void LoadLoopCapsEnv(IWebHostBuilder? builder)
    {
        var envPath = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "../../../../../deploy/envs/loop-caps.env"));
        if (!File.Exists(envPath))
            envPath = Path.GetFullPath("deploy/envs/loop-caps.env");
        if (File.Exists(envPath))
        {
            foreach (var line in File.ReadAllLines(envPath))
            {
                var trimmed = line.Trim();
                if (string.IsNullOrWhiteSpace(trimmed) || trimmed.StartsWith("#")) continue;
                var eqIdx = trimmed.IndexOf('=');
                if (eqIdx > 0)
                {
                    var k = trimmed[..eqIdx].Trim();
                    var v = trimmed[(eqIdx + 1)..].Trim();
                    Environment.SetEnvironmentVariable(k, v);
                    builder?.UseSetting(k, v);
                }
            }
        }
    }

    public Phase13ExamApiFactory(
        string connection,
        HttpMessageHandler? aiHandler = null,
        DbCommandInterceptor? dbInterceptor = null)
    {
        _connection = connection;
        _aiHandler = aiHandler;
        _dbInterceptor = dbInterceptor;
        Environment.SetEnvironmentVariable("JwtSettings__Issuer", "https://auth.langfens.local");
        Environment.SetEnvironmentVariable("JwtSettings__Audience", "langfens-api");
        Environment.SetEnvironmentVariable("JwtSettings__SignKey", TestSigningKey);
        Environment.SetEnvironmentVariable("EXAMSERVICE__INTERNAL__API__KEY", TestInternalApiKey);
        Environment.SetEnvironmentVariable("ConnectionStrings__exam-db", _connection);
        LoadLoopCapsEnv(null);
    }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");
        builder.UseSetting("JwtSettings__Issuer", "https://auth.langfens.local");
        builder.UseSetting("JwtSettings__Audience", "langfens-api");
        builder.UseSetting("JwtSettings__SignKey", TestSigningKey);
        builder.UseSetting("ConnectionStrings__exam-db", _connection);
        builder.UseSetting("EXAMSERVICE__INTERNAL__API__KEY", TestInternalApiKey);
        LoadLoopCapsEnv(builder);

        builder.ConfigureServices(services =>
        {
            // Remove default background worker so tests control worker execution deterministically
            var workerDescriptors = services.Where(d =>
                d.ServiceType == typeof(IHostedService) &&
                d.ImplementationType == typeof(ReadingPaperWorker)).ToList();
            foreach (var w in workerDescriptors) services.Remove(w);

            // Replace DbContext to use our test connection with warning suppression
            var dbDescriptors = services.Where(d =>
                d.ServiceType == typeof(DbContextOptions<ExamDbContext>) ||
                d.ServiceType == typeof(ExamDbContext)).ToList();
            foreach (var d in dbDescriptors) services.Remove(d);

            services.AddDbContext<ExamDbContext>(options =>
            {
                options.UseNpgsql(_connection, npg =>
                {
                    npg.ConfigureDataSource(dataSource => dataSource.EnableDynamicJson());
                    npg.EnableRetryOnFailure();
                });
                options.ConfigureWarnings(w => w.Ignore(RelationalEventId.PendingModelChangesWarning));
                if (_dbInterceptor is not null) options.AddInterceptors(_dbInterceptor);
            });

            // Replace ReadingPaperAiClient with mock handler if supplied
            if (_aiHandler != null)
            {
                services.AddHttpClient<ReadingPaperAiClient>(client =>
                {
                    client.BaseAddress = new Uri("http://generation-service:8080/");
                    client.Timeout = TimeSpan.FromMinutes(45);
                    client.DefaultRequestHeaders.Add(CheckpointService.InternalApiKeyHeader, TestInternalApiKey);
                }).ConfigurePrimaryHttpMessageHandler(() => _aiHandler);
            }
        });
    }

    public async Task ResetJobsAsync()
    {
        using var scope = Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        await db.Database.EnsureCreatedAsync();
        await db.ReadingPaperArtifactHeads.ExecuteDeleteAsync();
        await db.ReadingPaperArtifactDependencies.ExecuteDeleteAsync();
        await db.ReadingPaperArtifacts.ExecuteDeleteAsync();
        await db.ReadingPaperRuns.ExecuteDeleteAsync();
        await db.ReadingPaperJobs.ExecuteDeleteAsync();
    }

    public HttpClient CreateAdminClient()
    {
        var client = CreateClient();
        var token = GenerateAdminJwtToken(TestSigningKey);
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
        return client;
    }

    private static string GenerateAdminJwtToken(string signKey)
    {
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(signKey));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var claims = new[]
        {
            new Claim("sub", Guid.NewGuid().ToString()),
            new Claim("roles", "ADMIN"),
            new Claim("role", "ADMIN"),
            new Claim(ClaimTypes.Role, "ADMIN")
        };
        var token = new JwtSecurityToken(
            issuer: "https://auth.langfens.local",
            audience: "langfens-api",
            claims: claims,
            expires: DateTime.UtcNow.AddHours(1),
            signingCredentials: creds
        );
        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}

[Collection("DatabaseTests")]
public class Phase13E2EWorkflowTests
{
    private const string DefaultConn = "Host=localhost;Port=5433;Database=exam_test_phase13;Username=exam;Password=exam";

    private static string ConnectionString =>
        Environment.GetEnvironmentVariable("READING_TEST_POSTGRES")
        ?? DefaultConn;

    private static ReadingSource CreateSampleSource(int index, string? pmcid = null, string? title = null, string content = "Sample academic text content for IELTS reading passage synthesis.")
    {
        var validPmcid = pmcid ?? $"PMC{1000000 + index}";
        return new ReadingSource(
            Pmcid: validPmcid,
            Title: title ?? $"Source Title {index}",
            Doi: $"10.1000/{Guid.NewGuid():N}",
            License: "CC BY 4.0",
            Authors: "Dr. Lead Researcher et al.",
            WordCount: 850,
            Url: $"https://europepmc.org/articles/{validPmcid}",
            OpenAlexId: $"W1000{index}",
            TopicId: "T100",
            SourceType: "PMC",
            Metadata: new Dictionary<string, string> { ["domain"] = "Cognitive Science" },
            Content: content,
            ContentPreview: content.Length > 100 ? content[..100] : content
        );
    }

    private sealed class MockStreamHandler(string ndjsonPayload) : HttpMessageHandler
    {
        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken ct)
        {
            var content = new StringContent(ndjsonPayload, Encoding.UTF8, "application/x-ndjson");
            var response = new HttpResponseMessage(HttpStatusCode.OK) { Content = content };
            return Task.FromResult(response);
        }
    }

    private sealed class ControllableAiHandler(List<ReadingGeneratedSection> sections, int failOnSection = -1) : HttpMessageHandler
    {
        public Dictionary<int, int> Calls { get; } = new();

        protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken ct)
        {
            var path = request.RequestUri?.AbsolutePath ?? "";
            if (path.Contains("section", StringComparison.OrdinalIgnoreCase))
            {
                using var doc = JsonDocument.Parse(await request.Content!.ReadAsStringAsync(ct));
                var index = doc.RootElement.GetProperty("index").GetInt32();
                Calls[index] = Calls.GetValueOrDefault(index, 0) + 1;

                if (index == failOnSection)
                {
                    return new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("{\"error\":\"Simulated provider failure\"}", Encoding.UTF8, "application/json")
                    };
                }

                var sec = sections[index - 1];
                return new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent(JsonSerializer.Serialize(sec, ReadingPaperRules.Json), Encoding.UTF8, "application/json")
                };
            }

            return new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent("{}", Encoding.UTF8, "application/json")
            };
        }
    }

    private static async Task WaitForStatusAsync(Phase13ExamApiFactory factory, Guid jobId, string targetStatus, int timeoutSeconds = 30)
    {
        var scopeFactory = factory.Services.GetRequiredService<IServiceScopeFactory>();
        var caps = R03CapsProfileTests.ApprovedFromDeployEnvFile();
        var worker = new ReadingPaperWorker(scopeFactory, NullLogger<ReadingPaperWorker>.Instance, caps);

        using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(timeoutSeconds));
        var workerTask = worker.StartAsync(cts.Token);
        try
        {
            while (!cts.IsCancellationRequested)
            {
                using var scope = factory.Services.CreateScope();
                var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
                var status = await db.ReadingPaperJobs.AsNoTracking()
                    .Where(j => j.Id == jobId)
                    .Select(j => j.Status)
                    .FirstOrDefaultAsync();
                if (status == targetStatus) return;
                try
                {
                    await Task.Delay(150, cts.Token);
                }
                catch (OperationCanceledException)
                {
                    break;
                }
            }
        }
        finally
        {
            await worker.StopAsync(CancellationToken.None);
        }

        using var finalScope = factory.Services.CreateScope();
        var finalDb = finalScope.ServiceProvider.GetRequiredService<ExamDbContext>();
        var finalStatus = await finalDb.ReadingPaperJobs.AsNoTracking()
            .Where(j => j.Id == jobId)
            .Select(j => j.Status)
            .FirstOrDefaultAsync();
        Assert.Equal(targetStatus, finalStatus);
    }

    [Fact]
    public async Task Scenario1_JobCreation_ValidSources_StartsPending_ViaApiPost()
    {
        await using var factory = new Phase13ExamApiFactory(ConnectionString);
        await factory.ResetJobsAsync();
        using var client = factory.CreateAdminClient();

        var sources = new List<ReadingSource>
        {
            CreateSampleSource(1, "PMC1000001", "Cognitive Architecture"),
            CreateSampleSource(2, "PMC1000002", "Neural Networks"),
            CreateSampleSource(3, "PMC1000003", "Linguistic Processing")
        };

        var request = new ReadingJobRequest(
            Topic: $"Cognitive AI Paper {Guid.NewGuid():N}",
            Sources: sources
        );

        var response = await client.PostAsJsonAsync("/api/admin/reading-paper/jobs", request, ReadingPaperRules.Json);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        Assert.NotNull(response.Headers.Location);

        using var jsonDoc = await JsonDocument.ParseAsync(await response.Content.ReadAsStreamAsync());
        var root = jsonDoc.RootElement;
        Assert.Equal("Pending", root.GetProperty("status").GetString());
        Assert.Equal(0, root.GetProperty("completedSections").GetInt32());
        Assert.True(root.GetProperty("error").ValueKind == JsonValueKind.Null);
    }

    [Fact]
    public async Task Scenario2_JobCreation_UnverifiedSources_ReturnsNeedsSources_ViaApiPost()
    {
        await using var factory = new Phase13ExamApiFactory(ConnectionString);
        await factory.ResetJobsAsync();
        using var client = factory.CreateAdminClient();

        var request = new ReadingJobRequest(
            Topic: $"Unverified Oceanography {Guid.NewGuid():N}",
            Sources: new List<ReadingSource>()
        );

        var response = await client.PostAsJsonAsync("/api/admin/reading-paper/jobs", request, ReadingPaperRules.Json);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);

        using var jsonDoc = await JsonDocument.ParseAsync(await response.Content.ReadAsStreamAsync());
        var root = jsonDoc.RootElement;
        Assert.Equal("NeedsSources", root.GetProperty("status").GetString());
        Assert.False(string.IsNullOrWhiteSpace(root.GetProperty("error").GetString()));
    }

    [Fact]
    public async Task Scenario3_JobPolling_GetEndpoint_ReturnsAccurateState_And_CompletedSections()
    {
        await using var factory = new Phase13ExamApiFactory(ConnectionString);
        await factory.ResetJobsAsync();
        using var client = factory.CreateAdminClient();

        var sources = new List<ReadingSource>
        {
            CreateSampleSource(1, "PMC2000001", "Source 1"),
            CreateSampleSource(2, "PMC2000002", "Source 2"),
            CreateSampleSource(3, "PMC2000003", "Source 3")
        };
        var createReq = new ReadingJobRequest(Topic: $"Polling Test Topic {Guid.NewGuid():N}", Sources: sources);
        var createRes = await client.PostAsJsonAsync("/api/admin/reading-paper/jobs", createReq, ReadingPaperRules.Json);
        using var createDoc = await JsonDocument.ParseAsync(await createRes.Content.ReadAsStreamAsync());
        var jobId = Guid.Parse(createDoc.RootElement.GetProperty("id").GetString()!);

        var getRes = await client.GetAsync($"/api/admin/reading-paper/jobs/{jobId}");
        Assert.Equal(HttpStatusCode.OK, getRes.StatusCode);

        using var getDoc = await JsonDocument.ParseAsync(await getRes.Content.ReadAsStreamAsync());
        var getRoot = getDoc.RootElement;
        Assert.Equal(jobId.ToString(), getRoot.GetProperty("id").GetString());
        Assert.Equal("Pending", getRoot.GetProperty("status").GetString());
        Assert.Equal(0, getRoot.GetProperty("completedSections").GetInt32());
    }

    [Fact]
    public async Task Scenario4_RetryEndpoint_WhenJobFailed_ResetsJobToPending_ViaApiPost()
    {
        var fixture = ReadingPaperTests.Paper();
        var aiHandler = new ControllableAiHandler(fixture, failOnSection: 1);
        await using var factory = new Phase13ExamApiFactory(ConnectionString, aiHandler);
        await factory.ResetJobsAsync();
        using var client = factory.CreateAdminClient();

        // 1. Create job via POST /api/admin/reading-paper/jobs
        var sources = fixture.Select(x => x.Source).ToList();
        var createReq = new ReadingJobRequest(Topic: $"Quantum Algorithms {Guid.NewGuid():N}", Sources: sources);
        var createRes = await client.PostAsJsonAsync("/api/admin/reading-paper/jobs", createReq, ReadingPaperRules.Json);
        using var createDoc = await JsonDocument.ParseAsync(await createRes.Content.ReadAsStreamAsync());
        var jobId = Guid.Parse(createDoc.RootElement.GetProperty("id").GetString()!);

        // 2. Drive job into Failed status via real worker execution
        await WaitForStatusAsync(factory, jobId, "Failed");

        // Verify status is Failed before retry
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var failedJob = await db.ReadingPaperJobs.AsNoTracking().SingleAsync(j => j.Id == jobId);
            Assert.Equal("Failed", failedJob.Status);
        }

        // 3. Call POST /api/admin/reading-paper/jobs/{id}/retry via HTTP
        var retryRes = await client.PostAsync($"/api/admin/reading-paper/jobs/{jobId}/retry", null);
        Assert.Equal(HttpStatusCode.OK, retryRes.StatusCode);

        using var retryDoc = await JsonDocument.ParseAsync(await retryRes.Content.ReadAsStreamAsync());
        var root = retryDoc.RootElement;
        Assert.Equal("Pending", root.GetProperty("status").GetString());
        Assert.True(root.GetProperty("error").ValueKind == JsonValueKind.Null);

        // Verify database state after retry
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var dbJob = await db.ReadingPaperJobs.AsNoTracking().SingleAsync(j => j.Id == jobId);
            Assert.Equal("Pending", dbJob.Status);
            Assert.Null(dbJob.Error);
            Assert.Null(dbJob.LeaseOwner);
            Assert.Null(dbJob.LeaseUntil);
        }
    }

    [Fact]
    public async Task Scenario5_ReplaceSources_PUT_InvalidatesChangedSectionCheckpoints_ViaApiPut()
    {
        var fixture = ReadingPaperTests.Paper();
        // Section 1 succeeds, section 2 fails -> worker completes section 1, then marks job Failed
        var aiHandler = new ControllableAiHandler(fixture, failOnSection: 2);
        await using var factory = new Phase13ExamApiFactory(ConnectionString, aiHandler);
        await factory.ResetJobsAsync();
        using var client = factory.CreateAdminClient();

        // 1. Create job via POST endpoint
        var initialSources = fixture.Select(x => x.Source).ToList();
        var createReq = new ReadingJobRequest(Topic: $"Biomedical Optics {Guid.NewGuid():N}", Sources: initialSources);
        var createRes = await client.PostAsJsonAsync("/api/admin/reading-paper/jobs", createReq, ReadingPaperRules.Json);
        using var createDoc = await JsonDocument.ParseAsync(await createRes.Content.ReadAsStreamAsync());
        var jobId = Guid.Parse(createDoc.RootElement.GetProperty("id").GetString()!);

        // 2. Drive worker until section 1 succeeds and section 2 fails (job status becomes Failed)
        await WaitForStatusAsync(factory, jobId, "Failed");

        string runId;
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var job = await db.ReadingPaperJobs.AsNoTracking().SingleAsync(j => j.Id == jobId);
            Assert.Equal(1, job.CompletedSections);
            Assert.Equal("Failed", job.Status);
            runId = job.ActiveRunId ?? $"run_{jobId:N}";
        }

        // 3. Prepare replacement sources: source 1 kept, source 2 changed
        var src2New = CreateSampleSource(2, "PMC3000002", "Source Beta New Replacement", "New content beta replacement");
        var newSources = new List<ReadingSource> { initialSources[0], src2New, initialSources[2] };
        var replaceRequest = new ReadingJobRequest(
            Topic: $"Biomedical Optics Updated {Guid.NewGuid():N}",
            Sources: newSources
        );

        // 4. Call PUT /api/admin/reading-paper/jobs/{id}/sources via HTTP
        var putRes = await client.PutAsJsonAsync($"/api/admin/reading-paper/jobs/{jobId}/sources", replaceRequest, ReadingPaperRules.Json);
        Assert.Equal(HttpStatusCode.OK, putRes.StatusCode);

        using var putDoc = await JsonDocument.ParseAsync(await putRes.Content.ReadAsStreamAsync());
        var root = putDoc.RootElement;
        Assert.Equal("Pending", root.GetProperty("status").GetString());
        Assert.Equal(1, root.GetProperty("completedSections").GetInt32()); // Section 1 preserved

        // 5. Verify artifact heads in DB (art_section_1 kept, art_section_2 invalidated)
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var heads = await db.ReadingPaperArtifactHeads.Where(h => h.RunId == runId).ToListAsync();
            Assert.All(heads, h => Assert.NotEqual("art_section_2", h.ArtifactId));
        }
    }

    [Fact]
    public async Task Scenario6_StreamNDJSON_ReceivesLogsAndResult_AndParsesCanonicalSection()
    {
        var sampleSource = CreateSampleSource(1, "PMC1000001", "Memory Systems");
        var expectedSection = new ReadingGeneratedSection(
            "Section 1: Memory Systems",
            "This is a verified academic passage about human memory systems...",
            sampleSource,
            new List<ReadingGeneratedGroup>()
        );
        var serializedSection = JsonSerializer.Serialize(expectedSection, ReadingPaperRules.Json);

        var ndjsonLines = new StringBuilder();
        ndjsonLines.AppendLine("{\"type\": \"log\", \"level\": \"Information\", \"message\": \"Synthesizing passage...\"}");
        ndjsonLines.AppendLine("{\"type\": \"log\", \"level\": \"Information\", \"message\": \"Auditing against evidence graph...\"}");
        ndjsonLines.AppendLine($"{{\"type\": \"result\", \"section\": {serializedSection}}}");

        var httpClient = new HttpClient(new MockStreamHandler(ndjsonLines.ToString()))
        {
            BaseAddress = new Uri("http://localhost:8080/")
        };
        var aiClient = new ReadingPaperAiClient(httpClient);

        var logs = new List<string>();
        var result = await aiClient.GenerateSectionAsync(
            topic: "Memory Systems",
            index: 1,
            source: sampleSource,
            onProgress: (level, msg) =>
            {
                logs.Add($"[{level}] {msg}");
                return Task.CompletedTask;
            },
            ct: CancellationToken.None
        );

        Assert.NotNull(result);
        Assert.Equal("Section 1: Memory Systems", result.Title);
        Assert.Equal(2, logs.Count);
        Assert.Contains(logs, l => l.Contains("Synthesizing passage"));
        Assert.Contains(logs, l => l.Contains("Auditing against evidence"));
    }

    [Fact]
    public async Task Scenario7_ManualExam_Draft_Edit_Publish_ViaAdminAndPublicApi()
    {
        await using var factory = new Phase13ExamApiFactory(ConnectionString);
        using var client = factory.CreateAdminClient();

        var title = $"Manual E2E Exam {Guid.NewGuid():N}";
        // 1. Create in Draft via HTTP POST /api/admin/exam/addexam
        var createDto = new DtoAdmin.AdminExamCreate(
            Title: title,
            DescriptionMd: "Handcrafted manual reading test",
            Category: "IELTS",
            Level: "C1",
            DurationMin: 60,
            ImageUrl: null,
            Slug: null
        );
        var createRes = await client.PostAsJsonAsync("/api/admin/exam/addexam", createDto);
        Assert.Equal(HttpStatusCode.OK, createRes.StatusCode);

        Guid examId;
        string slug;
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var exam = await db.Exams.AsNoTracking().SingleAsync(e => e.Title == title);
            Assert.Equal(ExamStatus.Draft, exam.Status);
            examId = exam.Id;
            slug = exam.Slug;
        }

        // 2. Verify public endpoint GET /api/public/exam/getby/{slug} returns 404 NotFound when Draft
        var publicDraftRes = await client.GetAsync($"/api/public/exam/getby/{slug}");
        Assert.Equal(HttpStatusCode.NotFound, publicDraftRes.StatusCode);

        // 3. Publish via HTTP PUT /api/admin/exam/update/{id} with Status = Published
        var publishDto = new DtoAdmin.AdminExamUpdate(
            Title: title,
            DescriptionMd: "Handcrafted manual reading test published",
            Category: "IELTS",
            Level: "C1",
            DurationMin: 60,
            Status: ExamStatus.Published,
            ImageUrl: null
        );
        var updateRes = await client.PutAsJsonAsync($"/api/admin/exam/update/{examId}", publishDto);
        Assert.Equal(HttpStatusCode.OK, updateRes.StatusCode);

        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var publishedExam = await db.Exams.AsNoTracking().SingleAsync(e => e.Id == examId);
            Assert.Equal(ExamStatus.Published, publishedExam.Status);
        }

        // 4. Verify public endpoint GET /api/public/exam/getby/{slug} returns 200 OK once Published
        var publicPublishedRes = await client.GetAsync($"/api/public/exam/getby/{slug}");
        Assert.Equal(HttpStatusCode.OK, publicPublishedRes.StatusCode);
    }

    [Fact]
    public async Task Scenario8_ManualCRUD_AdminCanCreateUpdateDeleteExamsDirectly()
    {
        await using var factory = new Phase13ExamApiFactory(ConnectionString);
        using var client = factory.CreateAdminClient();

        var title = $"CRUD Test Exam {Guid.NewGuid():N}";
        // 1. Create via HTTP POST /api/admin/exam/addexam
        var createDto = new DtoAdmin.AdminExamCreate(
            Title: title,
            DescriptionMd: "Handcrafted manual reading test",
            Category: "IELTS",
            Level: "C1",
            DurationMin: 60,
            ImageUrl: null,
            Slug: null
        );
        var createRes = await client.PostAsJsonAsync("/api/admin/exam/addexam", createDto);
        Assert.Equal(HttpStatusCode.OK, createRes.StatusCode);

        Guid examId;
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var exam = await db.Exams.AsNoTracking().SingleAsync(e => e.Title == title);
            Assert.Equal(ExamStatus.Draft, exam.Status);
            examId = exam.Id;
        }

        // 2. Update via HTTP PUT /api/admin/exam/update/{id}
        var updatedTitle = $"{title} Rev2";
        var updateDto = new DtoAdmin.AdminExamUpdate(
            Title: updatedTitle,
            DescriptionMd: "Updated description",
            Category: "IELTS",
            Level: "C2",
            DurationMin: 70,
            Status: ExamStatus.Draft,
            ImageUrl: null
        );
        var updateRes = await client.PutAsJsonAsync($"/api/admin/exam/update/{examId}", updateDto);
        Assert.Equal(HttpStatusCode.OK, updateRes.StatusCode);

        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var updatedExam = await db.Exams.AsNoTracking().SingleAsync(e => e.Id == examId);
            Assert.Equal(updatedTitle, updatedExam.Title);
            Assert.Equal(70, updatedExam.DurationMin);
        }

        // 3. Delete via HTTP DELETE /api/admin/exam/delete/{id}
        var deleteRes = await client.DeleteAsync($"/api/admin/exam/delete/{examId}");
        Assert.Equal(HttpStatusCode.OK, deleteRes.StatusCode);

        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var exists = await db.Exams.AsNoTracking().AnyAsync(e => e.Id == examId);
            Assert.False(exists);
        }
    }

    [Fact]
    public async Task Scenario9_StatusContract_StrictlyEnforcesExactLifecycleEnumNames_NoNumericPercentages()
    {
        await using var factory = new Phase13ExamApiFactory(ConnectionString);
        await factory.ResetJobsAsync();
        using var client = factory.CreateAdminClient();

        var validStatuses = new HashSet<string> { "Pending", "Running", "NeedsSources", "Failed", "Completed", "Cancelled" };

        var sources = new List<ReadingSource>
        {
            CreateSampleSource(1, "PMC4000001", "Status Contract Source")
        };
        var createReq = new ReadingJobRequest(Topic: $"Status Contract Test {Guid.NewGuid():N}", Sources: sources);
        var createRes = await client.PostAsJsonAsync("/api/admin/reading-paper/jobs", createReq, ReadingPaperRules.Json);
        using var createDoc = await JsonDocument.ParseAsync(await createRes.Content.ReadAsStreamAsync());
        var status = createDoc.RootElement.GetProperty("status").GetString();

        Assert.NotNull(status);
        Assert.Contains(status, validStatuses);
        Assert.DoesNotContain("%", status);
    }
    [Fact]
    public async Task CancelJob_FencesRunAndReturnsLogsForLegacyPlainText()
    {
        await using var factory = new Phase13ExamApiFactory(ConnectionString);
        await factory.ResetJobsAsync();
        using var client = factory.CreateAdminClient();
        var owner = Guid.NewGuid();
        var job = new ReadingPaperJob
        {
            Topic = "Cancellation authority regression",
            Status = "Running",
            Epoch = 1,
            CancelVersion = 0,
            LeaseOwner = owner,
            LeaseUntil = DateTime.UtcNow.AddMinutes(5),
            ActiveRunId = "cancel-authority-regression",
            SourcesJson = "[]",
            SectionsJson = "[]",
            Logs = "Acceptance benchmark child run"
        };
        var run = new ReadingPaperRun
        {
            JobId = job.Id,
            RunId = job.ActiveRunId,
            Epoch = 1,
            Status = "RUNNING",
            LeaseOwner = owner,
            LeaseUntil = job.LeaseUntil,
            CancelVersion = 0
        };
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            db.ReadingPaperJobs.Add(job);
            db.ReadingPaperRuns.Add(run);
            await db.SaveChangesAsync();
        }

        var cancelResponse = await client.PostAsync($"/api/admin/reading-paper/jobs/{job.Id}/cancel", null);
        Assert.Equal(HttpStatusCode.OK, cancelResponse.StatusCode);
        using var responseJson = JsonDocument.Parse(await cancelResponse.Content.ReadAsStringAsync());
        Assert.Contains("Acceptance benchmark child run", responseJson.RootElement.GetProperty("logs").ToString());

        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var cancelledJob = await db.ReadingPaperJobs.AsNoTracking().SingleAsync(x => x.Id == job.Id);
            var cancelledRun = await db.ReadingPaperRuns.AsNoTracking().SingleAsync(x => x.RunId == run.RunId);
            Assert.Equal(cancelledJob.Epoch, cancelledRun.Epoch);
            Assert.Equal(cancelledJob.CancelVersion, cancelledRun.CancelVersion);
            Assert.Null(cancelledJob.LeaseOwner);
            Assert.Null(cancelledRun.LeaseOwner);
            Assert.Null(cancelledJob.LeaseUntil);
            Assert.Null(cancelledRun.LeaseUntil);

            client.DefaultRequestHeaders.Add(CheckpointService.InternalApiKeyHeader, Phase13ExamApiFactory.TestInternalApiKey);
            var staleWrite = new OperationGrantRequest(run.RunId, 1, owner, "late-cancel-write", "INGEST",
                Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(Encoding.UTF8.GetBytes("late"))).ToLowerInvariant(), 0);
            var staleResponse = await client.PostAsJsonAsync(
                "/api/internal/reading-paper/checkpoints/grant-operation", staleWrite, ReadingPaperRules.Json);
            Assert.Equal(HttpStatusCode.Conflict, staleResponse.StatusCode);
            Assert.Contains("epoch fencing", await staleResponse.Content.ReadAsStringAsync(), StringComparison.OrdinalIgnoreCase);
            Assert.False(await db.ReadingPaperOperations.AnyAsync(x => x.RunId == run.RunId && x.OperationId == "late-cancel-write"));
        }
    }
    [Fact]
    public async Task Worker_DoesNotResurrectRunWhenCancellationWinsDuringRunLoad()
    {
        var pause = new RunLoadPauseInterceptor();
        await using var factory = new Phase13ExamApiFactory(ConnectionString, dbInterceptor: pause);
        await factory.ResetJobsAsync();
        using var client = factory.CreateAdminClient();
        var job = new ReadingPaperJob
        {
            Topic = "Worker cancellation race regression",
            Status = "Pending",
            SourcesJson = "[]",
            SectionsJson = "[]"
        };
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            db.ReadingPaperJobs.Add(job);
            await db.SaveChangesAsync();
        }

        var worker = new ReadingPaperWorker(
            factory.Services.GetRequiredService<IServiceScopeFactory>(),
            NullLogger<ReadingPaperWorker>.Instance,
            R03CapsProfileTests.ApprovedFromDeployEnvFile());
        await worker.StartAsync(CancellationToken.None);
        try
        {
            await pause.ReachedRunLoad.Task.WaitAsync(TimeSpan.FromSeconds(10));
            var cancelResponse = await client.PostAsync($"/api/admin/reading-paper/jobs/{job.Id}/cancel", null);
            Assert.Equal(HttpStatusCode.OK, cancelResponse.StatusCode);
        }
        finally
        {
            pause.ResumeRunLoad.TrySetResult();
            await worker.StopAsync(CancellationToken.None);
        }

        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var cancelledJob = await db.ReadingPaperJobs.AsNoTracking().SingleAsync(x => x.Id == job.Id);
            Assert.Equal("Cancelled", cancelledJob.Status);
            Assert.Null(cancelledJob.LeaseOwner);
            Assert.False(await db.ReadingPaperRuns.AnyAsync(x => x.JobId == job.Id));
        }
    }
}
