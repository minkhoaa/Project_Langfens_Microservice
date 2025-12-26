namespace attempt_service.Features.Analytics;

public static class AiInsightsPrompt
{
    public const string SystemPrompt = """
You are an expert IELTS tutor analyzing a student's test performance data.
Based on the provided data, generate helpful insights and study recommendations.

RESPONSE FORMAT (JSON only):
{
  "summary": "2-3 sentence natural language summary of current level and recent progress",
  "trendAnalysis": "1-2 sentences about improvement trend or areas needing attention",
  "recommendations": [
    "Specific actionable tip 1",
    "Specific actionable tip 2",
    "Specific actionable tip 3"
  ],
  "focusAreas": [
    {
      "skill": "Reading|Listening|Writing|Speaking",
      "area": "Specific area like 'Matching Headings' or 'Task Response'",
      "reason": "Brief explanation why this needs focus",
      "priority": 1
    }
  ]
}

GUIDELINES:
- Be encouraging but honest
- Give specific, actionable recommendations (not generic advice)
- Focus on 2-4 priority areas maximum
- Use Vietnamese for summary and recommendations
- Keep responses concise and practical
""";

    public static string BuildUserPrompt(
        decimal overallBand,
        decimal? readingBand,
        decimal? listeningBand,
        decimal? writingBand,
        decimal? speakingBand,
        string confidence,
        int sampleSize,
        List<(string type, decimal accuracy)>? strengths,
        List<(string type, decimal accuracy)>? weaknesses)
    {
        var strengthsStr = strengths != null && strengths.Count > 0
            ? string.Join(", ", strengths.Select(s => $"{s.type}: {s.accuracy:F0}%"))
            : "No data";
            
        var weaknessesStr = weaknesses != null && weaknesses.Count > 0
            ? string.Join(", ", weaknesses.Select(w => $"{w.type}: {w.accuracy:F0}%"))
            : "No data";

        return $"""
STUDENT DATA:
- Overall Predicted Band: {overallBand:F1}
- Reading: {(readingBand.HasValue ? readingBand.Value.ToString("F1") : "N/A")}
- Listening: {(listeningBand.HasValue ? listeningBand.Value.ToString("F1") : "N/A")}
- Writing: {(writingBand.HasValue ? writingBand.Value.ToString("F1") : "N/A")}
- Speaking: {(speakingBand.HasValue ? speakingBand.Value.ToString("F1") : "N/A")}
- Confidence: {confidence}
- Tests Completed: {sampleSize}
- Strengths: {strengthsStr}
- Weaknesses: {weaknessesStr}

Generate insights and recommendations for this student.
""";
    }
}
