using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace email_service.Features
{
    public static class EmailEndpoint
    {
        public static void MapEmailEndpoint(this IEndpointRouteBuilder app)
        {
            app.MapGroup("/api/mail");
        }
    }
}