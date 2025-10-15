using email_service.Features.Service;
using Microsoft.AspNetCore.Mvc;

namespace email_service.Features.Handler;

public static class EmailSenderHandler
{
    public static Task<IResult> VerifyEmailHandler(
        [FromQuery] string email,
        [FromQuery] string otp,
        CancellationToken token,
        IEmailSender sender
    ) => sender.VerifyOtpAsync(email, otp, token);
}