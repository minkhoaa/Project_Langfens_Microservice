using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace dictionary_service.Domains.Entities
{
    public sealed class DictionaryEntry
    {
        public long Id { get; set; }                 // bigserial
        public string WordNorm { get; set; } = "";   // lower(trim(word))
        public string Word { get; set; } = "";
        public string Pos { get; set; } = "unknown";
        public JsonElement Data { get; set; }     // raw json line -> jsonb
        public DateTimeOffset ImportedAt { get; set; } = DateTimeOffset.UtcNow;
    }

}