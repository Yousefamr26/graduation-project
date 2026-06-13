using DataAccess.Abstractions;
using SmartCareerHub.Contracts.Auth;

namespace Business_Logic.IService
{
    public interface ITrainingCenterAuthService
    {
        Task<Result<TrainingCenterRegisterResponse>> RegisterTrainingCenterAsync(TrainingCenterRegisterRequest request);
        Task<Result<LoginResponse<TrainingCenterRegisterResponse>>> LoginAsync(LoginRequest request);
        Task<Result<string>> VerifyEmailAsync(string email, string otp);
        Task<Result<string>> ResendEmailOtpAsync(string email);
    }
}