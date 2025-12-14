namespace AttemptService.UnitTests.Attempt;

internal static class AttemptServiceFactory
{
    public static AttemptServiceImpl Create(
        AttemptDbContext context,
        Guid userId,
        IExamGateway? gateway = null)
    {
        var userContext = Mock.Of<IUserContext>(u => u.UserId == userId);
        var answerValidator = new AnswerValidator();
        var indexBuilder = new IndexBuilder();
        var answerKeyBuilder = new AnswerKeyBuilder(answerValidator);
        var graderFactory = new QuestionGraderFactory(new IQuestionGraderRegistration[]
        {
            new SingleChoiceGraderRegistration(new SingleChoiceGrader()),
            new CompletionGraderRegistration(new CompletionGrader()),
            new LabelGraderRegistration(new LabelGrader()),
            new MatchingHeadingGraderRegistration(new MatchingHeadingGrader()),
            new FlowChartGraderRegistration(new FlowChartGrader()),
            new ShortAnswerGraderRegistration(new ShortAnswerGrader())
        });

        return new AttemptServiceImpl(
            context,
            gateway ?? Mock.Of<IExamGateway>(),
            userContext,
            answerKeyBuilder,
            indexBuilder,
            answerValidator,
            Mock.Of<IPlacementWorkflow>(),
            graderFactory);
    }
}
