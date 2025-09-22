using System.Reflection.Metadata;
using Microsoft.CodeAnalysis.CSharp;
using Shared.Contracts.Contracts;

namespace exam_service.Application.Exam;

public record ExamOperationResults(ApiResultDto results, int statusCode) 
{   
    public static ExamOperationResults Success(ApiResultDto results, int statusCode) 
        =>  new(results, StatusCodes.Status200OK); 
    public static ExamOperationResults NotFound(ApiResultDto results, int statusCode)
        => new(results, StatusCodes.Status404NotFound) ;
    public static ExamOperationResults BadRequest(ApiResultDto results, int statusCode)
        => new (results, StatusCodes.Status400BadRequest);
}