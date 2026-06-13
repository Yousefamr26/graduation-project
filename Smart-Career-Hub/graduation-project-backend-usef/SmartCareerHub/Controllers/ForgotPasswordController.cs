using DataAccess.Contexts;
using DataAccess.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SmartCareerHub.Services;

namespace SmartCareerHub.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ForgotPasswordController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly ApplicationDbContext _context;
        private readonly IEmailService _emailService;

        public ForgotPasswordController(
            UserManager<ApplicationUser> userManager,
            ApplicationDbContext context,
            IEmailService emailService)
        {
            _userManager = userManager;
            _context = context;
            _emailService = emailService;
        }

        // ==============================
        // STEP 1: Send OTP
        // POST /api/forgotpassword/send-otp
        // ==============================
        [HttpPost("send-otp")]
        public async Task<IActionResult> SendOtp([FromBody] SendOtpRequest request)
        {
            if (string.IsNullOrEmpty(request.Email))
                return BadRequest(new { message = "Email is required." });

            var user = await _userManager.FindByEmailAsync(request.Email);
            if (user == null)
                return NotFound(new { message = "Email not found." });

            // Generate 6-digit OTP
            var otp = new Random().Next(100000, 999999).ToString();
            var expiresAt = DateTime.UtcNow.AddSeconds(30);

            // Save or update OTP
            var existingOtp = await _context.PasswordResetOtps
                .FirstOrDefaultAsync(o => o.UserId == user.Id);

            if (existingOtp != null)
            {
                existingOtp.OtpCode = otp;
                existingOtp.ExpiresAt = expiresAt;
                existingOtp.IsUsed = false;
                existingOtp.CreatedAt = DateTime.UtcNow;
            }
            else
            {
                _context.PasswordResetOtps.Add(new PasswordResetOtp
                {
                    UserId = user.Id,
                    OtpCode = otp,
                    ExpiresAt = expiresAt,
                    IsUsed = false
                });
            }

            await _context.SaveChangesAsync();

            // Send email
            var fullName = $"{user.FirstName} {user.LastName}";
            await _emailService.SendOtpEmailAsync(user.Email, fullName, otp);

            return Ok(new { message = "OTP sent successfully." });
        }

        // ==============================
        // STEP 2: Verify OTP
        // POST /api/forgotpassword/verify-otp
        // ==============================
        [HttpPost("verify-otp")]
        public async Task<IActionResult> VerifyOtp([FromBody] VerifyOtpRequest request)
        {
            if (string.IsNullOrEmpty(request.Email) || string.IsNullOrEmpty(request.Otp))
                return BadRequest(new { message = "Email and OTP are required." });

            var user = await _userManager.FindByEmailAsync(request.Email);
            if (user == null)
                return NotFound(new { message = "User not found." });

            var otpRecord = await _context.PasswordResetOtps
                .FirstOrDefaultAsync(o => o.UserId == user.Id && !o.IsUsed);

            if (otpRecord == null)
                return BadRequest(new { message = "No OTP found. Please request a new one." });

            if (otpRecord.ExpiresAt < DateTime.UtcNow)
                return BadRequest(new { message = "OTP expired. Please request a new one." });

            if (otpRecord.OtpCode != request.Otp)
                return BadRequest(new { message = "Invalid OTP." });

            // Mark as used
            otpRecord.IsUsed = true;
            await _context.SaveChangesAsync();

            return Ok(new { message = "OTP verified successfully." });
        }

        // ==============================
        // STEP 3: Reset Password
        // POST /api/forgotpassword/reset-password
        // ==============================
        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
        {
            if (string.IsNullOrEmpty(request.Email) ||
                string.IsNullOrEmpty(request.NewPassword) ||
                string.IsNullOrEmpty(request.ConfirmPassword))
                return BadRequest(new { message = "All fields are required." });

            if (request.NewPassword != request.ConfirmPassword)
                return BadRequest(new { message = "Passwords do not match." });

            var user = await _userManager.FindByEmailAsync(request.Email);
            if (user == null)
                return NotFound(new { message = "User not found." });

            // Reset password using Identity
            var token = await _userManager.GeneratePasswordResetTokenAsync(user);
            var result = await _userManager.ResetPasswordAsync(user, token, request.NewPassword);

            if (!result.Succeeded)
                return BadRequest(new { message = result.Errors.First().Description });

            return Ok(new { message = "Password reset successfully." });
        }
    }

    // ==============================
    // DTOs
    // ==============================
    public class SendOtpRequest
    {
        public string Email { get; set; } = string.Empty;
    }

    public class VerifyOtpRequest
    {
        public string Email { get; set; } = string.Empty;
        public string Otp { get; set; } = string.Empty;
    }

    public class ResetPasswordRequest
    {
        public string Email { get; set; } = string.Empty;
        public string NewPassword { get; set; } = string.Empty;
        public string ConfirmPassword { get; set; } = string.Empty;
    }
}