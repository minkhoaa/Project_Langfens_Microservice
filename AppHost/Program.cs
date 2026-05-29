using Aspire.Hosting;
using Aspire.Hosting.ApplicationModel;
using CommunityToolkit.Aspire.MassTransit.RabbitMQ;

var builder = DistributedApplication.CreateBuilder(args);

// ── Shared infra ──────────────────────────────────────────────────────────
// RabbitMQ: declare credentials as parameters so we can both hand them to
// AddRabbitMQ and reuse them when pushing the discrete RABBITMQ__USERNAME /
// RABBITMQ__PASSWORD env vars to services. Without explicit parameters,
// Aspire only materializes UserNameParameter/PasswordParameter later in the
// pipeline and they read as null at AddProject-time.
var rabbitUser = builder.AddParameter("rabbitmq-user", "guest");
var rabbitPass = builder.AddParameter("rabbitmq-password", "guest", secret: true);
var rabbitmq = builder.AddRabbitMQ("rabbitmq", userName: rabbitUser, password: rabbitPass)
    .WithManagementPlugin();

// Single shared Redis instance. The auth-service still uses Aspire's
// AddRedisClient("auth-redis") which looks up ConnectionStrings__auth-redis,
// so we explicitly inject that key onto the auth resource below.
var redis = builder.AddRedis("redis");

var elasticsearch = builder.AddContainer("elasticsearch", "docker.elastic.co/elasticsearch/elasticsearch", "8.19.0")
    .WithHttpEndpoint(targetPort: 9200, name: "http")
    .WithEnvironment("discovery.type", "single-node")
    .WithEnvironment("xpack.security.enabled", "false")
    .WithEnvironment("ES_JAVA_OPTS", "-Xms512m -Xmx512m");

var qdrant = builder.AddContainer("qdrant", "qdrant/qdrant", "latest")
    .WithHttpEndpoint(targetPort: 6333, name: "http");

// Ollama: chat/grading default to Groq (USE_OLLAMA=false), but EMBEDDINGS are
// always served by Ollama, so bge-m3 must be present or all RAG features
// (writing compare, grammar explain/search) 404. Persist the volume and pull
// bge-m3 via a one-shot init that ai-service waits for.
var ollama = builder.AddContainer("ollama", "ollama/ollama", "latest")
    .WithHttpEndpoint(targetPort: 11434, name: "http")
    .WithEnvironment("OLLAMA_HOST", "0.0.0.0")
    .WithEnvironment("OLLAMA_KEEP_ALIVE", "5m")
    .WithEnvironment("OLLAMA_NUM_PARALLEL", "1")
    .WithVolume("ollama-data", "/root/.ollama")
    .WithLifetime(ContainerLifetime.Persistent);

var ollamaInit = builder.AddContainer("ollama-init", "ollama/ollama", "latest")
    .WithEnvironment("OLLAMA_HOST", ollama.GetEndpoint("http"))
    .WithEntrypoint("/bin/sh")
    .WithArgs("-c", "ollama pull bge-m3")
    .WaitFor(ollama);

// ── Postgres servers (host ports kept for developer DX: psql/pgAdmin) ────
// Credentials match compose.local.yaml exactly for standalone dev parity.
var examDbUser = builder.AddParameter("exam-db-user", "exam");
var examDbPass = builder.AddParameter("exam-db-pass", "exam", secret: true);
var examDbServer = builder.AddPostgres("exam-db-server", userName: examDbUser, password: examDbPass, port: 5433).WithDataVolume().WithLifetime(ContainerLifetime.Persistent);
var examDb = examDbServer.AddDatabase("exam-db");

var gamificationDbUser = builder.AddParameter("gamification-db-user", "gamification");
var gamificationDbPass = builder.AddParameter("gamification-db-pass", "gamification", secret: true);
var gamificationDbServer = builder.AddPostgres("gamification-db-server", userName: gamificationDbUser, password: gamificationDbPass, port: 5444).WithDataVolume().WithLifetime(ContainerLifetime.Persistent);
var gamificationDb = gamificationDbServer.AddDatabase("gamification-db");

var courseDbUser = builder.AddParameter("course-db-user", "course");
var courseDbPass = builder.AddParameter("course-db-pass", "course", secret: true);
var courseDbServer = builder.AddPostgres("course-db-server", userName: courseDbUser, password: courseDbPass, port: 5446).WithDataVolume().WithLifetime(ContainerLifetime.Persistent);
var courseDb = courseDbServer.AddDatabase("course-db");

var speakingDbUser = builder.AddParameter("speaking-db-user", "speaking");
var speakingDbPass = builder.AddParameter("speaking-db-pass", "speaking", secret: true);
var speakingDbServer = builder.AddPostgres("speaking-db-server", userName: speakingDbUser, password: speakingDbPass, port: 5441).WithDataVolume().WithLifetime(ContainerLifetime.Persistent);
var speakingDb = speakingDbServer.AddDatabase("speaking-db");

var dictionaryDbUser = builder.AddParameter("dictionary-db-user", "dictionary");
var dictionaryDbPass = builder.AddParameter("dictionary-db-pass", "dictionary", secret: true);
var dictionaryDbServer = builder.AddPostgres("dictionary-db-server", userName: dictionaryDbUser, password: dictionaryDbPass, port: 5443).WithDataVolume().WithLifetime(ContainerLifetime.Persistent);
var dictionaryDb = dictionaryDbServer.AddDatabase("dictionary-db");

var vocabularyDbUser = builder.AddParameter("vocabulary-db-user", "vocabulary");
var vocabularyDbPass = builder.AddParameter("vocabulary-db-pass", "vocabulary", secret: true);
var vocabularyDbServer = builder.AddPostgres("vocabulary-db-server", userName: vocabularyDbUser, password: vocabularyDbPass, port: 5987).WithDataVolume().WithLifetime(ContainerLifetime.Persistent);
var vocabularyDb = vocabularyDbServer.AddDatabase("vocabulary-db");

var writingDbUser = builder.AddParameter("writing-db-user", "writing");
var writingDbPass = builder.AddParameter("writing-db-pass", "writing", secret: true);
var writingDbServer = builder.AddPostgres("writing-db-server", userName: writingDbUser, password: writingDbPass, port: 5440).WithDataVolume().WithLifetime(ContainerLifetime.Persistent);
var writingDb = writingDbServer.AddDatabase("writing-db");

var authDbUser = builder.AddParameter("auth-db-user", "auth");
var authDbPass = builder.AddParameter("auth-db-pass", "auth", secret: true);
var authDbServer = builder.AddPostgres("auth-db-server", userName: authDbUser, password: authDbPass, port: 5434).WithDataVolume().WithLifetime(ContainerLifetime.Persistent);
var authDb = authDbServer.AddDatabase("auth-db");

var attemptDbUser = builder.AddParameter("attempt-db-user", "attempt");
var attemptDbPass = builder.AddParameter("attempt-db-pass", "attempt", secret: true);
var attemptDbServer = builder.AddPostgres("attempt-db-server", userName: attemptDbUser, password: attemptDbPass, port: 5435).WithDataVolume().WithLifetime(ContainerLifetime.Persistent);
var attemptDb = attemptDbServer.AddDatabase("attempt-db");

// ── exam-service ─────────────────────────────────────────────────────────
// Let Aspire allocate Kestrel ports. Agent 4 is making Kestrel ports env-
// configurable (Kestrel__HttpPort / Kestrel__GrpcPort), but we deliberately
// don't pin them — service discovery handles addressing.
var exam = builder.AddProject("exam-service", "../services/exam-service/exam-service.csproj")
    .WithReference(examDb)
    .WithHttpEndpoint(name: "http", env: "Kestrel__HttpPort")
    .WithHttpEndpoint(name: "grpc", env: "Kestrel__GrpcPort")
    .WithComposeEnvFile("exam")
    .WaitFor(examDb);

// ── gamification-service ─────────────────────────────────────────────────
var gamification = builder.AddProject("gamification-service", "../services/gamification-service/gamification-service.csproj")
    .WithReference(gamificationDb)
    .WithReference(rabbitmq)
    .WithComposeEnvFile("gamification")
    .WithRabbitMqEnv(rabbitmq, rabbitUser, rabbitPass)
    .WaitFor(gamificationDb)
    .WaitFor(rabbitmq);

// ── email-service ────────────────────────────────────────────────────────
var email = builder.AddProject("email-service", "../services/email-service/email-service.csproj")
    .WithReference(rabbitmq)
    .WithComposeEnvFile("email")
    .WithRabbitMqEnv(rabbitmq, rabbitUser, rabbitPass)
    .WaitFor(rabbitmq);

// ── course-service ───────────────────────────────────────────────────────
var course = builder.AddProject("course-service", "../services/course-service/course-service.csproj")
    .WithReference(courseDb)
    .WithReference(rabbitmq)
    .WithComposeEnvFile("course")
    .WithRabbitMqEnv(rabbitmq, rabbitUser, rabbitPass)
    .WaitFor(courseDb)
    .WaitFor(rabbitmq);

// ── speaking-service ─────────────────────────────────────────────────────
var speaking = builder.AddProject("speaking-service", "../services/speaking-service/speaking-service.csproj")
    .WithReference(speakingDb)
    .WithReference(rabbitmq)
    .WithComposeEnvFile("speaking")
    .WithRabbitMqEnv(rabbitmq, rabbitUser, rabbitPass)
    .WaitFor(speakingDb)
    .WaitFor(rabbitmq);

// ── dictionary-service ───────────────────────────────────────────────────
var dictionary = builder.AddProject("dictionary-service", "../services/dictionary-service/dictionary-service.csproj")
    .WithReference(dictionaryDb)
    .WithEnvironment("ELASTICSEARCH__URL", elasticsearch.GetEndpoint("http"))
    .WithComposeEnvFile("dictionary")
    .WaitFor(dictionaryDb)
    .WaitFor(elasticsearch);

// ── vocabulary-service ───────────────────────────────────────────────────
var vocabulary = builder.AddProject("vocabulary-service", "../services/vocabulary-service/vocabulary-service.csproj")
    .WithReference(vocabularyDb)
    .WithReference(rabbitmq)
    .WithComposeEnvFile("vocabulary")
    .WithRabbitMqEnv(rabbitmq, rabbitUser, rabbitPass)
    .WaitFor(vocabularyDb)
    .WaitFor(rabbitmq);

// ── writing-service ──────────────────────────────────────────────────────
// writing-service reads CONNECTIONSTRING__WRITING directly (legacy bridge in
// its Program.cs), so we inject that on top of Aspire's auto-injected
// ConnectionStrings__writing-db.
var writing = builder.AddProject("writing-service", "../services/writing-service/writing-service.csproj")
    .WithReference(writingDb)
    .WithEnvironment("CONNECTIONSTRING__WRITING", writingDb.Resource.ConnectionStringExpression)
    .WithReference(rabbitmq)
    .WithComposeEnvFile("writing")
    .WithRabbitMqEnv(rabbitmq, rabbitUser, rabbitPass)
    .WaitFor(writingDb)
    .WaitFor(rabbitmq);

// ── auth-service ─────────────────────────────────────────────────────────
// auth-service uses AddRedisClient("auth-redis"), which reads
// ConnectionStrings__auth-redis. The shared Redis resource is named "redis",
// so we explicitly map its connection string under the auth-redis key.
var auth = builder.AddProject("auth-service", "../services/auth-service/auth-service.csproj")
    .WithReference(authDb)
    .WithReference(redis)
    .WithEnvironment("ConnectionStrings__auth-redis", redis.Resource.ConnectionStringExpression)
    .WithReference(rabbitmq)
    .WithComposeEnvFile("auth")
    .WithRabbitMqEnv(rabbitmq, rabbitUser, rabbitPass)
    .WaitFor(authDb)
    .WaitFor(redis)
    .WaitFor(rabbitmq);

// ── attempt-service ──────────────────────────────────────────────────────
// EXAMSERVICE__INTERNAL__API__KEY is required (attempt-service throws on
// startup without it). Dev placeholder only.
var attempt = builder.AddProject("attempt-service", "../services/attempt-service/attempt-service.csproj")
    .WithReference(attemptDb)
    .WithReference(rabbitmq)
    .WithComposeEnvFile("attempt")
    .WithRabbitMqEnv(rabbitmq, rabbitUser, rabbitPass)
    .WithEnvironment("EXAMSERVICE__EXAM__ADDRESS", exam.GetEndpoint("http"))
    .WithEnvironment("ExamService__GrpcAddress", exam.GetEndpoint("grpc"))
    .WithEnvironment("EXAMSERVICE__INTERNAL__API__KEY", "dev-internal-key-not-for-prod")
    .WaitFor(attemptDb)
    .WaitFor(rabbitmq)
    .WaitFor(exam);

// ── AI Service (Python, built from Dockerfile) ───────────────────────────
var aiService = builder.AddDockerfile("ai-service", "../", "services/ai-service/Dockerfile")
    .WithHttpEndpoint(targetPort: 8080, name: "http")
    // Hot reload: mount host source over the baked /app/app and run uvicorn
    // --reload so Python edits apply live without an image rebuild.
    .WithBindMount("../services/ai-service/app", "/app/app")
    .WithEntrypoint("uvicorn")
    .WithArgs("app.main:app", "--host", "0.0.0.0", "--port", "8080",
              "--reload", "--reload-dir", "/app/app")
    .WithEnvironment("REDIS_HOST", redis.Resource.PrimaryEndpoint.Property(EndpointProperty.Host))
    .WithEnvironment("REDIS_PORT", redis.Resource.PrimaryEndpoint.Property(EndpointProperty.Port))
    .WithEnvironment("REDIS_PASSWORD", redis.Resource.PasswordParameter!)
    .WithEnvironment("REDIS_SSL", "true")
    .WithEnvironment("QDRANT_HOST", qdrant.GetEndpoint("http").Property(EndpointProperty.Host))
    .WithEnvironment("QDRANT_PORT", qdrant.GetEndpoint("http").Property(EndpointProperty.Port))
    .WithEnvironment("OLLAMA_BASE_URL", ollama.GetEndpoint("http"))
    .WithComposeEnvFile("ai")
    .WaitFor(redis)
    .WaitFor(qdrant)
    .WaitForCompletion(ollamaInit);

// AI URL injection into writing & speaking (both default to http://ai-service:8080)
writing.WithEnvironment("AI_SERVICE_URL", aiService.GetEndpoint("http"));
speaking.WithEnvironment("AI_SERVICE_URL", aiService.GetEndpoint("http"));

// ── API Gateway ──────────────────────────────────────────────────────────
// Reference every downstream so service discovery works, and override every
// YARP cluster destination so we use Aspire-allocated endpoints instead of
// the compose hostnames baked into gateway/api-gateway/appsettings.json.
var gateway = builder.AddProject("api-gateway", "../gateway/api-gateway/api-gateway.csproj")
    .WithHttpEndpoint(port: 5000, name: "http", env: "ASPNETCORE_HTTP_PORTS")
    .WithReference(exam)
    .WithReference(gamification)
    .WithReference(speaking)
    .WithReference(dictionary)
    .WithReference(vocabulary)
    .WithReference(writing)
    .WithReference(auth)
    .WithReference(attempt)
    .WithReference(course)
    .WithReference(email)
    .WithComposeEnvFile("gateway")
    .WithEnvironment("ReverseProxy__Clusters__auth-cluster__Destinations__d1__Address", auth.GetEndpoint("http"))
    .WithEnvironment("ReverseProxy__Clusters__exam-cluster__Destinations__d1__Address", exam.GetEndpoint("http"))
    .WithEnvironment("ReverseProxy__Clusters__attempt-cluster__Destinations__d1__Address", attempt.GetEndpoint("http"))
    .WithEnvironment("ReverseProxy__Clusters__vocabulary-cluster__Destinations__d1__Address", vocabulary.GetEndpoint("http"))
    .WithEnvironment("ReverseProxy__Clusters__course-cluster__Destinations__d1__Address", course.GetEndpoint("http"))
    .WithEnvironment("ReverseProxy__Clusters__speaking-cluster__Destinations__d1__Address", speaking.GetEndpoint("http"))
    .WithEnvironment("ReverseProxy__Clusters__writing-cluster__Destinations__d1__Address", writing.GetEndpoint("http"))
    .WithEnvironment("ReverseProxy__Clusters__email-cluster__Destinations__d1__Address", email.GetEndpoint("http"))
    .WithEnvironment("ReverseProxy__Clusters__dictionary-cluster__Destinations__d1__Address", dictionary.GetEndpoint("http"))
    .WithEnvironment("ReverseProxy__Clusters__gamification-cluster__Destinations__d1__Address", gamification.GetEndpoint("http"))
    .WithEnvironment("ReverseProxy__Clusters__ai-cluster__Destinations__d1__Address", aiService.GetEndpoint("http"))
    .WaitFor(exam)
    .WaitFor(gamification)
    .WaitFor(speaking)
    .WaitFor(dictionary)
    .WaitFor(vocabulary)
    .WaitFor(writing)
    .WaitFor(auth)
    .WaitFor(attempt)
    .WaitFor(course)
    .WaitFor(email);

// ── Frontend ─────────────────────────────────────────────────────────────
// The Next.js dev server (langfens-fe-app) is run outside Aspire — start it
// manually with `npm run dev` and point NEXT_PUBLIC_GATEWAY_URL at the
// gateway endpoint Aspire allocates.

var app = builder.Build();
try
{
    app.Run();
}
finally
{
    app.Dispose();
}

// ── Helpers ──────────────────────────────────────────────────────────────
internal static class AppHostExtensions
{
    private static readonly string EnvDir = Path.Combine(
        AppContext.BaseDirectory, "..", "..", "..", "..", "deploy", "envs");

    /// <summary>
    /// Loads deploy/envs/&lt;name&gt;.env and applies every key/value pair to the
    /// service via WithEnvironment. The same env files compose uses, so secrets
    /// (JwtSettings, SMTP, Azure OpenAI, Groq, etc.) reach the service without
    /// duplicating them in AppHost. Skips RABBITMQ__*, CONNECTIONSTRING__*,
    /// EXAMSERVICE__EXAM__ADDRESS and AI_SERVICE_URL because AppHost injects
    /// those with Aspire-allocated values.
    /// </summary>
    public static IResourceBuilder<T> WithComposeEnvFile<T>(
        this IResourceBuilder<T> service,
        string name)
        where T : IResourceWithEnvironment
    {
        var path = Path.GetFullPath(Path.Combine(EnvDir, $"{name}.env"));
        if (!File.Exists(path))
        {
            return service;
        }

        foreach (var raw in File.ReadAllLines(path))
        {
            var line = raw.Trim();
            if (line.Length == 0 || line.StartsWith('#'))
                continue;

            var idx = line.IndexOf('=');
            if (idx <= 0)
                continue;

            var key = line[..idx].Trim();
            var val = line[(idx + 1)..].Trim();

            // Strip optional surrounding quotes and unescape \n.
            if (val.Length >= 2 &&
                ((val.StartsWith('"') && val.EndsWith('"')) ||
                 (val.StartsWith('\'') && val.EndsWith('\''))))
            {
                val = val[1..^1];
            }
            val = val.Replace("\\n", "\n");

            // Don't override values AppHost injects from the live resource graph.
            if (key.StartsWith("RABBITMQ__") ||
                key.StartsWith("CONNECTIONSTRING__") ||
                key.StartsWith("ConnectionStrings__") ||
                key == "EXAMSERVICE__EXAM__ADDRESS" ||
                key == "EXAMSERVICE__INTERNAL__API__KEY" ||
                key == "AI_SERVICE_URL" ||
                key == "ELASTICSEARCH__URL" ||
                key == "REDIS_HOST" ||
                key == "REDIS_PORT" ||
                key == "QDRANT_HOST" ||
                key == "QDRANT_PORT")
            {
                continue;
            }

            service.WithEnvironment(key, val);
        }
        return service;
    }

    /// <summary>
    /// Pushes RabbitMQ connection details to a service via the discrete
    /// RABBITMQ__* env vars that langfens services read (they don't read
    /// the standard ConnectionStrings__rabbitmq value injected by
    /// WithReference(rabbitmq)).
    /// </summary>
    public static IResourceBuilder<T> WithRabbitMqEnv<T>(
        this IResourceBuilder<T> service,
        IResourceBuilder<RabbitMQServerResource> rabbitmq,
        IResourceBuilder<ParameterResource> userName,
        IResourceBuilder<ParameterResource> password)
        where T : IResourceWithEnvironment
    {
        return service
            .WithEnvironment("RABBITMQ__HOST", rabbitmq.Resource.PrimaryEndpoint.Property(EndpointProperty.Host))
            .WithEnvironment("RABBITMQ__PORT", rabbitmq.Resource.PrimaryEndpoint.Property(EndpointProperty.Port))
            .WithEnvironment("RABBITMQ__USERNAME", userName)
            .WithEnvironment("RABBITMQ__PASSWORD", password)
            .WithEnvironment("RABBITMQ__VHOST", "/")
            .WithEnvironment("RABBITMQ__USESSL", "false");
    }
}
