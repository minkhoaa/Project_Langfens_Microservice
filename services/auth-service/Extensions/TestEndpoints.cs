using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;
using auth_service.Infrastructure.Persistence;
using auth_service.Application.Common;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace auth_service.Extensions;

/// <summary>
/// Test harness endpoints for E2E testing.
/// These endpoints are ONLY active in Testing environment.
/// Protected by X-Test-Secret header.
/// </summary>
public static class TestEndpoints
{
    private const string TestSecretHeader = "X-Test-Secret";

    public static void MapTestEndpoints(this IEndpointRouteBuilder app, IWebHostEnvironment env)
    {
        if (!env.IsEnvironment("Testing"))
            return;

        var testSecret = Environment.GetEnvironmentVariable("TEST_SECRET") ?? "test-key";

        var group = app.MapGroup("/__test")
            .AddEndpointFilter(async (context, next) =>
            {
                var request = context.HttpContext.Request;
                if (!request.Headers.TryGetValue(TestSecretHeader, out var secret) ||
                    !secret.Equals(testSecret))
                {
                    return Results.StatusCode(403);
                }
                return await next(context);
            });

        // GET /__test/otp/{email} - Retrieve OTP from Redis/Cache
        group.MapGet("/otp/{email}", async (string email, HttpContext httpContext) =>
        {
            try
            {
                // For testing, we need to expose the OTP directly
                // Since OTPs are hashed in production, we store a test copy 
                var testOtpKey = $"test:otp:{email}";
                
                // Get Redis from DI
                var redis = httpContext.RequestServices.GetRequiredService<StackExchange.Redis.IDatabase>();
                var otp = await redis.StringGetAsync(testOtpKey);
                
                if (otp.IsNullOrEmpty)
                {
                    return Results.NotFound(new { message = "No OTP found for email", email });
                }
                
                return Results.Ok(new { email, otp = otp.ToString() });
            }
            catch (Exception ex)
            {
                return Results.Problem(ex.Message);
            }
        });

        // POST /__test/seed-user - Create test user directly
        group.MapPost("/seed-user", async (
            SeedUserRequest request,
            UserManager<User> userManager,
            AuthDbContext dbContext) =>
        {
            try
            {
                // Check if user exists
                var existing = await userManager.FindByEmailAsync(request.Email);
                if (existing != null)
                {
                    return Results.Ok(new { message = "User already exists", userId = existing.Id });
                }

                var user = new User
                {
                    UserName = request.Email,
                    Email = request.Email,
                    EmailConfirmed = request.EmailConfirmed
                };

                var result = await userManager.CreateAsync(user, request.Password);
                if (!result.Succeeded)
                {
                    return Results.BadRequest(new { errors = result.Errors });
                }

                if (request.Roles?.Any() == true)
                {
                    await userManager.AddToRolesAsync(user, request.Roles);
                }

                return Results.Created($"/__test/user/{user.Id}", new { userId = user.Id, email = user.Email });
            }
            catch (Exception ex)
            {
                return Results.Problem(ex.Message);
            }
        });

        // DELETE /__test/cleanup - Remove all test data
        group.MapDelete("/cleanup", async (AuthDbContext dbContext) =>
        {
            try
            {
                // Only delete users created in testing (has @test. email domain)
                var testUsers = await dbContext.Users
                    .Where(u => u.Email!.Contains("@test."))
                    .ToListAsync();
                
                dbContext.Users.RemoveRange(testUsers);
                await dbContext.SaveChangesAsync();
                
                return Results.Ok(new { deleted = testUsers.Count });
            }
            catch (Exception ex)
            {
                return Results.Problem(ex.Message);
            }
        });

        // GET /__test/health - Simple health check
        group.MapGet("/health", () => Results.Ok(new { status = "ok", environment = "Testing" }));
    }
}

public record SeedUserRequest(
    string Email,
    string Password,
    bool EmailConfirmed = true,
    string? DisplayName = null,
    string[]? Roles = null
);
