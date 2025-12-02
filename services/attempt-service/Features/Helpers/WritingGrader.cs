using Writing.Internal;

namespace attempt_service.Features.Helpers
{
    public interface IWritingGrader
    {
        Task<IResult> GradeAsync(string Task, string Answer);
    }
    public class WritingGrader : IWritingGrader
    {
        private readonly WritingGradingServiceGrpc.WritingGradingServiceGrpcClient _client;
        public WritingGrader(WritingGradingServiceGrpc.WritingGradingServiceGrpcClient client)
        {
            _client = client;
        }

        public async Task<IResult> GradeAsync(string Task, string Answer)
        {
            var req = new GradeEssayRequest
            {
                TaskText = Task,
                AnswerText = Answer,
            };
            var res = await _client.GradeWritingAsync(req);
            return Results.Ok(res);
        }
    }
}