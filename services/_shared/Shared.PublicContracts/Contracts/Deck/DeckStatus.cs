namespace Shared.ExamDto.Contracts.Deck;

public class DeckStatus
{

        public static string Draft = "DRAFT";
        public static string Published = "PUBLISHED";
        static HashSet<string> alls = [Draft, Published];
        public static bool IsValid(string status) => alls.Contains(status);
}