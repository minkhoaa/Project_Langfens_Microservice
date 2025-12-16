namespace Shared.ExamDto.Contracts.Auth_Email;

public record UserRegisteredSendOtp
(
    string Email,
    string Otp,
    long TtlSeconds
)
{
    public UserRegisteredSendOtp() : this(default!, default!, default) { }
}
public record UserRegisteredConfirmOtp
(
    string Email,
    string Otp
);
