namespace Shared.PublicContracts.Events;

/// <summary>
/// Published by auth-service when a user completes email verification
/// </summary>
public record UserCreatedEvent(Guid UserId, string Email, DateTime CreatedAt);
