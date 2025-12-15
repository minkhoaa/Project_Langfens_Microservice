namespace LangfensEnglish.Tests.Common.Utils;

public static class TimeWaiter
{
    public static Task WaitForExpiryAsync(TimeSpan ttl, CancellationToken ct = default) =>
        Task.Delay(ttl + TimeSpan.FromMilliseconds(200), ct);
}
