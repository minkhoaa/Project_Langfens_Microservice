using System.IdentityModel.Tokens.Jwt;
using System.Text;
using course_service.Features;
using course_service.Features.AdminEndpoint;
using course_service.Features.PublicEndpoint;
using course_service.Features.UserEndpoint;
using course_service.Infrastructure;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Shared.Security.Claims;
using Shared.Security.Contracts;
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
    
    options.AddPolicy(CourseScope.CourseRead,  p => p.RequireAssertion(c =>
        c.User.HasAnyScope(CourseScope.CourseRead) || c.User.IsInRole(Roles.User)));
    options.AddPolicy(CourseScope.CourseEnroll,  p => p.RequireAssertion(c =>
        c.User.HasAnyScope(CourseScope.CourseEnroll) || c.User.IsInRole(Roles.User)));
    options.AddPolicy(CourseScope.CourseComplete,  p => p.RequireAssertion(c =>
        c.User.HasAnyScope(CourseScope.CourseComplete) || c.User.IsInRole(Roles.User)));
    options.AddPolicy(CourseScope.CourseManage,  p => p.RequireAssertion(c =>
        c.User.HasAnyScope(CourseScope.CourseManage) || c.User.IsInRole(Roles.Admin)));
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(option =>
{
    option.SwaggerDoc("v1", new OpenApiInfo { Title = "Course Service", Version = "1.0" });
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
builder.Services.AddCors(options =>
{
    options.AddPolicy("FE", policy => policy
        .WithOrigins("http://localhost:3000", "http://127.0.0.1:3000")
        .AllowAnyHeader()
        .AllowAnyMethod()
        .AllowCredentials());
});

// configure
var connectionString = Environment.GetEnvironmentVariable("CONNECTIONSTRING__COURSE")
                        ?? builder.Configuration.GetConnectionString("Course_DB")
                        ?? "Host=localhost;Port=5436;Database=course-db;Username=course;Password=course";
builder.Services.AddDbContext<CourseDbContext>(option => option.UseNpgsql(connectionString));

// DI
builder.Services.AddScoped<IPublicEndpointService, PublicEndpointService>();
builder.Services.AddScoped<IUserEndpointService, UserEndpointService>();
builder.Services.AddScoped<IAdminEndpointService, AdminEndpointService>();

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<CourseDbContext>();
    await context.Database.MigrateAsync();
}

// Configure the HTTP request pipeline.

app.UseSwagger();
app.UseSwaggerUI();

app.UseCors("FE");
app.UseAuthentication();
app.UseAuthorization();

app.MapCourseEndpoint();
app.MapLessonEndpoint();
app.MapAdminEndpoint();

app.Run();