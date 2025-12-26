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
            .Include(x => x.Sections).ThenInclude(x => x.QuestionGroups)
            .FirstOrDefaultAsync(context.CancellationToken);
        if (exams == null) return null!;
        var res = ProtoHelper.MapToProto(exams, request.ShowAnswers);
        return res;
    }
    
    public override async Task<GetExamListResponse> GetExamList(GetExamListRequest request,
        ServerCallContext context)
    {
        var query = _context.Exams.AsNoTracking()
            .Include(x => x.Sections)
            .ThenInclude(s => s.Questions)
            .AsQueryable();
        
        // Apply filters
        if (!string.IsNullOrEmpty(request.Category))
        {
            query = query.Where(e => e.Category.ToString().ToUpper() == request.Category.ToUpper());
        }
        
        // Limit results
        var limit = request.Limit > 0 ? request.Limit : 50;
        
        var exams = await query.Take(limit).ToListAsync(context.CancellationToken);
        
        var response = new GetExamListResponse();
        foreach (var exam in exams)
        {
            var questionCount = exam.Sections.Sum(s => s.Questions.Count);
            response.Exams.Add(new Shared.Grpc.ExamInternal.ExamListItem
            {
                Id = exam.Id.ToString(),
                Title = exam.Title ?? "",
                Category = exam.Category.ToString(),
                QuestionCount = questionCount,
                DurationMin = exam.DurationMin
            });
        }
        
        return response;
    }
}