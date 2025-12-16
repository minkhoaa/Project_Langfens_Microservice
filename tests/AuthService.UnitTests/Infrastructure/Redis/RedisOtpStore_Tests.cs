extern alias authsvc;
using authsvc::auth_service.Infrastructure.Redis;
using FluentAssertions;
using Microsoft.AspNetCore.Identity;
using Moq;
using StackExchange.Redis;
using Xunit;

namespace AuthService.UnitTests.Infrastructure.Redis
{
    public class RedisOtpStore_Tests
    {
        private readonly Mock<IConnectionMultiplexer> _mockMultiplexer;
        private readonly Mock<IDatabase> _mockDatabase;
        private readonly Mock<IPasswordHasher<string>> _mockHasher;
        private readonly RedisOtpStore _sut;

        public RedisOtpStore_Tests()
        {
            _mockMultiplexer = new Mock<IConnectionMultiplexer>();
            _mockDatabase = new Mock<IDatabase>();
            _mockHasher = new Mock<IPasswordHasher<string>>();

            _mockMultiplexer.Setup(m => m.GetDatabase(It.IsAny<int>(), It.IsAny<object>())).Returns(_mockDatabase.Object);
            _sut = new RedisOtpStore(_mockMultiplexer.Object, _mockHasher.Object);
        }

        private static RedisKey KeyOtp(string email) => $"otp:{email}";
        private static RedisKey KeyTry(string email) => $"otp:tries:{email}";
        private static RedisKey KeyBlock(string email) => $"otp:block:{email}";

        public static IEnumerable<object[]> Verify_TestCases()
        {
            var email = "test@example.com";
            var otp = "123456";
            var hashedOtp = "hashed_otp_string";
            var maxAttempts = 3;
            yield return new object[] { "OE-001_Case01_IsBlocked", true, null, PasswordVerificationResult.Failed, 0, false, false, false };
            yield return new object[] { "OE-001_Case02_HashIsNull", false, RedisValue.Null, PasswordVerificationResult.Failed, 0, false, false, false };
            yield return new object[] { "OE-001_Case03_Success", false, (RedisValue)hashedOtp, PasswordVerificationResult.Success, 0, true, false, true };
            yield return new object[] { "OE-001_Case04_Failure_1st", false, (RedisValue)hashedOtp, PasswordVerificationResult.Failed, 1, false, false, false };
            yield return new object[] { "OE-001_Case05_Failure_2nd", false, (RedisValue)hashedOtp, PasswordVerificationResult.Failed, 2, false, false, false };
            yield return new object[] { "OE-001_Case06_Failure_3rd_Block", false, (RedisValue)hashedOtp, PasswordVerificationResult.Failed, 3, false, true, false };
            yield return new object[] { "OE-001_Case07_SuccessReusedPw", false, (RedisValue)hashedOtp, PasswordVerificationResult.SuccessRehashNeeded, 0, false, false, false };
            yield return new object[] { "OE-001_Case08_NullOtp", false, (RedisValue)hashedOtp, PasswordVerificationResult.Failed, 0, false, false, false, null };
            yield return new object[] { "OE-001_Case09_EmptyEmail", false, RedisValue.Null, PasswordVerificationResult.Failed, 0, false, false, false, otp, "" };
            yield return new object[] { "OE-001_Case10_Failure_AlmostBlock", false, (RedisValue)hashedOtp, PasswordVerificationResult.Failed, maxAttempts - 1, false, false, false };
            yield return new object[] { "OE-001_Case11_Failure_OverBlock", false, (RedisValue)hashedOtp, PasswordVerificationResult.Failed, maxAttempts + 1, false, true, false };
        }

        [Theory(DisplayName = "{0}")]
        [MemberData(nameof(Verify_TestCases))]
        public async Task Verify_Should_Implement_OtpLogic_Correctly(
            string caseId, bool isBlocked, RedisValue storedHash, PasswordVerificationResult verificationResult,
            long tries, bool expectSuccess, bool verifyBlockSet, bool verifyClearCalled, string otp = "123456", string email = "test@example.com")
        {
            _ = caseId;
            var normEmail = email.Trim().ToLowerInvariant();
            _mockDatabase.Setup(db => db.KeyExistsAsync(KeyBlock(normEmail), It.IsAny<CommandFlags>())).ReturnsAsync(isBlocked);
            _mockDatabase.Setup(db => db.StringGetAsync(It.IsAny<RedisKey>(), It.IsAny<CommandFlags>())).ReturnsAsync(storedHash);
            // Use It.IsAny<string> for hash to avoid potential Moq expression tree issues with RedisValue implicit conversion
            _mockHasher.Setup(h => h.VerifyHashedPassword(normEmail, It.Is<string>(s => s == storedHash.ToString()), otp)).Returns(verificationResult);
            _mockDatabase.Setup(db => db.StringIncrementAsync(KeyTry(normEmail), 1, It.IsAny<CommandFlags>())).ReturnsAsync(tries);

            var result = await _sut.Verify(email, otp, 3, TimeSpan.FromMinutes(5));

            result.Should().Be(expectSuccess);
            if (verifyBlockSet)
            {
                _mockDatabase.Verify(db => db.StringSetAsync(KeyBlock(normEmail), "1", TimeSpan.FromMinutes(5), false, It.IsAny<When>(), It.IsAny<CommandFlags>()), Times.Once);
            }
            else
            {
                _mockDatabase.Verify(db => db.StringSetAsync(KeyBlock(normEmail), It.IsAny<RedisValue>(), It.IsAny<TimeSpan?>(), false, It.IsAny<When>(), It.IsAny<CommandFlags>()), Times.Never);
            }
            if (verifyClearCalled)
            {
                _mockDatabase.Verify(db => db.KeyDeleteAsync(It.IsAny<RedisKey[]>(), It.IsAny<CommandFlags>()), Times.Once);
            }
        }

        public static IEnumerable<object[]> CanResend_TestCases()
        {
            yield return new object[] { "OE-002_Case01", "test@example.com", true, false };
            yield return new object[] { "OE-002_Case02", "test@example.com", false, true };
            for (int i = 3; i <= 11; i++)
            {
                yield return new object[] { $"OE-002_Case{i:D2}", $"test{i}@example.com", i % 2 == 0, i % 2 != 0 };
            }
        }

        [Theory(DisplayName = "{0}")]
        [MemberData(nameof(CanResend_TestCases))]
        public async Task CanResend_Should_Check_CooldownKey(string caseId, string email, bool keyExists, bool expectedResult)
        {
            _ = caseId;
            var normEmail = email.Trim().ToLowerInvariant();
            _mockDatabase.Setup(db => db.KeyExistsAsync($"otp:cool:{normEmail}", It.IsAny<CommandFlags>())).ReturnsAsync(keyExists);
            var result = await _sut.CanResend(email, TimeSpan.FromSeconds(30));
            result.Should().Be(expectedResult);
        }
    }
}