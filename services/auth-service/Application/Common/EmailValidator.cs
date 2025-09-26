using System.Globalization;
using System.Net.Mail;

namespace auth_service.Application.Common;

public interface IEmailValidator
{
    bool IsValid(string? email);
}

public class EmailValidator : IEmailValidator
{
    public bool IsValid(string? email)
    {
        if (string.IsNullOrWhiteSpace(email))
        {
            return false;
        }

        var trimmed = email.Trim();
        var at = trimmed.LastIndexOf('@');
        if (at <= 0 || at == trimmed.Length - 1)
        {
            return false;
        }

        var local = trimmed[..at];
        var domain = trimmed[(at + 1)..];
        try
        {
            domain = new IdnMapping().GetAscii(domain);
        }
        catch
        {
            return false;
        }

        var candidate = $"{local}@{domain}";
        return MailAddress.TryCreate(candidate, out var address) && address.Address == candidate;
    }
}