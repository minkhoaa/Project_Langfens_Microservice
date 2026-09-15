using Microsoft.AspNetCore.Mvc;
using Shared.ExamDto.Contracts;
using Shared.Security.Roles;

namespace exam_service.Features.Exams.AdminEndpoint;

/// <summary>
/// Admin-only image upload endpoint. Stores files on the local filesystem
/// under <c>wwwroot/uploads/images/yyyy/mm/&lt;guid&gt;.&lt;ext&gt;</c> and returns
/// the relative URL that can be stored on the question/option.
/// Served as a static asset by <c>app.UseStaticFiles()</c>.
/// </summary>
public static class AdminUploadEndpoint
{
    public const int MaxBytes = 5 * 1024 * 1024; // 5 MB

    private static readonly HashSet<string> AllowedExtensions =
        new(StringComparer.OrdinalIgnoreCase) { ".jpg", ".jpeg", ".png", ".gif", ".webp" };

    public static void MapAdminUploadEndpoint(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/admin/upload").RequireAuthorization(Roles.Admin);

        group.MapPost("/image", UploadImageHandler)
            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status400BadRequest)
            .Produces(StatusCodes.Status413PayloadTooLarge)
            .Produces(StatusCodes.Status415UnsupportedMediaType);

        // Reject anything larger than MaxBytes+1 before ASP.NET Core materialises
        // the IFormFile (Kestrel's default 30MB cap still applies).
        group.DisableAntiforgery();
    }

    private static async Task<IResult> UploadImageHandler(
        HttpRequest request,
        IWebHostEnvironment env,
        CancellationToken token)
    {
        if (!request.HasFormContentType)
            return Results.BadRequest(new ApiResultDto(false, "Expected multipart/form-data", null!));

        var form = await request.ReadFormAsync(token);
        var file = form.Files["file"] ?? form.Files.FirstOrDefault();
        if (file is null || file.Length == 0)
            return Results.BadRequest(new ApiResultDto(false, "Missing 'file' form field", null!));

        if (file.Length > MaxBytes)
            return Results.Json(
                new ApiResultDto(false, $"File too large (max {MaxBytes / 1024 / 1024} MB)", null!),
                statusCode: StatusCodes.Status413PayloadTooLarge);

        if (string.IsNullOrEmpty(file.ContentType) ||
            !file.ContentType.StartsWith("image/", StringComparison.OrdinalIgnoreCase))
        {
            return Results.Json(
                new ApiResultDto(false, $"Unsupported content-type: '{file.ContentType ?? "<empty>"}'", null!),
                statusCode: StatusCodes.Status415UnsupportedMediaType);
        }

        var ext = Path.GetExtension(file.FileName);
        if (string.IsNullOrEmpty(ext) || !AllowedExtensions.Contains(ext))
        {
            return Results.Json(
                new ApiResultDto(false, $"Unsupported file extension: '{ext}'. Allowed: {string.Join(", ", AllowedExtensions)}", null!),
                statusCode: StatusCodes.Status415UnsupportedMediaType);
        }

        // Folder layout: wwwroot/uploads/images/<yyyy>/<mm>/<guid>.<ext>
        var webRoot = !string.IsNullOrEmpty(env.WebRootPath)
            ? env.WebRootPath
            : Path.Combine(env.ContentRootPath, "wwwroot");
        var now = DateTime.UtcNow;
        var folder = Path.Combine(
            webRoot,
            "uploads",
            "images",
            now.ToString("yyyy"),
            now.ToString("MM"));

        try
        {
            Directory.CreateDirectory(folder);
        }
        catch (Exception ex)
        {
            return Results.BadRequest(new ApiResultDto(false, $"Failed to create upload directory: {ex.Message}", null!));
        }

        var fileName = $"{Guid.NewGuid():N}{ext.ToLowerInvariant()}";
        var fullPath = Path.Combine(folder, fileName);

        try
        {
            await using var stream = File.Create(fullPath);
            await file.CopyToAsync(stream, token);
        }
        catch (Exception ex)
        {
            return Results.BadRequest(new ApiResultDto(false, $"Failed to write file: {ex.Message}", null!));
        }

        var url = $"/uploads/images/{now:yyyy}/{now:MM}/{fileName}";
        return Results.Ok(new ApiResultDto(true, "Uploaded", new { url }));
    }
}
