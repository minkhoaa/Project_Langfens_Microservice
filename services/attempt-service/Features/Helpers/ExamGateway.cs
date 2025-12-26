using Grpc.Core;
using Shared.Grpc.ExamInternal;

namespace attempt_service.Features.Helpers;

public interface IExamGateway
{
    Task<InternalDeliveryExam> GetExamSnapshotAsync(Guid examId, CancellationToken ct);
    Task<List<ExamListItem>> GetExamListAsync(CancellationToken ct);
}

public record ExamListItem(Guid Id, string? Title, string? Category, int QuestionCount);

public class ExamGateway : IExamGateway
{
    private readonly ExamInternal.ExamInternalClient _client;
    public ExamGateway(ExamInternal.ExamInternalClient client) => _client = client;

    public async Task<InternalDeliveryExam> GetExamSnapshotAsync(Guid examId, CancellationToken ct)
    {
        var req = new GetInternalExamRequest { ExamId = examId.ToString(), ShowAnswers = true };
        // có thể set deadline nếu muốn:
        var callOptions = new CallOptions(deadline: DateTime.UtcNow.AddSeconds(5), cancellationToken: ct);
        return await _client.GetInternalExamAsync(req, callOptions)!;
    }
    
    public async Task<List<ExamListItem>> GetExamListAsync(CancellationToken ct)
    {
        try
        {
            var callOptions = new CallOptions(deadline: DateTime.UtcNow.AddSeconds(10), cancellationToken: ct);
            var response = await _client.GetExamListAsync(new GetExamListRequest(), callOptions);
            return response.Exams.Select(e => new ExamListItem(
                Guid.TryParse(e.Id, out var id) ? id : Guid.Empty,
                e.Title,
                e.Category,
                e.QuestionCount
            )).Where(e => e.Id != Guid.Empty).ToList();
        }
        catch
        {
            return new List<ExamListItem>();
        }
    }
}

public static class GrpcSnapshotSanitizer
{
    public static InternalDeliveryExam Sanitize(InternalDeliveryExam exam)
    {
        var clone = exam.Clone(); // protobuf có IDeepCloneable
        foreach (var sec in clone.Sections)
        foreach (var grp in sec.QuestionGroups)
        foreach (var q in grp.Questions)
        foreach (var o in q.Options)
            if (o.HasIsCorrect)
                o.ClearIsCorrect(); // unset optional bool
        foreach (var sec in clone.Sections)
        foreach (var grp in sec.QuestionGroups)
        foreach (var q in grp.Questions)
        {
            q.CompletionAccepts.Clear();
            q.MatchPairs.Clear();
            q.OrderCorrects.Clear();
            q.ShortAnswerAcceptTexts.Clear();
            q.ShortAnswerAcceptRegex.Clear();
        }
        return clone;
    }
}
