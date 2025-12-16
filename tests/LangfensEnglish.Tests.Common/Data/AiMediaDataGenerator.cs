namespace LangfensEnglish.Tests.Common.Data;

/// <summary>
/// Generates test data specifically for AI/Media service test cases.
/// Provides >= 11 scenarios per requirement (SP-xxx, WR-xxx).
/// </summary>
public static class AiMediaDataGenerator
{
    #region SP-001 to SP-009: Speaking Service Cases

    /// <summary>
    /// SP-001: JSON extraction from LLM output test cases.
    /// Returns: (caseId, rawLlmOutput, expectedJsonOrThrow)
    /// </summary>
    public static IEnumerable<object?[]> GetJsonExtractCases()
    {
        // Clean JSON
        yield return new object?[] { "SP-001-01", "{\"score\": 7.5}", "{\"score\": 7.5}", false };
        yield return new object?[] { "SP-001-02", "[1, 2, 3]", "[1, 2, 3]", false };
        
        // JSON with leading garbage
        yield return new object?[] { "SP-001-03", "Here is the result: {\"score\": 8}", "{\"score\": 8}", false };
        yield return new object?[] { "SP-001-04", "```json\n{\"data\": true}\n```", "{\"data\": true}", false };
        
        // Nested JSON
        yield return new object?[] { "SP-001-05", "{\"outer\": {\"inner\": 1}}", "{\"outer\": {\"inner\": 1}}", false };
        
        // JSON with escaped quotes
        yield return new object?[] { "SP-001-06", "{\"text\": \"He said \\\"hello\\\"\"}", "{\"text\": \"He said \\\"hello\\\"\"}", false };
        
        // Array at root
        yield return new object?[] { "SP-001-07", "Result: [{\"a\":1},{\"b\":2}]", "[{\"a\":1},{\"b\":2}]", false };
        
        // No JSON (should throw)
        yield return new object?[] { "SP-001-08", "This is plain text without JSON", null, true };
        yield return new object?[] { "SP-001-09", "", null, true };
        yield return new object?[] { "SP-001-10", "   ", null, true };
        
        // Incomplete JSON (should throw)
        yield return new object?[] { "SP-001-11", "{\"incomplete\": ", null, true };
    }

    /// <summary>
    /// SP-003: Cloud upload test cases (mocked).
    /// Returns: (caseId, fileName, fileSize, mockSuccess, expectedStatus)
    /// </summary>
    public static IEnumerable<object[]> GetCloudUploadCases()
    {
        yield return new object[] { "SP-003-01", "audio.mp3", 1024, true, "Uploaded" };
        yield return new object[] { "SP-003-02", "audio.wav", 2048, true, "Uploaded" };
        yield return new object[] { "SP-003-03", "recording.m4a", 512, true, "Uploaded" };
        yield return new object[] { "SP-003-04", "audio.mp3", 1024, false, "UploadFailed" };
        yield return new object[] { "SP-003-05", "", 0, false, "BadRequest" };
        yield return new object[] { "SP-003-06", "audio.mp3", 0, false, "BadRequest" };
        yield return new object[] { "SP-003-07", "audio.mp3", 100_000_000, false, "TooLarge" };
        yield return new object[] { "SP-003-08", "audio.exe", 1024, false, "InvalidFormat" };
        yield return new object[] { "SP-003-09", "audio.mp3", 1024, true, "Uploaded" };
        yield return new object[] { "SP-003-10", "test.webm", 4096, true, "Uploaded" };
        yield return new object[] { "SP-003-11", "long_recording.ogg", 50000, true, "Uploaded" };
    }

    /// <summary>
    /// SP-005: Whisper transcription test cases (mocked).
    /// Returns: (caseId, audioUrl, mockTranscript, mockSuccess)
    /// </summary>
    public static IEnumerable<object?[]> GetWhisperTranscriptionCases()
    {
        yield return new object?[] { "SP-005-01", "https://cdn/audio1.mp3", "Hello world", true };
        yield return new object?[] { "SP-005-02", "https://cdn/audio2.mp3", "This is a test", true };
        yield return new object?[] { "SP-005-03", "https://cdn/audio3.mp3", "", true };  // Silent audio
        yield return new object?[] { "SP-005-04", "https://cdn/audio4.mp3", null, false };  // Service error
        yield return new object?[] { "SP-005-05", "", null, false };  // Empty URL
        yield return new object?[] { "SP-005-06", null, null, false };  // Null URL
        yield return new object?[] { "SP-005-07", "https://cdn/long.mp3", "A long transcription with many words that tests the limits of the system.", true };
        yield return new object?[] { "SP-005-08", "https://cdn/unicode.mp3", "日本語テスト", true };  // Unicode
        yield return new object?[] { "SP-005-09", "https://cdn/noise.mp3", "[inaudible]", true };
        yield return new object?[] { "SP-005-10", "https://cdn/timeout.mp3", null, false };  // Timeout
        yield return new object?[] { "SP-005-11", "https://cdn/valid.mp3", "Valid transcription result", true };
    }

    #endregion

    #region WR-001 to WR-007: Writing Service Cases

    /// <summary>
    /// WR-001: Word count test cases.
    /// Returns: (caseId, text, expectedWordCount)
    /// </summary>
    public static IEnumerable<object?[]> GetWordCountCases()
    {
        yield return new object?[] { "WR-001-01", "Hello world", 2 };
        yield return new object?[] { "WR-001-02", "One", 1 };
        yield return new object?[] { "WR-001-03", "", 0 };
        yield return new object?[] { "WR-001-04", null, 0 };
        yield return new object?[] { "WR-001-05", "   ", 0 };
        yield return new object?[] { "WR-001-06", "Word1  Word2   Word3", 3 };  // Multiple spaces
        yield return new object?[] { "WR-001-07", "Line1\nLine2", 2 };  // Newlines
        yield return new object?[] { "WR-001-08", "Tab\tSeparated", 2 };  // Tabs
        yield return new object?[] { "WR-001-09", "Mixed\n\t  spaces", 2 };
        yield return new object?[] { "WR-001-10", "A B C D E F G H I J K", 11 };  // Many words
        yield return new object?[] { "WR-001-11", "   Leading and trailing spaces   ", 4 };
    }

    /// <summary>
    /// WR-003: LLM dirty data parsing test cases.
    /// Returns: (caseId, dirtyLlmOutput, shouldParse)
    /// </summary>
    public static IEnumerable<object?[]> GetLlmDirtyDataCases()
    {
        // Clean JSON
        yield return new object?[] { "WR-003-01", "{\"band\": 7.0, \"comment\": \"Good\"}", true };
        
        // Markdown code block wrapper
        yield return new object?[] { "WR-003-02", "```json\n{\"band\": 6.5}\n```", true };
        yield return new object?[] { "WR-003-03", "```\n{\"band\": 6.0}\n```", true };
        
        // Leading explanation text
        yield return new object?[] { "WR-003-04", "Here is the grading result:\n{\"band\": 7.5}", true };
        yield return new object?[] { "WR-003-05", "Based on the IELTS criteria:\n\n{\"band\": 8.0}", true };
        
        // Trailing garbage
        yield return new object?[] { "WR-003-06", "{\"band\": 5.5}\n\nLet me know if you need more details!", true };
        
        // Completely invalid
        yield return new object?[] { "WR-003-07", "I cannot grade this essay because...", false };
        yield return new object?[] { "WR-003-08", "The band score is 7.0", false };  // No JSON
        
        // Partial/broken JSON
        yield return new object?[] { "WR-003-09", "{\"band\": 6.5, \"comment\":", false };
        yield return new object?[] { "WR-003-10", "{band: 7.0}", false };  // Invalid JSON syntax
        
        // Empty response
        yield return new object?[] { "WR-003-11", "", false };
    }

    /// <summary>
    /// WR-005: Writing submission consumer test cases.
    /// Returns: (caseId, essayText, taskType, expectedProcessed)
    /// </summary>
    public static IEnumerable<object?[]> GetWritingSubmissionCases()
    {
        yield return new object?[] { "WR-005-01", "This is a sample essay about technology.", "Task2", true };
        yield return new object?[] { "WR-005-02", "The chart shows...", "Task1", true };
        yield return new object?[] { "WR-005-03", "", "Task2", false };
        yield return new object?[] { "WR-005-04", null, "Task2", false };
        yield return new object?[] { "WR-005-05", "   ", "Task2", false };
        yield return new object?[] { "WR-005-06", "Valid essay text", "", false };
        yield return new object?[] { "WR-005-07", "Valid essay text", null, false };
        yield return new object?[] { "WR-005-08", new string('a', 10000), "Task2", true };  // Long essay
        yield return new object?[] { "WR-005-09", "Short.", "Task1", true };
        yield return new object?[] { "WR-005-10", "Essay with special chars: éàü", "Task2", true };
        yield return new object?[] { "WR-005-11", "Multiple\nlines\nessay", "Task2", true };
    }

    #endregion
}
