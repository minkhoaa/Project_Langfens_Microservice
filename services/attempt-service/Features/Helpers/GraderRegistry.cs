namespace attempt_service.Features.Helpers;

public sealed class GraderRegistry
{
    private readonly Dictionary<string, IGrader> _bySlug;

    public GraderRegistry(IEnumerable<IGrader> graders)
    {
        _bySlug = graders.ToDictionary(g => g.Slug, StringComparer.Ordinal);
    }

    public IGrader Resolve(string slug)
        => _bySlug.TryGetValue(slug, out var g)
            ? g
            : throw new UnknownQuestionTypeException(slug);

    public bool TryResolve(string slug, out IGrader? grader)
        => _bySlug.TryGetValue(slug, out grader);
}