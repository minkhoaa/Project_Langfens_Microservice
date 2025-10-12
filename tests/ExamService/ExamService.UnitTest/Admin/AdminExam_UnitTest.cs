using exam_service.Contracts.Exams;
using exam_service.Features.Exams.AdminEndpoint.ExamEndpoint;
using exam_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Moq;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Exam.Enums;

namespace ExamService.UnitTest.Admin;

// Helper: lấy Status + payload từ IResult (không cần HttpContext/DI)
internal static class ResultHelpers
{
    public static (int Status, T? Value) Extract<T>(IResult result)
    {
        var status = (result as IStatusCodeHttpResult)?.StatusCode ?? StatusCodes.Status200OK;
        var value = (result as IValueHttpResult)?.Value;
        return (status, value is T t ? t : default);
    }
}

public class AdminExamHandlerUnitTests
{
    [Fact]
    public async Task AddExam_Should_Return_400_When_Missing_Title()
    {
        var dto = new DtoAdmin.AdminExamCreate("   ", "no-slug", null, "IELTS", "B1", 60);

        var svc = new Mock<IAdminExamService>();
        svc.Setup(s => s.AddAsync(It.IsAny<DtoAdmin.AdminExamCreate>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(Results.BadRequest(new ApiResultDto(false, "Title is required", null!)));

        var result = await AdminExamHandler.AddExamHandler(dto, CancellationToken.None, svc.Object);

        var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
        Assert.Equal(StatusCodes.Status400BadRequest, status);
        Assert.False(api!.isSuccess);
        Assert.Contains("Title is required", api.message);

        svc.Verify(s => s.AddAsync(It.IsAny<DtoAdmin.AdminExamCreate>(), It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task AddExam_Should_Proxy_200_From_Service()
    {
        var dto = new DtoAdmin.AdminExamCreate("IELTS Reading 1", "noslug-2", "desc", "IELTS", "B1", 60);
        var ok = Results.Ok(new ApiResultDto(true, "Create isSuccessfully", new { Id = Guid.NewGuid() }));

        var svc = new Mock<IAdminExamService>();
        svc.Setup(s => s.AddAsync(dto, It.IsAny<CancellationToken>())).ReturnsAsync(ok);

        var result = await AdminExamHandler.AddExamHandler(dto, CancellationToken.None, svc.Object);

        var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
        Assert.Equal(StatusCodes.Status200OK, status);
        Assert.True(api!.isSuccess);
        Assert.Contains("Create isSuccessfully", api.message);
    }

    [Fact]
    public async Task UpdateExam_Should_Call_Service_And_Return_200()
    {
        var id = Guid.NewGuid();
        var update = new DtoAdmin.AdminExamUpdate("New", "D", "IELTS", "B2", 50,
            ExamStatus.Published);

        var ok = Results.Ok(new ApiResultDto(true, "Affected 1 rows", null!));
        var svc = new Mock<IAdminExamService>();
        svc.Setup(s => s.UpdateAsync(id, update, It.IsAny<CancellationToken>())).ReturnsAsync(ok);

        var result = await AdminExamHandler.UpdateExamHandler(id, svc.Object, update, CancellationToken.None);

        var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
        Assert.Equal(StatusCodes.Status200OK, status);
        Assert.True(api!.isSuccess);
        Assert.Contains("Affected 1", api.message);
    }

    [Fact]
    public async Task DeleteExam_Should_Call_Service_And_Return_200()
    {
        var id = Guid.NewGuid();
        var ok = Results.Ok(new ApiResultDto(true, "Deleted 1", null!));
        var svc = new Mock<IAdminExamService>();
        svc.Setup(s => s.DeleteAsync(id, It.IsAny<CancellationToken>())).ReturnsAsync(ok);

        var result = await AdminExamHandler.DeleteExamHandler(id, svc.Object, CancellationToken.None);

        var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
        Assert.Equal(StatusCodes.Status200OK, status);
        Assert.True(api!.isSuccess);
        Assert.Contains("Deleted 1", api.message);
    }
}

public class AdminExamService_UnitTests_Validation
{
    // Không dùng UseInMemoryDatabase: chỉ cần options != null để new DbContext
    private static ExamDbContext CreateDb_ForValidationOnly()
    {
        var options = new DbContextOptionsBuilder<ExamDbContext>().Options; // không cấu hình provider
        return new ExamDbContext(options);
    }

    [Fact]
    public async Task AddAsync_MissingTitle_Returns_400_Without_DB()
    {
        using var db = CreateDb_ForValidationOnly(); // ctor ok, nhánh validate sẽ return sớm
        var svc = new AdminExamService(db);

        var dto = new DtoAdmin.AdminExamCreate("   ", null, null, "IELTS", "B1", 60);

        var result = await svc.AddAsync(dto, CancellationToken.None);

        var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
        Assert.Equal(StatusCodes.Status400BadRequest, status);
        Assert.False(api!.isSuccess);
        Assert.Contains("Title is required", api.message);
    }
}
