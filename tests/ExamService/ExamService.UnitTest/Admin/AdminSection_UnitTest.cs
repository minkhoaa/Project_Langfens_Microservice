using exam_service.Contracts.Exams;
using exam_service.Features.Exams.AdminEndpoint.SectionEndpoint;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;

namespace ExamService.UnitTest.Admin;

public class AdminSectionUnitTest
{
    [Fact]
    public async Task AddSection_Should_Return_404_When_Exam_NotFound()
    {
        var (ctx, conn) = SqlTestHelper.CreateInMemory();
        try
        {
            var svc = new AdminSectionService(ctx);
            var dto = new DtoAdmin.AdminSectionUpsert(1011, null, "Sec 1", "No content");

            var result = await AdminSectionHandler.AddSectionHandler(svc, dto, CancellationToken.None);

            var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
            Assert.Equal(StatusCodes.Status404NotFound, status);
            Assert.False(api!.isSuccess);
        }
        finally
        {
            await conn.DisposeAsync();
            await ctx.DisposeAsync();
        }
    }

    [Fact]
    public async Task AddSection_Should_Insert_At_End_And_Return_200()
    {
        var (ctx, conn) = SqlTestHelper.CreateInMemory();
        try
        {
            var examId = await SeedHelper.SeedExamAsync(ctx);
            await SeedHelper.SeedSectionsAsync(ctx, examId, (1, "A"), (2, "B"));

            var svc = new AdminSectionService(ctx);
            var dto = new DtoAdmin.AdminSectionUpsert(
                ExamId: examId,
                Idx: 1, // append cuối
                Title: "C",
                InstructionsMd: "Null"
            );

            var result = await svc.AddAsync(dto, CancellationToken.None);

            var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
            Assert.Equal(StatusCodes.Status200OK, status);
            Assert.True(api is not null, "api is null");
            Assert.True(api!.message is not null, $"no message; isSuccess={api.isSuccess}");
            Assert.True(api.isSuccess, $"isSuccess=false; message={api.message}");
            Assert.True(api!.isSuccess);

            var order = await ctx.ExamSections.Where(x => x.ExamId == examId)
                .OrderBy(x => x.Idx).Select(x => x.Idx).ToListAsync();
            Assert.Equal(new[] { 1, 2, 3 }, order);
        }
        finally
        {
            await conn.DisposeAsync();
            await ctx.DisposeAsync();
        }
    }

    [Fact]
    public async Task UpdateAync_Should_Update_One_Row()
    {
        var (ctx, conn) = SqlTestHelper.CreateInMemory();
        try
        {
            var examId = await SeedHelper.SeedExamAsync(ctx);
            var secs = await SeedHelper.SeedSectionsAsync(ctx, examId, (1, "A"));
            var id = secs[0].Id;

            var dto = new DtoAdmin.AdminSectionUpdate
            (
                ExamId: examId,
                Idx: 5,
                Title: "A-Updated",
                InstructionsMd: "MD"
            );
            var svc = new AdminSectionService(ctx);
            var result = await svc.UpdateAync(dto, id, CancellationToken.None);

            var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
            Assert.Equal(StatusCodes.Status200OK, status);
            Assert.True(api!.isSuccess);
            Assert.Contains("Update 1", api.message);
        }
        finally
        {
            await conn.DisposeAsync();
            await ctx.DisposeAsync();
        }
    }

    [Fact]
    public async Task DeleteAsync_Should_Delete_One_Row()
    {
        var (ctx, conn) = SqlTestHelper.CreateInMemory();
        try
        {
            var examId = await SeedHelper.SeedExamAsync(ctx);
            var secs = await SeedHelper.SeedSectionsAsync(ctx, examId, (1, "A"));
            var id = secs[0].Id;

            var svc = new AdminSectionService(ctx);
            var result = await svc.DeleteAsync(id, CancellationToken.None);

            var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
            Assert.Equal(StatusCodes.Status200OK, status);
            Assert.True(api!.isSuccess);
            Assert.Contains("Deleted 1", api.message);

            Assert.Equal(0, await ctx.ExamSections.CountAsync());
        }
        finally
        {
            await conn.DisposeAsync();
            await ctx.DisposeAsync();
        }
    }

    [Fact]
    public async Task DeleteAsync_Should_Return_Deleted_0_When_Id_NotFound()
    {
        var (ctx, conn) = SqlTestHelper.CreateInMemory();
        try
        {
            var svc = new AdminSectionService(ctx);
            var result = await svc.DeleteAsync(123456, CancellationToken.None);

            var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
            Assert.Equal(StatusCodes.Status200OK, status);
            Assert.True(api!.isSuccess);
            Assert.Contains("Deleted 0", api.message);
        }
        finally
        {
            await conn.DisposeAsync();
            await ctx.DisposeAsync();
        }
    }
}