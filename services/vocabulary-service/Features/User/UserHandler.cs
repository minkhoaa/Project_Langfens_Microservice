using vocabulary_service.Contracts;

namespace vocabulary_service.Features.User;

public static class UserHandler
{
    public static Task<IResult> CreateDeck(DeckDto dto, CancellationToken token, IUserService service) =>
        service.CreateDeck(dto, token);
}