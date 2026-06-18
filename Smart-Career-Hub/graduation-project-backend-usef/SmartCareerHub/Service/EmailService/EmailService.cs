using SendGrid;
using SendGrid.Helpers.Mail;

namespace SmartCareerHub.Services
{
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _config;

        public EmailService(IConfiguration config)
        {
            _config = config;
        }

        public async Task SendOtpEmailAsync(string toEmail, string userName, string otp)
        {
            var apiKey = _config["SendGrid:ApiKey"];
            var fromEmail = _config["SendGrid:FromEmail"];
            var fromName = _config["SendGrid:FromName"];

            var client = new SendGridClient(apiKey);

            var msg = new SendGridMessage
            {
                From = new EmailAddress(fromEmail, fromName),
                Subject = "Your verification code"
            };

            msg.AddTo(new EmailAddress(toEmail));

            msg.HtmlContent = $@"
            <!DOCTYPE html>
            <html>
            <body style='font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;'>
              <div style='max-width: 500px; margin: auto; background: white; border-radius: 10px; padding: 30px;'>
                <h2 style='color: #1a73e8; text-align: center;'>Smart Career Hub</h2>
                <p>Hello, <strong>{userName}</strong></p>
                <p>We received a request to reset your password. Use the verification code below to continue:</p>
                <div style='text-align: center; margin: 30px 0;'>
                  <div style='
                    display: inline-block;
                    background: #f0f7ff;
                    border: 2px dashed #1a73e8;
                    border-radius: 8px;
                    padding: 16px 40px;
                    font-size: 32px;
                    font-weight: bold;
                    color: #1a73e8;
                    letter-spacing: 8px;'>
                    {otp}
                  </div>
                  <p style='color: #888; font-size: 12px; margin-top: 8px;'>This code changes every time</p>
                </div>
                <p style='color: #555;'>This code is valid for <strong>10 minutes</strong> and will expire shortly.</p>
                <hr style='border: none; border-top: 1px solid #eee; margin: 20px 0;'>
                <p style='color: #999; font-size: 12px; font-style: italic;'>
                  If you didn't request this, please ignore this email.
                </p>
                <p style='color: #555;'>Best regards,<br><strong>Yousef Amr @ Smart Career Hub Team</strong></p>
              </div>
            </body>
            </html>";

            var response = await client.SendEmailAsync(msg);

            if (!response.IsSuccessStatusCode)
            {
                var body = await response.Body.ReadAsStringAsync();
                throw new Exception($"SendGrid Error [{response.StatusCode}]: {body}");
            }
        }
    }
}