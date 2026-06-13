using SmartCareerHub.Contracts.Auth;
using DataAccess.Abstractions;
using System.Threading.Tasks;

namespace Business_Logic.IService
{
    public interface IAuthService
    {
        Task<Result<CompanyResponse>> RegisterCompanyAsync(RegisterCompanyRequest request);

        Task<Result<LoginResponse<CompanyResponse>>> LoginAsync(LoginRequest request);
        Task<Result<string>> VerifyEmailAsync(string email, string otp);
        Task<Result<string>> ResendEmailOtpAsync(string email);

    }
}