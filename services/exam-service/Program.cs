using System.IdentityModel.Tokens.Jwt;
using System.Text;
using exam_service.Features.Exams.AdminEndpoint;
using exam_service.Features.Exams.AdminEndpoint.ExamEndpoint;
using exam_service.Features.Exams.AdminEndpoint.OptionEndpoint;
using exam_service.Features.Exams.AdminEndpoint.QuestionEndpoint;
using exam_service.Features.Exams.AdminEndpoint.SectionEndpoint;
using exam_service.Features.Exams.InternalEndpoint;
using exam_service.Features.Exams.PublicEndpoint;
using exam_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Shared.Security.Claims;
using Shared.Security.Helper;
using Shared.Security.Roles;
using Shared.Security.Scopes;


var builder = WebApplication.CreateBuilder(args);



JwtSecurityTokenHandler.DefaultMapInboundClaims = false;
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(option =>
    {
        option.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = builder.Configuration["JwtSettings:Issuer"] 
                          ?? throw new Exception("valid issuer is missing"),
            ValidAudience = builder.Configuration["JwtSettings:Audience"] 
                            ?? throw new Exception("valid issuer is missing"),
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true, 
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["JwtSettings:SignKey"] 
            ?? throw new Exception("Signing key is missing"))),
            
            ClockSkew = TimeSpan.Zero,
            NameClaimType = CustomClaims.Sub,
            RoleClaimType = CustomClaims.Roles
        };
    });
builder.Services.AddAuthorization(options =>
{
    options.FallbackPolicy = new AuthorizationPolicyBuilder()
        .RequireAuthenticatedUser().Build();
    options.AddPolicy(Roles.User, p => p.RequireRole(Roles.User));
    options.AddPolicy(Roles.Admin, p => p.RequireRole(Roles.Admin));
    
    options.AddPolicy(ExamScope.ExamRead,  p => p.RequireAssertion(c =>
        c.User.HasAnyScope(ExamScope.ExamRead) || c.User.IsInRole(Roles.User)));
    options.AddPolicy(ExamScope.ExamManage,  p => p.RequireAssertion(c =>
        c.User.HasAnyScope(ExamScope.ExamManage) || c.User.IsInRole(Roles.Admin)));
});

builder.Services.AddCors(options =>
{
    options.AddPolicy("FE", policy => policy
        .WithOrigins("http://localhost:3000", "http://127.0.0.1:3000")
        .AllowAnyHeader()
        .AllowAnyMethod()
        .AllowCredentials());
});

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(option =>
{
    option.SwaggerDoc("v1", new OpenApiInfo { Title = "Exam Service", Version = "1.0" });
    option.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
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
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});
builder.Services.AddDbContextPool<ExamDbContext>(option =>
    option.UseNpgsql(Environment.GetEnvironmentVariable("CONNECTIONSTRING__EXAM")
                     ?? builder.Configuration.GetConnectionString("Exam_DB")));

builder.Services.AddScoped<IExamService, ExamService>();
builder.Services.AddScoped<IAdminExamService, AdminExamService>();
builder.Services.AddScoped<IAdminOptionService, AdminOptionService>();
builder.Services.AddScoped<IAdminSectionService, AdminSectionService>();
builder.Services.AddScoped<IInternalExamService, InternalExamService>();
builder.Services.AddScoped<IAdminQuestionService, AdminQuestionService>();

int grpcPort = 8081;
int httpPort = 8080;
builder.WebHost.ConfigureKestrel(o =>
{
    o.ListenAnyIP(httpPort, lo => lo.Protocols = HttpProtocols.Http1);
    o.ListenAnyIP(grpcPort, lo => lo.Protocols = HttpProtocols.Http2);
});
builder.Services.AddGrpc();


var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
    await db.Database.MigrateAsync();
}

await using (var scope = app.Services.CreateAsyncScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
    var pending = (await db.Database.GetPendingMigrationsAsync()).ToList();
    Console.WriteLine($"[EF] Pending migrations: {pending.Count} => {string.Join(", ", pending)}");
    await db.Database.MigrateAsync();
}

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
    await db.Database.MigrateAsync();
}

await using (var scope = app.Services.CreateAsyncScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
    var pending = (await db.Database.GetPendingMigrationsAsync()).ToList();
    Console.WriteLine($"[EF] Pending migrations: {pending.Count} => {string.Join(", ", pending)}");
    await db.Database.MigrateAsync();
}

app.UseSwagger();
app.UseSwaggerUI();
app.UseCors("FE");
app.UseAuthentication();
app.UseAuthorization();

app.MapGrpcService<ExamInternalGrpcService>().RequireHost($"*:{grpcPort}").AllowAnonymous();


app.MapPublicExamEndpoints();
app.MapAdminExamEndpoint();
app.MapAdminSectionEndpoint();
app.MapAdminQuestionEndpoint();
app.MapAdminOptionEndpoint();
app.MapInternalExamEndpoint();
app.Run();