namespace SmartCareerHub.Services
{
    public interface IEmailService
    {
        Task SendOtpEmailAsync(string toEmail, string userName, string otp);
    }
}