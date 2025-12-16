using System.Net;
using System.Text.Json;
using email_service.Contracts;
using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.Extensions.Options;
using MimeKit;
using Shared.ExamDto.Contracts;

namespace email_service.Features.Service;

public interface IEmailSender
{
    Task SendOtpAsync(string toEmail, string otp, long ttlSeconds, CancellationToken token);
    Task SendAsync(string toEmail, string subject, string html, string? plain = null, CancellationToken token = default);
    Task<IResult> VerifyOtpAsync(string email, string otp, CancellationToken token);

}
public class EmailSender(IOptions<SmtpOptions> options, IHttpClientFactory httpClient, ILogger<string> logger) : IEmailSender
{
    private readonly SmtpOptions _smtpOptions = options.Value;


    public virtual async Task SendAsync(string toEmail, string subject, string html, string? plain = null,
        CancellationToken token = default)
    {
        var msg = new MimeMessage();
        msg.From.Add(MailboxAddress.Parse(_smtpOptions.From));
        msg.To.Add(MailboxAddress.Parse(toEmail));
        msg.Subject = subject;
        var body = new BodyBuilder()
        {
            HtmlBody = html,
            TextBody = plain ?? "",

        }.ToMessageBody();
        msg.Body = body;
        using var client = new SmtpClient();
        client.CheckCertificateRevocation = true;

        try
        {
            // 587: STARTTLS, 465: SSL on connect
            var secure = _smtpOptions.Port == 465 ? SecureSocketOptions.SslOnConnect : SecureSocketOptions.StartTls;
            await client.ConnectAsync(_smtpOptions.Host, _smtpOptions.Port, secure, token)!;
            if (!string.IsNullOrEmpty(_smtpOptions.User))
                await client.AuthenticateAsync(_smtpOptions.User, _smtpOptions.Pass, token)!;
            await client.SendAsync(msg, token)!;
            Console.WriteLine($"Sent to {toEmail}");
            await client.DisconnectAsync(true, token)!;
        }
        catch (Exception e)
        {
            Console.WriteLine($"Failed while sending email to {toEmail}", e.Message);
            logger.LogInformation($"Failed while sending email to {toEmail}", e.Message);
        }
    }

    public async Task SendOtpAsync(string toEmail, string otp, long ttlSeconds, CancellationToken token)
    {
        var html = BuildOtpHtml(toEmail, otp, ttlSeconds, _smtpOptions);
        var plain = BuildOtpPlain(toEmail, otp, ttlSeconds, _smtpOptions);
        var subject = $"Your verification code is: {otp}";
        await SendAsync(toEmail, subject, html, plain, token);
    }

    public async Task<IResult> VerifyOtpAsync(string email, string otp, CancellationToken token)
    {
        if (string.IsNullOrWhiteSpace(_smtpOptions.VerifyUrlTemplate))
            throw new InvalidOperationException("AuthConfirmEndpoint is not configured.");

        var http = httpClient.CreateClient("auth-confirm");
        var uri = QueryHelpers.AddQueryString(
            _smtpOptions.VerifyUrlTemplate,
            new Dictionary<string, string?> { ["email"] = email, ["otp"] = otp });

        using var resp = await http.GetAsync(uri, token);
        var body = await resp.Content.ReadAsStringAsync(token);

        logger.LogInformation("Confirm call => {Url} | {Status} | {Body}", uri, (int)resp.StatusCode, body);

        try
        {
            var dto = JsonSerializer.Deserialize<ApiResultDto>(body, new JsonSerializerOptions(JsonSerializerDefaults.Web));
            return Results.Json(dto, statusCode: (int)resp.StatusCode);
        }
        catch
        {
            var contentType = resp.Content.Headers.ContentType?.ToString() ?? "application/json";
            return Results.Content(body, contentType: contentType, statusCode: (int)resp.StatusCode);
        }
    }
    private static string BuildOtpPlain(string email, string otp, long ttl, SmtpOptions o)
    {
        var minutes = Math.Max(1, ttl / 60);
        var link = RenderUrl(email, otp, o);
        return $"Hello {email},\nYour verification code is: {otp}\n" +
               $"This code will expire in {minutes} minute(s).\n" +
               (string.IsNullOrWhiteSpace(link) ? "" : $"Verify link: {link}\n") +
               $"If you didn’t request this, contact {o.Support}.";
    }

    private static string BuildOtpHtml(string email, string otp, long ttl, SmtpOptions o)
    {
        var minutes = Math.Max(1, ttl / 60);
        var link = RenderUrl(email, otp, o);
        var button = string.IsNullOrWhiteSpace(link) ? "" :
            $@"<a href=""{link}"" style=""display:inline-block;padding:12px 20px;border-radius:8px;
            background:#4F46E5;color:#fff;text-decoration:none;font-weight:600"">Verify Account</a>";
        return $"""
                <!doctype html>
                <html lang="en">
                <head>
                  <meta charset="utf-8" />
                  <meta name="viewport" content="width=device-width, initial-scale=1" />
                  <title>{o.Brand} - Verification Code</title>
                </head>
                <body style="background:#f6f7fb;margin:0;padding:24px;font-family:system-ui,Arial">
                  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width:600px;margin:auto;background:#ffffff;border-radius:12px;overflow:hidden">
                    <tr>
                      <td style="padding:24px 24px 8px">
                        <h2 style="margin:0 0 8px 0;font-size:20px;color:#111827">{o.Brand}</h2>
                        <p style="margin:0;color:#6B7280;font-size:14px">Email verification code</p>
                      </td>
                    </tr>
                    <tr>
                      <td style="padding:8px 24px 24px">
                        <p style="margin:0 0 12px 0;color:#111827">Hello <b>{email}</b>,</p>
                        <p style="margin:0 0 16px 0;color:#111827">Your verification code is:</p>
                        <div style="font-size:32px;letter-spacing:6px;font-weight:800;color:#111827;margin:8px 0 16px 0">{otp}</div>
                        <p style="margin:0 0 16px 0;color:#374151">
                          This code will expire in <b>{minutes} minute(s)</b>.
                        </p>
                        <hr style="border:none;border-top:1px solid #e5e7eb;margin:20px 0" />
                        <p style="margin:0;color:#6B7280;font-size:12px">
                          If you didn’t request this, please ignore this email or contact us at {o.Support}.
                        </p>
                      </td>
                    </tr>
                  </table>
                </body>
                </html>
                """;
    }
    private static string RenderUrl(string email, string otp, SmtpOptions options)
        => string.IsNullOrWhiteSpace(options.RedirectUrl)
            ? ""
            :   QueryHelpers.AddQueryString(
        options.RedirectUrl,
     new Dictionary<string, string?> { ["email"] = email, ["otp"] = otp });

}