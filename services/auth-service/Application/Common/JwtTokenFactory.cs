using System.IdentityModel.Tokens.Jwt;
using System.Runtime.InteropServices;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using auth_service.Infrastructure.Persistence;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Shared.Security.Claims;

namespace auth_service.Application.Common;

public interface IJwtTokenFactory
{
    Task<string> CreateTokenAsync(User user, IEnumerable<string> roles,
        IEnumerable<string> scopes, 
        string sid,
        CancellationToken ct);
}

public class JwtTokenFactory : IJwtTokenFactory
{

    private readonly JwtSettings _settings;
    private readonly RsaSecurityKey _signKey;
    private readonly string _kid;

    public JwtTokenFactory(IOptions<JwtSettings> jwt)
    {
        _settings = jwt.Value;

        var rsa = RSA.Create();
        rsa.ImportFromPem(_settings.RsaPrivateKeyPem);
        _signKey = new RsaSecurityKey(rsa);
        _kid = _settings.KeyId;
    }
    public Task<string> CreateTokenAsync(User user, IEnumerable<string> roles, IEnumerable<string> scopes, 
        string sid, CancellationToken ct)
    {
        var now = DateTimeOffset.UtcNow;

        var claims = new List<Claim>
        {
            new (CustomClaims.Sub, user.Id),
            new (CustomClaims.Scope, string.Join(' ', scopes)),
            new ("sid", sid)
        };
        foreach (var role in roles)
        {
            claims.Add(new Claim(CustomClaims.Roles, role));
            claims.Add(new Claim(ClaimTypes.Role, role));
        }

        claims.Add(new Claim(JwtRegisteredClaimNames.Iat, now.ToUnixTimeSeconds().ToString(), ClaimValueTypes.Integer64));
        claims.Add(new Claim(JwtRegisteredClaimNames.Nbf, now.ToUnixTimeSeconds().ToString(), ClaimValueTypes.Integer64));
        claims.Add(new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString("N")));
        
        
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_settings.SignKey));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var token = new JwtSecurityToken(
            issuer: _settings.Issuer,
            audience: _settings.Audience,
            claims: claims,
            expires: DateTime.UtcNow.AddSeconds(_settings.AccessTokenLifetimeSeconds),
            signingCredentials: creds
        )
        {
            Header =
            {
                ["kid"] = _kid
            }
        };
        var handler = new JwtSecurityTokenHandler();
        var accessToken = handler.WriteToken(token);
        return Task.FromResult(accessToken);
    }
}