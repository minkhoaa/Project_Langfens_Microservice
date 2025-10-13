using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace email_service.Contracts
{
    public sealed record SmtpOptions
    {
        public string Host { get; init; } = "";
        public int Port { get; init; } = 587;
        public string User { get; init; } = "";
        public string Pass { get; init; } = "";
        public string From { get; init; } = "Langfens <no-reply@langfens.com>";
        public string Brand { get; init; } = "Langfens English";
        public string Support { get; init; } = "support@langfens.com";
        public string VerifyUrlTemplate { get; init; } = "";
    }
}