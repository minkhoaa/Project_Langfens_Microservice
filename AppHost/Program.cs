using Aspire.Hosting;
using CommunityToolkit.Aspire.MassTransit.RabbitMQ;

var builder = DistributedApplication.CreateBuilder(args);

// ── exam-service ──────────────────────────────────────────────────────────
var examDbServer = builder.AddPostgres("exam-db-server", port: 5433);
var examDb = examDbServer.AddDatabase("exam-db");

var exam = builder.AddProject("exam-service", "../services/exam-service/exam-service.csproj")
    .WithReference(examDb)
    .WaitFor(examDb);

// ── gamification-service ─────────────────────────────────────────────────
var gamificationDbServer = builder.AddPostgres("gamification-db-server", port: 5444);
var gamificationDb = gamificationDbServer.AddDatabase("gamification-db");

var rabbitmq = builder.AddRabbitMQ("rabbitmq", port: 5672)
    .WithManagementPlugin();

var gamificationService = builder.AddProject("gamification-service", "../services/gamification-service/gamification-service.csproj")
    .WithReference(gamificationDb)
    .WithReference(rabbitmq)
    .WaitFor(gamificationDb)
    .WaitFor(rabbitmq);

// ── email-service ─────────────────────────────────────────────────────────
var emailService = builder.AddProject("email-service", "../services/email-service/email-service.csproj")
    .WithReference(rabbitmq)
    .WaitFor(rabbitmq);

// ── course-service ─────────────────────────────────────────────────────────
var courseDbServer = builder.AddPostgres("course-db-server", port: 5446);
var courseDb = courseDbServer.AddDatabase("course-db");

var courseService = builder.AddProject("course-service", "../services/course-service/course-service.csproj")
    .WithReference(courseDb)
    .WithReference(rabbitmq)
    .WaitFor(courseDb)
    .WaitFor(rabbitmq);

// ── speaking-service ─────────────────────────────────────────────────────
// NOTE: Speaking-service uses CUDA GPU for Whisper.net inference.
//       GPU passthrough requires ContainerRuntimeArgsAnnotation("--gpus=all")
//       which is handled via docker-compose overlay — OUT OF SCOPE for Aspire local dev.
var speakingDbServer = builder.AddPostgres("speaking-db-server", port: 5441);
var speakingDb = speakingDbServer.AddDatabase("speaking-db");

var speakingService = builder.AddProject("speaking-service", "../services/speaking-service/speaking-service.csproj")
    .WithReference(speakingDb)
    .WithReference(rabbitmq)
    .WaitFor(speakingDb)
    .WaitFor(rabbitmq);

// ── dictionary-service ───────────────────────────────────────────────────
var dictionaryDbServer = builder.AddPostgres("dictionary-db-server", port: 5443);
var dictionaryDb = dictionaryDbServer.AddDatabase("dictionary-db");

// Elasticsearch has no native Aspire resource — added via AddContainer
// Image: docker.elastic.co/elasticsearch/elasticsearch:8.19.0
// Single-node, security disabled (xpack.security.enabled=false), memory-limited
var elasticsearch = builder.AddContainer("elasticsearch", "docker.elastic.co/elasticsearch/elasticsearch", "8.19.0")
    .WithHttpEndpoint(9200)
    .WithEnvironment("discovery.type", "single-node")
    .WithEnvironment("xpack.security.enabled", "false")
    .WithEnvironment("ES_JAVA_OPTS", "-Xms512m -Xmx512m");

var dictionaryService = builder.AddProject("dictionary-service", "../services/dictionary-service/dictionary-service.csproj")
    .WithReference(dictionaryDb)
    .WaitFor(dictionaryDb)
    .WaitFor(elasticsearch);

// ── vocabulary-service ───────────────────────────────────────────────────
var vocabularyDbServer = builder.AddPostgres("vocabulary-db-server", port: 5987);
var vocabularyDb = vocabularyDbServer.AddDatabase("vocabulary-db");

var vocabularyService = builder.AddProject("vocabulary-service", "../services/vocabulary-service/vocabulary-service.csproj")
    .WithReference(vocabularyDb)
    .WithReference(rabbitmq)
    .WaitFor(vocabularyDb)
    .WaitFor(rabbitmq);

// ── writing-service ───────────────────────────────────────────────────────
var writingDbServer = builder.AddPostgres("writing-db-server", port: 5440);
var writingDb = writingDbServer.AddDatabase("writing-db");

var writingService = builder.AddProject("writing-service", "../services/writing-service/writing-service.csproj")
    .WithReference(writingDb)
    .WithReference(rabbitmq)
    .WaitFor(writingDb)
    .WaitFor(rabbitmq);

// ── auth-service ───────────────────────────────────────────────────────────
var authDbServer = builder.AddPostgres("auth-db-server", port: 5434);
var authDb = authDbServer.AddDatabase("auth-db");

var authRedis = builder.AddRedis("auth-redis", port: 6379);

var authService = builder.AddProject("auth-service", "../services/auth-service/auth-service.csproj")
    .WithReference(authDb)
    .WithReference(authRedis)
    .WithReference(rabbitmq)
    .WaitFor(authDb)
    .WaitFor(authRedis)
    .WaitFor(rabbitmq);

// ── attempt-service ────────────────────────────────────────────────────────
var attemptDbServer = builder.AddPostgres("attempt-db-server", port: 5435);
var attemptDb = attemptDbServer.AddDatabase("attempt-db");

var attemptService = builder.AddProject("attempt-service", "../services/attempt-service/attempt-service.csproj")
    .WithReference(attemptDb)
    .WithReference(rabbitmq)
    .WaitFor(attemptDb)
    .WaitFor(rabbitmq);

// ── API Gateway ──────────────────────────────────────────────────────────
var gateway = builder.AddProject("api-gateway", "../gateway/api-gateway/api-gateway.csproj")
    .WithReference(exam)
    .WithReference(gamificationService)
    .WithReference(speakingService)
    .WithReference(dictionaryService)
    .WithReference(vocabularyService)
    .WithReference(writingService)
    .WithReference(authService)
    .WithReference(attemptService)
    .WaitFor(exam)
    .WaitFor(gamificationService)
    .WaitFor(speakingService)
    .WaitFor(dictionaryService)
    .WaitFor(vocabularyService)
    .WaitFor(writingService)
    .WaitFor(authService)
    .WaitFor(attemptService);

// ── AI Service ───────────────────────────────────────────────────────────
var qdrant = builder.AddContainer("qdrant", "qdrant/qdrant", "latest")
    .WithHttpEndpoint(6333);

var aiService = builder.AddContainer("ai-service", "langfens-ai-service", "latest")
    .WithEnvironment("REDIS_HOST", "localhost")
    .WithEnvironment("REDIS_PORT", "6379")
    .WithEnvironment("QDRANT_HOST", "localhost")
    .WithEnvironment("QDRANT_PORT", "6333")
    .WaitFor(qdrant);

// ── Frontend (NOT added — AddNpmApp/AddNodeApp requires Aspire.Hosting.Node package)
var _ = builder; // placeholder so AddNpmApp reference below can be uncommented when package is added
// var frontend = builder.AddNpmApp("frontend", "../langfens-fe-app")
//     .WithReference(gateway)
//     .WithEnvironment("NEXT_PUBLIC_GATEWAY_URL", "http://localhost:8080")
//     .WaitFor(gateway);

builder.Build().Run();