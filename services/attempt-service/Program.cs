using System.IdentityModel.Tokens.Jwt;
using System.Security.Authentication;
using System.Text;
using System.Text.Json;
using attempt_service.Features.Attempt;
using attempt_service.Features.Attempt.AttemptEndpoint;
using attempt_service.Features.Helpers;
using attempt_service.Features.RabbitMq;
using attempt_service.Infrastructure.Persistence;
using MassTransit;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Shared.ExamDto.Contracts.Speaking;
using Shared.ExamDto.Contracts.Writing;
using Shared.Grpc.ExamInternal;
using Shared.Security.Claims;
using Shared.Security.Helper;
using Shared.Security.Roles;
using Shared.Security.Scopes;

var builder = WebApplication.CreateBuilder(args);
JwtSecurityTokenHandler.DefaultMapInboundClaims = false;
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddResponseCompression();
builder.Services.AddSwaggerGen(option =>
{
    option.SwaggerDoc("v1", new OpenApiInfo()
    {
        Title = "Attempt-service"
    });
    option.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme()
    {
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        Description = "Enter token"
    });
    option.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme()
            {
                Reference = new OpenApiReference()
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                },
            },
            Array.Empty<string>()
        }
    });
});
builder.Services.AddCors(options =>
{
    options.AddPolicy("FE", policy => policy
        .WithOrigins("http://localhost:3000", "http://127.0.0.1:3000")
        .AllowAnyHeader()
        .AllowAnyMethod()
        .AllowCredentials());
});


AppContext.SetSwitch("System.Net.Http.SocketsHttpHandler.Http2UnencryptedSupport", true);

builder.Services
    .AddGrpcClient<ExamInternal.ExamInternalClient>(o =>
    {
        o.Address = new Uri("http://exam-service:8081");
    })
    .ConfigurePrimaryHttpMessageHandler(() => new SocketsHttpHandler
    {
        EnableMultipleHttp2Connections = true
    })
    ;
builder.Services.Configure<JwtSettings>
    (builder.Configuration.GetSection("JwtSettings"));
var jwtSettings = builder.Configuration.GetSection("JwtSettings").Get<JwtSettings>();
builder.Services.AddDbContext<AttemptDbContext>(option => option.UseNpgsql(
    Environment.GetEnvironmentVariable("CONNECTIONSTRING__ATTEMPT")
    ?? builder.Configuration.GetConnectionString("Attempt_DB")
));
builder.Services.AddHttpClient("ExamServiceInternal", (sp, http) =>
{
    var cfg = sp.GetRequiredService<IConfiguration>();
    var baseExamAddress = Environment.GetEnvironmentVariable("EXAMSERVICE__EXAM__ADDRESS")
                          ?? cfg["ExamService:Exam_BaseAddress"]
                          ?? "http://examservice:8080";
    var internalApiKey = Environment.GetEnvironmentVariable("EXAMSERVICE__INTERNAL__API__KEY")
                         ?? cfg["ExamService:Exam_Internal_Api_Key"];
    Console.Write(baseExamAddress + "  " + internalApiKey);
    http.BaseAddress = new Uri(baseExamAddress);
    http.DefaultRequestHeaders.Add("X-Internal-Key", internalApiKey);
});

builder.Services.AddMassTransit(configurator =>
{
    configurator.AddConsumer<WritingGradedConsumer>();
    configurator.AddConsumer<SpeakingGradedConsumer>();
    RabbitMqConfig prodRabbitEnvironment;
    try
    {
        prodRabbitEnvironment = new RabbitMqConfig
        {
            Host = Environment.GetEnvironmentVariable("RABBITMQ__HOST") ??
                                        builder.Configuration["RabbitMq:Host"] ?? "localhost",
            Username = Environment.GetEnvironmentVariable("RABBITMQ__USERNAME") ??
                       builder.Configuration["RabbitMq:Username"] ?? "guest",
            Password = Environment.GetEnvironmentVariable("RABBITMQ__PASSWORD") ??
                       builder.Configuration["RabbitMq:Password"] ?? "guest",
            VirtualHost = builder.Configuration["RabbitMq:VirtualHost"] ??
                          Environment.GetEnvironmentVariable("RABBITMQ__VHOST") ?? "/",
            Port = ushort.TryParse(Environment.GetEnvironmentVariable("RABBITMQ__PORT"), out var a) ? a :
                bool.TryParse(builder.Configuration["RabbitMq:UseSsl"], out var useSsl) && useSsl ? (ushort)5671 :
                (ushort)5672,
            UseSsl = bool.TryParse(Environment.GetEnvironmentVariable(""), out var proSsl) && proSsl
        };
    }
    catch
    {
        prodRabbitEnvironment =
            builder.Configuration.GetSection("RabbitMq").Get<RabbitMqConfig>()
            ?? throw new Exception("Rabbitmq config is missing");

    }
    configurator.UsingRabbitMq((bus, config) =>
    {
        config.Host(prodRabbitEnvironment.Host, prodRabbitEnvironment.Port, prodRabbitEnvironment.VirtualHost,
        h =>
        {
            h.Username(prodRabbitEnvironment.Username);
            h.Password(prodRabbitEnvironment.Password);
            if (prodRabbitEnvironment.UseSsl)
            {
                h.UseSsl(k => k.Protocol = SslProtocols.Tls12);
            }
        });

        config.ReceiveEndpoint("writing-graded-response", k => k.ConfigureConsumer<WritingGradedConsumer>(bus));
        config.ReceiveEndpoint("speaking-graded-response", k => k.ConfigureConsumer<SpeakingGradedConsumer>(bus));
    });



});
// DI
builder.Services.AddScoped<IAttemptService, AttemptService>();
builder.Services.AddScoped<IExamGateway, ExamGateway>();
builder.Services.AddScoped<IUserContext, UserContext>();
builder.Services.AddSingleton<IAnswerKeyBuilder, AnswerKeyBuilder>();
builder.Services.AddSingleton<IBuildQuestionIdSet, BuildQuestionIdSet>();
builder.Services.AddSingleton<IQuestionIndex, QuestionIndex>();
builder.Services.AddSingleton<IIndexBuilder, IndexBuilder>();
builder.Services.AddSingleton<IAnswerValidator, AnswerValidator>();


builder.Services.AddSingleton<SingleChoiceGrader>();
builder.Services.AddSingleton<CompletionGrader>();
builder.Services.AddSingleton<LabelGrader>();
builder.Services.AddSingleton<MatchingHeadingGrader>();
builder.Services.AddSingleton<FlowChartGrader>();
builder.Services.AddSingleton<ShortAnswerGrader>();

builder.Services.AddSingleton<IQuestionGraderRegistration, SingleChoiceGraderRegistration>();
builder.Services.AddSingleton<IQuestionGraderRegistration, CompletionGraderRegistration>();
builder.Services.AddSingleton<IQuestionGraderRegistration, LabelGraderRegistration>();
builder.Services.AddSingleton<IQuestionGraderRegistration, MatchingHeadingGraderRegistration>();
builder.Services.AddSingleton<IQuestionGraderRegistration, FlowChartGraderRegistration>();
builder.Services.AddSingleton<IQuestionGraderRegistration, ShortAnswerGraderRegistration>();
builder.Services.AddScoped<IPlacementWorkflow, PlacementWorkflow>();


builder.Services.AddSingleton<IQuestionGraderFactory, QuestionGraderFactory>();
builder.Services.ConfigureHttpJsonOptions(option =>
{
    option.SerializerOptions.PropertyNameCaseInsensitive = true;
    option.SerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
});
builder.Services.AddAuthentication(option =>
{
    option.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    option.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
}).AddJwtBearer(options =>
{
    options.SaveToken = true;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateIssuerSigningKey = true,
        ValidateLifetime = true,
        ValidAudience = jwtSettings!.Audience,
        ValidIssuer = jwtSettings.Issuer,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings.SignKey)),
        ClockSkew = TimeSpan.Zero,
        RoleClaimType = CustomClaims.Roles,
        NameClaimType = CustomClaims.Sub
    };
    options.MapInboundClaims = false;
});
builder.Services.AddAuthorization(option =>
{
    option.FallbackPolicy = new AuthorizationPolicyBuilder().RequireAuthenticatedUser().Build();
    option.AddPolicy(Roles.User, a => a.RequireRole(Roles.User));
    option.AddPolicy(Roles.Admin, a => a.RequireRole(Roles.Admin));

    option.AddPolicy(AttemptScope.AttemptStart, a => a.RequireAssertion(c => c.User.HasAnyScope(AttemptScope.AttemptStart)
                                                                   || c.User.IsInRole(Roles.User)));
    option.AddPolicy(AttemptScope.AttemptSubmit, a => a.RequireAssertion(c => c.User.HasAnyScope(AttemptScope.AttemptSubmit)
                                                                   || c.User.IsInRole(Roles.User)));
    option.AddPolicy(AttemptScope.AttemptReadOwn, a => a.RequireAssertion(c => c.User.HasAnyScope(AttemptScope.AttemptReadOwn)
                                                                   || c.User.IsInRole(Roles.User)));
    option.AddPolicy(AttemptScope.AttemptReadAny, a => a.RequireAssertion(c => c.User.HasAnyScope(AttemptScope.AttemptReadAny)
                                                                    || c.User.IsInRole(Roles.Admin)));

});


builder.Services.AddAuthorization();
builder.Services.AddHttpContextAccessor();

var app = builder.Build();


using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AttemptDbContext>();
    var all = db.Database.GetMigrations().ToList();
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

app.MapPost("/api/test-writing", async (WritingGradeRequestMessage request, IPublishEndpoint bus) =>
{
    await bus.Publish<WritingGradeRequestMessage>(request);
    return Results.Ok();
}).AllowAnonymous();

app.Run();
