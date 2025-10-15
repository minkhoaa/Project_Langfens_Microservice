namespace auth_service.Application.Common;


public interface IOtpGenerator
{
    string Generate();
}
public class OtpGenerator : IOtpGenerator
{
    public string Generate() => new Random().Next(100000, 999999).ToString();
}