namespace LangfensEnglish.Tests.Common.Utils;

public record DiscoveryEntry(
    string Service,
    string BaseRoute,
    IReadOnlyCollection<string> Endpoints,
    IReadOnlyCollection<string> ConfigKeys,
    string AuthScheme);

public sealed class DiscoveryReport
{
    private readonly List<DiscoveryEntry> _entries = new();

    public IReadOnlyCollection<DiscoveryEntry> Entries => _entries;

    public void Add(DiscoveryEntry entry) => _entries.Add(entry);
}
