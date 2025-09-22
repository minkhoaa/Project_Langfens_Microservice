using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using auth_service.Models;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace auth_service.Application.Common;
public interface IJwtTokenFactory
{
    Task<string> CreateTokenAsync(User user, IEnumerable<string> roles, CancellationToken ct);
}

public class JwtTokenFactory : IJwtTokenFactory
{
    private readonly JwtSettings _settings;

    public JwtTokenFactory(IOptions<JwtSettings> options)
    {
        _settings = options.Value;
    }

    public Task<string> CreateTokenAsync(User user, IEnumerable<string> roles, CancellationToken ct)
    {
        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, user.Id),
            new(ClaimTypes.Email, user.Email ?? string.Empty),
            new(ClaimTypes.Name, user.UserName ?? user.Email ?? string.Empty)
        };

        claims.AddRange(roles.Select(role => new Claim(ClaimTypes.Role, role)));

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_settings.SignKey));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var token = new JwtSecurityToken(
            issuer: _settings.Issuer,
            audience: _settings.Audience,
            claims: claims,
            expires: DateTime.UtcNow.AddSeconds(_settings.AccessTokenLifetimeSeconds),
            signingCredentials: creds
        );

        var handler = new JwtSecurityTokenHandler();
        var accessToken = handler.WriteToken(token);
        return Task.FromResult(accessToken);
    }
}
