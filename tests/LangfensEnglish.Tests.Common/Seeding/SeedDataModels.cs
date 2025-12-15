namespace LangfensEnglish.Tests.Common.Seeding;

public record SeededUser(Guid Id, string Email, string Password, string Role);
public record SeededExam(Guid Id, string Slug);
public record SeededCourse(Guid Id, string Slug);
public record SeededDeck(Guid Id, string Slug);

public record SeedContext(
    SeededUser User,
    SeededUser Admin,
    SeededExam Exam,
    SeededCourse Course,
    SeededDeck Deck);
