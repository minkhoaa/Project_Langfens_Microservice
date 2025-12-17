using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using dictionary_service.Contracts;

namespace dictionary_service.Features.Helper
{
    public interface IEnViTranslator
    {
        /// <summary>
        /// Dịch 1 câu định nghĩa tiếng Anh sang tiếng Việt để hiển thị "giải thích".
        /// Return null nếu không dịch được.
        /// </summary>
        Task<string?> TranslateDefinitionAsync(string english, CancellationToken ct);
    }

    /// <summary>
    /// Default translator: không dịch (để MVP chạy ngay).
    /// Bạn thay bằng implementation thật (OpenAI/Google/Azure/local model...) sau.
    /// </summary>
    public sealed class NullEnViTranslator : IEnViTranslator
    {
        public Task<string?> TranslateDefinitionAsync(string english, CancellationToken ct)
            => Task.FromResult<string?>(null);
    }

    public interface IDictionaryDtoMapper
    {
        // Giữ sync cho backward compatible: chỉ map EN + VI terms (không có DefinitionVi)
        DictionaryDetailsDto ToDetailsDto(DictionaryDoc doc, int maxSenses, int maxExamplesPerSense);

        // Async: có thêm DefinitionVi (dịch EN->VI)
        Task<DictionaryDetailsDto> ToDetailsDtoAsync(DictionaryDoc doc, int maxSenses, int maxExamplesPerSense, CancellationToken ct);
    }

    public sealed class DictionaryDtoMapper : IDictionaryDtoMapper
    {
        private readonly IEnViTranslator _translator;

        public DictionaryDtoMapper(IEnViTranslator translator)
        {
            _translator = translator;
        }

        public DictionaryDetailsDto ToDetailsDto(DictionaryDoc doc, int maxSenses, int maxExamplesPerSense)
        {
            // Không dịch câu EN->VI (DefinitionVi=null), vẫn có VI terms
            return BuildDto(doc, maxSenses, maxExamplesPerSense, translateVi: false, ct: default).GetAwaiter().GetResult();
        }

        public Task<DictionaryDetailsDto> ToDetailsDtoAsync(DictionaryDoc doc, int maxSenses, int maxExamplesPerSense, CancellationToken ct)
        {
            // Có dịch EN->VI
            return BuildDto(doc, maxSenses, maxExamplesPerSense, translateVi: true, ct: ct);
        }

        private async Task<DictionaryDetailsDto> BuildDto(DictionaryDoc doc, int maxSenses, int maxExamplesPerSense, bool translateVi, CancellationToken ct)
        {
            // doc.Data: full entry json (forms/senses/sounds/translations/...)
            var entry = doc.Data;

            var prons = ExtractPronunciations(entry);
            var forms = ExtractForms(entry);

            // VI terms ở entry-level (fallback)
            var viFallback = ExtractVietnameseTerms(entry);

            // senses EN
            var senses = ExtractSenses(entry, viFallback, maxSenses, maxExamplesPerSense);

            if (translateVi && senses.Count > 0)
            {
                // cache theo definition để tránh dịch lặp
                var cache = new Dictionary<string, string?>(StringComparer.Ordinal);
                foreach (var s in senses)
                {
                    if (string.IsNullOrWhiteSpace(s.DefinitionEn)) continue;

                    if (!cache.TryGetValue(s.DefinitionEn, out var vi))
                    {
                        vi = await _translator.TranslateDefinitionAsync(s.DefinitionEn, ct);
                        // normalize nhẹ
                        vi = string.IsNullOrWhiteSpace(vi) ? null : vi.Trim();
                        cache[s.DefinitionEn] = vi;
                    }

                    s.DefinitionVi = vi;
                }
            }

            return new DictionaryDetailsDto(
                Id: doc.Id,
                Word: doc.Word,
                Pos: doc.Pos,
                WordNorm: doc.WordNorm,
                ImportedAt: doc.ImportedAt,
                Pronunciations: prons,
                Forms: forms,
                Senses: senses.Select(x => x.ToDto()).ToList(),
                VietnameseTerms: viFallback
            );
        }

        private static IReadOnlyList<PronunciationDto> ExtractPronunciations(JsonElement entry)
        {
            var list = new List<PronunciationDto>();
            if (!entry.TryGetProperty("sounds", out var sounds) || sounds.ValueKind != JsonValueKind.Array)
                return list;

            foreach (var s in sounds.EnumerateArray())
            {
                var ipa = GetString(s, "ipa");
                var mp3 = GetString(s, "mp3_url");
                if (string.IsNullOrWhiteSpace(ipa) && string.IsNullOrWhiteSpace(mp3)) continue;

                var tags = GetStringArray(s, "tags");
                var region =
                    tags.Contains("US", StringComparer.OrdinalIgnoreCase) ? "US" :
                    tags.Contains("UK", StringComparer.OrdinalIgnoreCase) ||
                    tags.Contains("Received-Pronunciation", StringComparer.OrdinalIgnoreCase) ? "UK" :
                    null;

                list.Add(new PronunciationDto(region, ipa, mp3));
            }

            return list
                .GroupBy(x => $"{x.Region}|{x.Ipa}|{x.Mp3Url}")
                .Select(g => g.First())
                .OrderBy(x => x.Region == "UK" ? 0 : x.Region == "US" ? 1 : 2)
                .Take(4)
                .ToList();
        }

        private static IReadOnlyList<FormDto> ExtractForms(JsonElement entry)
        {
            var list = new List<FormDto>();
            if (!entry.TryGetProperty("forms", out var forms) || forms.ValueKind != JsonValueKind.Array)
                return list;

            foreach (var f in forms.EnumerateArray())
            {
                var form = GetString(f, "form");
                if (string.IsNullOrWhiteSpace(form)) continue;

                var tags = GetStringArray(f, "tags");

                // MVP: giữ vài loại hay dùng
                var keep = tags.Any(t =>
                    t is "plural" or "past" or "present" or "participle" or "third-person"
                      or "comparative" or "superlative" or "alternative");

                if (!keep) continue;

                list.Add(new FormDto(form!, tags));
            }

            return list.Take(12).ToList();
        }

        private static List<string> ExtractVietnameseTerms(JsonElement entryOrSense)
        {
            var outSet = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            if (!entryOrSense.TryGetProperty("translations", out var translations) || translations.ValueKind != JsonValueKind.Array)
                return outSet.ToList();

            foreach (var t in translations.EnumerateArray())
            {
                var code = GetString(t, "code") ?? GetString(t, "lang_code");
                var lang = GetString(t, "lang");

                var isVi =
                    string.Equals(code, "vi", StringComparison.OrdinalIgnoreCase) ||
                    string.Equals(lang, "Vietnamese", StringComparison.OrdinalIgnoreCase);

                if (!isVi) continue;

                // ưu tiên word (từ điển, tự điển...)
                var w = GetString(t, "word");
                if (!string.IsNullOrWhiteSpace(w)) outSet.Add(w!);

                // nếu bạn muốn giữ cả alt (chữ Hán) thì có thể append "(詞典)" v.v.
                // var alt = GetString(t, "alt");
            }

            return outSet.Take(20).ToList();
        }

        private static List<SenseBuild> ExtractSenses(JsonElement entry, List<string> viFallback, int maxSenses, int maxExamplesPerSense)
        {
            var list = new List<SenseBuild>();
            if (!entry.TryGetProperty("senses", out var senses) || senses.ValueKind != JsonValueKind.Array)
                return list;

            foreach (var s in senses.EnumerateArray())
            {
                if (list.Count >= maxSenses) break;

                var id = GetString(s, "id") ?? "";

                var labels = GetStringArray(s, "tags");

                // qualifier (nếu có)
                var qualifier = GetString(s, "qualifier");
                if (!string.IsNullOrWhiteSpace(qualifier))
                    labels = labels.Concat(new[] { qualifier! }).ToList();

                var def =
                    FirstStringInArray(s, "glosses")
                    ?? FirstStringInArray(s, "raw_glosses")
                    ?? "";

                if (string.IsNullOrWhiteSpace(def)) continue;

                var examples = ExtractExampleTexts(s, maxExamplesPerSense);

                // VI terms: sense-level nếu có, không thì fallback entry-level
                var viSense = ExtractVietnameseTerms(s);
                if (viSense.Count == 0) viSense = viFallback;

                list.Add(new SenseBuild
                {
                    Id = id,
                    DefinitionEn = def,
                    DefinitionVi = null, // sẽ fill bằng translator (nếu gọi ToDetailsDtoAsync)
                    Labels = labels,
                    VietnameseTerms = viSense,
                    Examples = examples
                });
            }

            return list;
        }

        private static IReadOnlyList<string> ExtractExampleTexts(JsonElement sense, int max)
        {
            var list = new List<string>();
            if (!sense.TryGetProperty("examples", out var examples) || examples.ValueKind != JsonValueKind.Array)
                return list;

            foreach (var ex in examples.EnumerateArray())
            {
                if (list.Count >= max) break;
                var text = GetString(ex, "text");
                if (!string.IsNullOrWhiteSpace(text)) list.Add(text!);
            }
            return list;
        }

        private static string? GetString(JsonElement obj, string prop)
            => obj.TryGetProperty(prop, out var v) && v.ValueKind == JsonValueKind.String ? v.GetString() : null;

        private static List<string> GetStringArray(JsonElement obj, string prop)
        {
            if (!obj.TryGetProperty(prop, out var arr) || arr.ValueKind != JsonValueKind.Array)
                return new List<string>();

            var list = new List<string>();
            foreach (var x in arr.EnumerateArray())
            {
                if (x.ValueKind == JsonValueKind.String && !string.IsNullOrWhiteSpace(x.GetString()))
                    list.Add(x.GetString()!);
            }
            return list;
        }

        private static string? FirstStringInArray(JsonElement obj, string prop)
        {
            if (!obj.TryGetProperty(prop, out var arr) || arr.ValueKind != JsonValueKind.Array)
                return null;

            foreach (var x in arr.EnumerateArray())
            {
                if (x.ValueKind == JsonValueKind.String && !string.IsNullOrWhiteSpace(x.GetString()))
                    return x.GetString();
            }
            return null;
        }

        // internal build model (để fill DefinitionVi trước khi map sang record immutable)
        private sealed class SenseBuild
        {
            public string Id { get; set; } = "";
            public string DefinitionEn { get; set; } = "";
            public string? DefinitionVi { get; set; }
            public IReadOnlyList<string> Labels { get; set; } = Array.Empty<string>();
            public IReadOnlyList<string> VietnameseTerms { get; set; } = Array.Empty<string>();
            public IReadOnlyList<string> Examples { get; set; } = Array.Empty<string>();

            public SenseDto ToDto() => new(
                Id: Id,
                DefinitionEn: DefinitionEn,
                DefinitionVi: DefinitionVi,
                Labels: Labels,
                VietnameseTerms: VietnameseTerms,
                Examples: Examples
            );
        }
    }
}
