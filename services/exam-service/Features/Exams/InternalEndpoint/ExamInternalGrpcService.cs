using exam_service.Application.Common;
using exam_service.Infrastructure.Persistence;
using Grpc.Core;
using Microsoft.EntityFrameworkCore;
using Shared.Grpc.ExamInternal;

namespace exam_service.Features.Exams.InternalEndpoint;

public class ExamInternalGrpcService : ExamInternal.ExamInternalBase
{
    private readonly IConfiguration _configuration;
    private readonly ExamDbContext _context;

    public ExamInternalGrpcService(ExamDbContext context, IConfiguration configuration)
    {
        _configuration = configuration;
        _context = context;
    }

    public override async Task<InternalDeliveryExam> GetInternalExam(GetInternalExamRequest request,
        ServerCallContext context)
    {
        var exams = await _context.Exams.AsNoTracking()
            .Where(x => x.Id.ToString() == request.ExamId)
            .Include(x => x.Sections).ThenInclude(x => x.Questions).ThenInclude(x => x.Options)
            .FirstOrDefaultAsync(context.CancellationToken);
        if (exams == null) return null!;
        var res = ProtoHelper.MapToProto(exams, request.ShowAnswers);
        return res;
    }
}