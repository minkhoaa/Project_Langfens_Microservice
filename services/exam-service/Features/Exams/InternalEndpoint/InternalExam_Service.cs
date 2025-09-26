using exam_service.Contracts.Exams;
using exam_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.EntityFrameworkCore;
using Shared.Contracts.Contracts;

namespace exam_service.Features.Exams.InternalEndpoint;
public interface IInternalExamService
{
    public Task<IResult> GetByExamIdAsync(int examId, CancellationToken token, bool showAnswer);
}

public class InternalExamService : IInternalExamService
{
    private readonly ExamDbContext _context;
    public InternalExamService(ExamDbContext context) => _context = context;
    public async Task<IResult> GetByExamIdAsync(int examId, CancellationToken token, bool showAnswer)
    {
        try {
         var paper = await _context.Exams.AsNoTracking()
             .Where(x=> x.Id == examId)
             .Select(exam => new DtoInternal.InternalDeliveryExam(
                 examId, 
                 exam.Slug,
                 exam.Slug,
                 exam.DescriptionMd,
                 exam.Category,
                 exam.Level,
                 exam.DurationMin, 
                 exam.Sections.Where(s=>s.ExamId == exam.Id).Select(
                     section => new DtoInternal.InternalDeliverySection(
                         section.Idx, 
                         section.Title, 
                         section.InstructionsMd,
                         section.Questions.Where(a=>a.SectionId == section.Id)
                             .Select(question => new DtoInternal.InternalDeliveryQuestion(
                                 question.Idx, 
                                 question.Type, 
                                 question.Skill,
                                 question.Difficulty,
                                 question.PromptMd,
                                 question.ExplanationMd,
                                 question.Options.Where(d => d.QuestionId == question.Id)
                                     .Select(option => new DtoInternal.InternalDeliveryOption(
                                         option.Idx, 
                                         option.ContentMd,
                                         (showAnswer) ?  option.IsCorrect : null!
                                         )).ToList()
                                 )).ToList()
                        )).ToList()
             )).FirstOrDefaultAsync(token);
         return (paper != null) ? Results.Ok(new ApiResultDto(true, "Success", paper)) 
             : Results.NotFound(new ApiResultDto(false, "Not found", null!)) ;
        }
        catch (Exception e)
        {
            return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
        }
    }
    
}