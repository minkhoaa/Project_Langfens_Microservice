using exam_service.Infrastructure.Persistence;
using Grpc.Core;
using Shared.Grpc.ExamInternal;
namespace exam_service.Features.Exams.InternalEndpoint;
public sealed class ExamInternalGrpcService(ExamDbContext context, IConfiguration configuration)
    : ExamInternal.ExamInternalBase
{

   
}