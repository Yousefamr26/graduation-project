using DataAccess.Abstractions;
using SmartCareerHub.Contracts.Auth;

namespace Business_Logic.IService
{
    public interface IGraduateAuthService
    {
        Task<Result<GraduateResponse>> RegisterGraduateAsync(RegisterGraduateRequest request);
        Task<Result<LoginResponse<GraduateResponse>>> LoginAsync(LoginRequest request);
        Task<Result<string>> VerifyEmailAsync(string email, string otp);
        Task<Result<string>> ResendEmailOtpAsync(string email);
    }
}