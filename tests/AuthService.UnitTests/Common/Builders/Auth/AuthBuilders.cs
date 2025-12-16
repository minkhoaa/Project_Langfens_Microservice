extern alias authsvc;
// Move builders to this project
using authsvc::auth_service.Application.Auth;
namespace AuthService.UnitTests.Common.Builders.Auth
{
    public class RegisterDtoBuilder
    {
        private string _email = "test.user@example.com";
        private string _password = "Password123!";
        public RegisterDtoBuilder WithEmail(string email) { _email = email; return this; }
        public RegisterDtoBuilder WithPassword(string password) { _password = password; return this; }
        public RegisterDto Build() { return new RegisterDto(_email, _password); }
    }
    public class LoginDtoBuilder
    {
        private string _email = "test.user@example.com";
        private string _password = "Password123!";
        public LoginDtoBuilder WithEmail(string email) { _email = email; return this; }
        public LoginDtoBuilder WithPassword(string password) { _password = password; return this; }
        public LoginDto Build() { return new LoginDto(_email, _password); }
    }
}
