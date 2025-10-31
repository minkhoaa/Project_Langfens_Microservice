namespace Shared.ExamDto.Contracts.Deck;

public static class DeckCategory
{
    public static string Toeic = "TOEIC";
    public static string Ielts = "IELTS";
    public static string Vstep = "VSTEP";

     static HashSet<string> alls = [Toeic, Vstep, Ielts];
    public static bool IsValid(string category) => alls.Contains(category);
}