using DataAccess.Abstractions;
using SmartCareerHub.Contracts.Auth;

namespace Business_Logic.IService
{
    public interface IUniversityAuthService
    {
        Task<Result<UniversityRegisterResponse>> RegisterUniversityAsync(UniversityRegisterRequest request);
        Task<Result<LoginResponse<UniversityRegisterResponse>>> LoginAsync(LoginRequest request);
        Task<Result<string>> VerifyEmailAsync(string email, string otp);
        Task<Result<string>> ResendEmailOtpAsync(string email);
    }
}