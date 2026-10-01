using exam_service.Features.ReadingPaper.Contracts;
using exam_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Mvc;

namespace exam_service.Features.ReadingPaper;

public static class CheckpointEndpoints
{
    public static void MapCheckpointEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/internal/reading-paper/checkpoints");

        // Service Authentication middleware/filter
        group.AddEndpointFilter(async (context, next) =>
        {
            var httpContext = context.HttpContext;
            if (!httpContext.Request.Headers.TryGetValue(CheckpointService.InternalApiKeyHeader, out var keyValues))
            {
                return Results.Json(new { error = "Missing internal service authentication key" }, statusCode: 401);
            }

            var expectedKey = Environment.GetEnvironmentVariable("EXAMSERVICE__INTERNAL__API__KEY")
                              ?? Environment.GetEnvironmentVariable("InternalApiKey");

            if (string.IsNullOrWhiteSpace(expectedKey))
            {
                return Results.Json(new { error = "Internal service authentication key is not configured on server" }, statusCode: 500);
            }

            var providedKey = keyValues.ToString();
            if (!string.Equals(providedKey, expectedKey, StringComparison.Ordinal))
            {
                return Results.Json(new { error = "Invalid internal service authentication key" }, statusCode: 403);
            }

            return await next(context);
        });

        group.MapPost("/grant-operation", async (
            [FromBody] OperationGrantRequest request,
            ExamDbContext db,
            CancellationToken ct) =>
        {
            try
            {
                var result = await CheckpointService.GrantOperationAsync(db, request, ct);
                return Results.Ok(result);
            }
            catch (CheckpointValidationException ex)
            {
                return Results.Json(new { error = ex.Message }, statusCode: ex.StatusCode);
            }
        });
        group.MapPost("/budgets/allocate", async (
            [FromBody] SetBudgetAllocationsRequest request,
            ExamDbContext db,
            CancellationToken ct) =>
        {
            try
            {
                var result = await CheckpointService.SetBudgetAllocationsAsync(db, request, ct);
                return Results.Ok(result);
            }
            catch (CheckpointValidationException ex)
            {
                return Results.Json(new { error = ex.Message }, statusCode: ex.StatusCode);
            }
        });
        group.MapPost("/operations/reconcile", async (
            [FromBody] OperationReconcileRequest request,
            ExamDbContext db,
            CancellationToken ct) =>
        {
            try
            {
                var result = await CheckpointService.ReconcileOperationAsync(db, request, ct);
                return Results.Ok(result);
            }
            catch (CheckpointValidationException ex)
            {
                return Results.Json(new { error = ex.Message }, statusCode: ex.StatusCode);
            }
        });



        group.MapPost("/commit", async (
            [FromBody] CheckpointCommitRequest request,
            ExamDbContext db,
            CancellationToken ct) =>
        {
            try
            {
                var result = await CheckpointService.CommitCheckpointAsync(db, request, ct);
                return Results.Ok(result);
            }
            catch (CheckpointValidationException ex)
            {
                return Results.Json(new { error = ex.Message }, statusCode: ex.StatusCode);
            }
        });

        group.MapPost("/draft", async (
            [FromBody] DraftCheckpointRequest request,
            ExamDbContext db,
            CancellationToken ct) =>
        {
            try
            {
                var result = await CheckpointService.SaveDraftCheckpointAsync(db, request, ct);
                return Results.Ok(result);
            }
            catch (CheckpointValidationException ex)
            {
                return Results.Json(new { error = ex.Message }, statusCode: ex.StatusCode);
            }
        });
        group.MapPost("/unknown-outcome", async (
            [FromBody] UnknownOutcomeRequest request,
            ExamDbContext db,
            CancellationToken ct) =>
        {
            try
            {
                var result = await CheckpointService.RecordUnknownOutcomeAsync(db, request, ct);
                return Results.Ok(result);
            }
            catch (CheckpointValidationException ex)
            {
                return Results.Json(new { error = ex.Message }, statusCode: ex.StatusCode);
            }
        });

        group.MapPost("/loop/cursor", async (
            [FromBody] LoopCursorCheckpointRequest request,
            ExamDbContext db,
            CancellationToken ct) =>
        {
            try { return Results.Ok(await LoopCursorService.SaveAsync(db, request, ct)); }
            catch (CheckpointValidationException ex)
            { return Results.Json(new { error = ex.Message }, statusCode: ex.StatusCode); }
        });
        group.MapGet("/resume/{runId}", async (
            string runId,
            ExamDbContext db,
            CancellationToken ct) =>
        {
            try
            {
                var result = await CheckpointService.ResumeStateAsync(db, runId, ct);
                return Results.Ok(result);
            }
            catch (CheckpointValidationException ex)
            {
                return Results.Json(new { error = ex.Message }, statusCode: ex.StatusCode);
            }
        });

        group.MapPost("/invalidate", async (
            [FromBody] InvalidateDependencyRequest request,
            ExamDbContext db,
            CancellationToken ct) =>
        {
            try
            {
                var result = await CheckpointService.InvalidateDependencyClosureAsync(db, request, ct);
                return Results.Ok(result);
            }
            catch (CheckpointValidationException ex)
            {
                return Results.Json(new { error = ex.Message }, statusCode: ex.StatusCode);
            }
        });

        group.MapPost("/build-exam", async (
            [FromBody] BuildExamInternalRequest request,
            ExamDbContext db,
            CancellationToken ct) =>
        {
            try
            {
                var result = await CheckpointService.BuildExamIdempotentAsync(db, request, ct);
                return Results.Ok(result);
            }
            catch (CheckpointValidationException ex)
            {
                return Results.Json(new { error = ex.Message }, statusCode: ex.StatusCode);
            }
        });
    }
}
