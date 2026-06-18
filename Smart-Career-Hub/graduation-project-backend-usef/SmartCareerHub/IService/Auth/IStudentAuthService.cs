using DataAccess.Abstractions;
using SmartCareerHub.Contracts.Auth;

namespace Business_Logic.IService
{
    public interface IStudentAuthService
    {
        Task<Result<StudentResponse>> RegisterStudentAsync(RegisterStudentRequest request);
        Task<Result<LoginResponse<StudentResponse>>> LoginAsync(LoginRequest request);
        Task<Result<string>> VerifyEmailAsync(string email, string otp);
        Task<Result<string>> ResendEmailOtpAsync(string email);
    }
}