using Microsoft.AspNetCore.Identity;
using StackExchange.Redis;

namespace auth_service.Infrastructure.Redis;

public interface IOtpStore
{
    Task PutOtp(string email, string rawOtp, TimeSpan ttlSeconds);
    Task<bool> CanResend(string email, TimeSpan cooldownSeconds);
    Task TouchResendCooldown(string email, TimeSpan cooldownSeconds);
    Task<bool> IsBlocked(string email);
    Task<bool> Verify(string email, string rawOtp, int maxAttempts, TimeSpan blockSeconds);
    Task Clear(string email);
}

public sealed class RedisOtpStore(IConnectionMultiplexer redis, IPasswordHasher<string> hasher)
    : IOtpStore
{
    private static RedisKey KeyOtp(string email)   => $"otp:{email}";
    private static RedisKey KeyTry(string email)   => $"otp:tries:{email}";
    private static RedisKey KeyBlock(string email) => $"otp:block:{email}";
    private static RedisKey KeyCool(string email)  => $"otp:cool:{email}";
    private string Normalize(string email) => email.Trim().ToLowerInvariant();
    private readonly IDatabase _redis = redis.GetDatabase();

    public async Task PutOtp(string email, string rawOtp, TimeSpan ttlSeconds)
    {
        email = Normalize(email);
        var key = KeyOtp(email);
        var hash = hasher.HashPassword(email, rawOtp);
        await _redis.StringSetAsync(key, hash, ttlSeconds);
        await _redis.KeyDeleteAsync(KeyTry(email));
    }

    public async Task<bool> CanResend(string email, TimeSpan cooldownSeconds)
        => !await _redis.KeyExistsAsync(KeyCool(Normalize(email)));

    public Task TouchResendCooldown(string email, TimeSpan cooldownSeconds)
    {
        email = Normalize(email);
        return _redis.StringSetAsync(KeyCool(email), 
            new RedisValue("1"), cooldownSeconds);
    }

    public Task<bool> IsBlocked(string email) 
        =>  _redis.KeyExistsAsync(KeyBlock(Normalize(email)));

    public async Task<bool> Verify(string email, string rawOtp, int maxAttempts, TimeSpan blockSeconds)
    {
        email = Normalize(email);
        if (await IsBlocked(email).ConfigureAwait(false)) return false;
        var otpKey = KeyOtp(email);
        var hashed = await _redis.StringGetAsync(otpKey);
        if (hashed.IsNullOrEmpty) return false;
        var hashedOtp = (string)hashed!;
        var result = hasher.VerifyHashedPassword(email, hashedOtp, rawOtp);
        if (result == PasswordVerificationResult.Success)
        {
            await Clear(email);
            return true; 
        }

        var triesKey = KeyTry(email);
        var tries = await _redis.StringIncrementAsync(triesKey);
        if (tries == 1)
        {
            var remain = await _redis.KeyTimeToLiveAsync(otpKey) ?? TimeSpan.FromSeconds(60);
            await _redis.KeyExpireAsync(triesKey, remain);
            
        }

        if (tries >= maxAttempts)
        {
            await _redis.StringSetAsync(KeyBlock(email), "1", blockSeconds);
        }

        return false;
    }

    public async Task Clear(string email)
    {
        email = Normalize(email);
        await _redis.KeyDeleteAsync([
            KeyCool(email), 
            KeyOtp(email), 
            KeyTry(email), 
            KeyBlock(email)]);
    }
}