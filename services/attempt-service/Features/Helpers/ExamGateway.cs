using Grpc.Core;
using Shared.Grpc.ExamInternal;

namespace attempt_service.Features.Helpers;

public interface IExamGateway
{
    Task<InternalDeliveryExam> GetExamSnapshotAsync(Guid examId, CancellationToken ct);
}

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
}

public static class GrpcSnapshotSanitizer
{
    public static InternalDeliveryExam Sanitize(InternalDeliveryExam exam)
    {
        var clone = exam.Clone(); // protobuf có IDeepCloneable
        foreach (var sec in clone.Sections)
        foreach (var q in sec.Questions)
        foreach (var o in q.Options)
            if (o.HasIsCorrect)
                o.ClearIsCorrect(); // unset optional bool
        return clone;
    }
}
