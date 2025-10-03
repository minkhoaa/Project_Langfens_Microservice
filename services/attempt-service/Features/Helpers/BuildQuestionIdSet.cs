using System.Text.Json;

namespace attempt_service.Features.Helpers;

public static class BuildQuestionIdSet
{
    public static HashSet<int> Build(JsonDocument paper)
    {
        var set = new HashSet<int>();
        if (!paper.RootElement.TryGetProperty("sections", out var sections)) return set;
        foreach (var s in sections.EnumerateArray())
        {
            if (!s.TryGetProperty("questions", out var qs)) continue;
            foreach (var q in qs.EnumerateArray())
                if (q.TryGetProperty("id", out var idProp))
                    set.Add(idProp.GetInt32());
        }
        return set;
    }
}
public static class QuestionIndex {
    public static Dictionary<int, (int SectionId, string Type, HashSet<int> OptionIds)> Build(JsonDocument doc) {
        var map = new Dictionary<int, (int, string, HashSet<int>)>();
        if (!doc.RootElement.TryGetProperty("sections", out var sections)) return map;
        foreach (var s in sections.EnumerateArray()) {
            var sectionId = s.GetProperty("id").GetInt32();
            if (!s.TryGetProperty("questions", out var qs)) continue;
            foreach (var q in qs.EnumerateArray()) {
                int qid = q.GetProperty("id").GetInt32();
                string type = q.TryGetProperty("type", out var t) ? t.GetString() ?? "" : "";
                var opts = new HashSet<int>();
                if (q.TryGetProperty("options", out var os))
                    foreach (var o in os.EnumerateArray())
                        if (o.TryGetProperty("id", out var oid)) opts.Add(oid.GetInt32());
                map[qid] = (sectionId, type, opts);
            }
        }
        return map;
    }
}