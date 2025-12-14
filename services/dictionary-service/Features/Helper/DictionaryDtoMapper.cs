using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using dictionary_service.Contracts;

namespace dictionary_service.Features.Helper
{
    public interface IDictionaryDtoMapper
    {
        public DictionaryDetailsDto ToDetailsDto(DictionaryDoc doc, int maxSenses, int maxExamplesPerSense);

    }
    public class DictionaryDtoMapper : IDictionaryDtoMapper
    {
        public DictionaryDetailsDto ToDetailsDto(DictionaryDoc doc, int maxSenses, int maxExamplesPerSense)
        {
            // doc.Data: full entry json (forms/senses/sounds/translations/...)
            var entry = doc.Data;

            var prons = ExtractPronunciations(entry);
            var forms = ExtractForms(entry);

            // Fallback: nếu translations không sense-disambiguated, ta vẫn có list VI tổng.
            var viFallback = ExtractVietnameseTranslations(entry);

            var senses = ExtractSenses(entry, maxSenses, maxExamplesPerSense);

            return new DictionaryDetailsDto(
                Id: doc.Id,
                Word: doc.Word,
                Pos: doc.Pos,
                WordNorm: doc.WordNorm,
                ImportedAt: doc.ImportedAt,
                Pronunciations: prons,
                Forms: forms,
                Senses: senses,
                Vietnamese: viFallback
            );
        }

        private IReadOnlyList<PronunciationDto> ExtractPronunciations(JsonElement entry)
        {
            var list = new List<PronunciationDto>();
            if (!entry.TryGetProperty("sounds", out var sounds) || sounds.ValueKind != JsonValueKind.Array)
                return list;

            foreach (var s in sounds.EnumerateArray())
            {
                var ipa = GetString(s, "ipa");
                var mp3 = GetString(s, "mp3_url"); // Kaikki/wiktextract thường có mp3_url/ogg_url 
                if (string.IsNullOrWhiteSpace(ipa) && string.IsNullOrWhiteSpace(mp3)) continue;

                var tags = GetStringArray(s, "tags");
                var region =
                    tags.Contains("US", StringComparer.OrdinalIgnoreCase) ? "US" :
                    tags.Contains("UK", StringComparer.OrdinalIgnoreCase) || tags.Contains("Received-Pronunciation", StringComparer.OrdinalIgnoreCase) ? "UK" :
                    null;

                list.Add(new PronunciationDto(region, ipa, mp3));
            }

            // Ưu tiên UK/US trước, giới hạn cho gọn
            return list
                .GroupBy(x => $"{x.Region}|{x.Ipa}|{x.Mp3Url}")
                .Select(g => g.First())
                .OrderBy(x => x.Region == "UK" ? 0 : x.Region == "US" ? 1 : 2)
                .Take(4)
                .ToList();
        }

        static IReadOnlyList<FormDto> ExtractForms(JsonElement entry)
        {
            var list = new List<FormDto>();
            if (!entry.TryGetProperty("forms", out var forms) || forms.ValueKind != JsonValueKind.Array)
                return list;

            foreach (var f in forms.EnumerateArray())
            {
                var form = GetString(f, "form");
                if (string.IsNullOrWhiteSpace(form)) continue;

                var tags = GetStringArray(f, "tags");

                // MVP: giữ vài loại hay dùng (plural/past/…/alternative)
                var keep = tags.Any(t =>
                    t is "plural" or "past" or "present" or "participle" or "third-person" or "comparative" or "superlative" or "alternative");

                if (!keep) continue;

                list.Add(new FormDto(form, tags));
            }

            return list.Take(12).ToList();
        }

        static IReadOnlyList<SenseDto> ExtractSenses(JsonElement entry, int maxSenses, int maxExamplesPerSense)
        {
            var list = new List<SenseDto>();
            if (!entry.TryGetProperty("senses", out var senses) || senses.ValueKind != JsonValueKind.Array)
                return list;

            foreach (var s in senses.EnumerateArray())
            {
                if (list.Count >= maxSenses) break;

                var id = GetString(s, "id") ?? "";
                var labels = GetStringArray(s, "tags");

                // qualifier (ví dụ “preceded by the”, “frequently figurative”… trong data của bạn) :contentReference[oaicite:6]{index=6}
                var qualifier = GetString(s, "qualifier");
                if (!string.IsNullOrWhiteSpace(qualifier)) labels = labels.Concat(new[] { qualifier! }).ToList();

                var def =
                    FirstStringInArray(s, "glosses")
                    ?? FirstStringInArray(s, "raw_glosses")
                    ?? "";

                var examples = ExtractExampleTexts(s, maxExamplesPerSense);

                // Translations có thể nằm ở word-level hoặc sense-level 
                var vi = ExtractVietnameseTranslations(s); // thử lấy translations ngay trong sense

                list.Add(new SenseDto(
                    Id: id,
                    DefinitionEn: def,
                    Labels: labels,
                    Vietnamese: vi,
                    Examples: examples
                ));
            }

            return list;
        }

        static IReadOnlyList<string> ExtractExampleTexts(JsonElement sense, int max)
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

        static IReadOnlyList<string> ExtractVietnameseTranslations(JsonElement entryOrSense)
        {
            var outList = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            if (!entryOrSense.TryGetProperty("translations", out var translations) || translations.ValueKind != JsonValueKind.Array)
                return outList.ToList();

            foreach (var t in translations.EnumerateArray())
            {
                // wiktextract: thường có "code" cho ngôn ngữ (vi) + "lang" + "word"/"alt" 
                var code = GetString(t, "code") ?? GetString(t, "lang_code");
                var lang = GetString(t, "lang");

                var isVi =
                    string.Equals(code, "vi", StringComparison.OrdinalIgnoreCase) ||
                    string.Equals(lang, "Vietnamese", StringComparison.OrdinalIgnoreCase);

                if (!isVi) continue;

                var w = GetString(t, "alt") ?? GetString(t, "word");
                if (!string.IsNullOrWhiteSpace(w)) outList.Add(w!);
            }

            return outList.Take(10).ToList(); // gọn payload
        }

        static string? GetString(JsonElement obj, string prop)
            => obj.TryGetProperty(prop, out var v) && v.ValueKind == JsonValueKind.String ? v.GetString() : null;

        static List<string> GetStringArray(JsonElement obj, string prop)
        {
            if (!obj.TryGetProperty(prop, out var arr) || arr.ValueKind != JsonValueKind.Array)
                return new List<string>();

            var list = new List<string>();
            foreach (var x in arr.EnumerateArray())
                if (x.ValueKind == JsonValueKind.String && !string.IsNullOrWhiteSpace(x.GetString()))
                    list.Add(x.GetString()!);
            return list;
        }

        static string? FirstStringInArray(JsonElement obj, string prop)
        {
            if (!obj.TryGetProperty(prop, out var arr) || arr.ValueKind != JsonValueKind.Array)
                return null;

            foreach (var x in arr.EnumerateArray())
                if (x.ValueKind == JsonValueKind.String && !string.IsNullOrWhiteSpace(x.GetString()))
                    return x.GetString();

            return null;
        }
    }
}