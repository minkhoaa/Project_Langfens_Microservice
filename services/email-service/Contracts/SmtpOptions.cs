using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace email_service.Contracts
{
    public sealed record SmtpOptions
    {
        public string Host { get; set; } = "";
        public int Port { get; set; } = 587;
        public string User { get; set; } = "";
        public string Pass { get; set; } = "";
        public string From { get; set; } = "Langfens <no-reply@langfens.com>";
        public string Brand { get; set; } = "Langfens English";
        public string Support { get; set; } = "support@langfens.com";
        public string VerifyUrlTemplate { get; set; } = "";
        public string RedirectUrl { get; set; } = "";
        
    }
}