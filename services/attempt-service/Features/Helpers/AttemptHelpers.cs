using System.Security.Claims;

namespace attempt_service.Features.Helpers;

public interface IUserContent
{
    int UserId { get; }
    ClaimsPrincipal _claimsPrincipal { get;  }
}
public class AttemptHelpers
{
    
   
}