namespace attempt_service.Features.Helpers
{
    public interface ICommandHandler<TCommand>
    {
        Task HandleAsync(TCommand command, CancellationToken ct = default);
    }
    public class CommandHandler : ICommandHandler<GradeAttemptCommand>
    {
        public Task HandleAsync(GradeAttemptCommand command, CancellationToken ct = default)
        {
            throw new NotImplementedException();
        }
    }
    public sealed record GradeAttemptCommand(Guid AttemptId);

}
