using System.Security.Cryptography;

namespace auth_service.Application.Common;


public interface IOtpGenerator
{
    string Generate();
}
public class OtpGenerator : IOtpGenerator
{
    public string Generate() => RandomNumberGenerator.GetInt32(100000, 1000000).ToString();
}
