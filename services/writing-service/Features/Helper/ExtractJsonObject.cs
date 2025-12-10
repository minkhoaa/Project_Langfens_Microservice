namespace writing_service.Features.Helper
{
    public static class ExtractJsonObject
    {
        public static string Extract(string text)
        {
            text = text.Trim();

            // Nếu đã bắt đầu bằng { hoặc [ thì thử parse luôn
            if (text.StartsWith("{") || text.StartsWith("["))
                return text;

            // Nếu có rác phía trước, tìm dấu { đầu tiên
            var firstBrace = text.IndexOf('{');
            var firstBracket = text.IndexOf('[');
            int start = -1;
            if (firstBrace >= 0 && firstBracket >= 0)
                start = Math.Min(firstBrace, firstBracket);
            else
                start = Math.Max(firstBrace, firstBracket); // cái nào != -1

            if (start < 0)
                throw new InvalidOperationException("No JSON object/array found in model output.");

            // Từ đó trở đi, cố gắng cân ngoặc
            int depth = 0;
            bool inString = false;
            bool escape = false;
            char open = text[start];
            char close = open == '{' ? '}' : ']';

            for (int i = start; i < text.Length; i++)
            {
                char ch = text[i];

                if (escape)
                {
                    escape = false;
                    continue;
                }

                if (ch == '\\')
                {
                    escape = true;
                    continue;
                }

                if (ch == '"')
                {
                    inString = !inString;
                    continue;
                }

                if (!inString)
                {
                    if (ch == open) depth++;
                    else if (ch == close) depth--;

                    if (depth == 0)
                    {
                        // JSON kết thúc ở đây
                        return text.Substring(start, i - start + 1);
                    }
                }
            }

            throw new InvalidOperationException("Could not find complete JSON object/array.");
        }

    }
}