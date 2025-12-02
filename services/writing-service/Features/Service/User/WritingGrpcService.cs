using Google.Protobuf;
using Grpc.Core;
using Microsoft.AspNetCore.Antiforgery;
using Microsoft.AspNetCore.Http.HttpResults;
using Writing.Internal;
using writing_service.Contracts;
using writing_service.Features.Helper;
namespace writing_service.Features.Service.User
{
    public class WritingGrpcService : WritingGradingServiceGrpc.WritingGradingServiceGrpcBase
    {
        private readonly IWritingGrader _grader;
        public WritingGrpcService(IWritingGrader grader) => _grader = grader;
        public override async Task<GradeEssayResponse> GradeWriting(GradeEssayRequest request, ServerCallContext context)
        {
            try
            {
                var content = new ContentSubmission
                {
                    Task = request.TaskText,
                    Answer = request.AnswerText
                };
                var (writingRes, llmResponse) = await _grader.Grade(content, CancellationToken.None);
                return new GradeEssayResponse
                {
                    Band = writingRes.OverallBand,
                    Ta = writingRes.TaskResponse.Band,
                    Cc = writingRes.CoherenceAndCohesion.Band,
                    Lr = writingRes.LexicalResource.Band,
                    Gr = writingRes.GrammaticalRangeAndAccuracy.Band,
                    Feedback = writingRes.ImprovedParagraph
                };
            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
        }

    }
}