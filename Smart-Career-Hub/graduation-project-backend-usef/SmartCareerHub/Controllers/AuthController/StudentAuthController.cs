using Business_Logic.IService;
using Microsoft.AspNetCore.Mvc;
using SmartCareerHub.Contracts.Auth;

namespace SmartCareerHub.Controllers.Auth
{
    [ApiController]
    [Route("api/[controller]")]
    public class StudentAuthController : ControllerBase
    {
        private readonly IStudentAuthService _authService;

        public StudentAuthController(IStudentAuthService authService)
        {
            _authService = authService;
        }

        // ==============================
        // POST /api/studentauth/register
        // ==============================
        [HttpPost("register")]
        public async Task<IActionResult> RegisterStudent([FromForm] RegisterStudentRequest request)
        {
            try
            {
                var result = await _authService.RegisterStudentAsync(request);
                if (!result.IsSuccess)
                    return BadRequest(result.Error);

                return Ok(new
                {
                    success = true,
                    message = "Registration successful. Please check your email to verify your account.",
                    data = result.Value
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "An unexpected error occurred. " + ex.Message });
            }
        }

        // ==============================
        // POST /api/studentauth/verify-email
        // ==============================
        [HttpPost("verify-email")]
        public async Task<IActionResult> VerifyEmail([FromBody] VerifyEmailRequest request)
        {
            var result = await _authService.VerifyEmailAsync(request.Email, request.Otp);
            if (!result.IsSuccess)
                return BadRequest(new { success = false, message = result.Error.Description });

            return Ok(new { success = true, message = result.Value });
        }

        // ==============================
        // POST /api/studentauth/resend-otp
        // ==============================
        [HttpPost("resend-otp")]
        public async Task<IActionResult> ResendOtp([FromBody] ResendOtpRequest request)
        {
            var result = await _authService.ResendEmailOtpAsync(request.Email);
            if (!result.IsSuccess)
                return BadRequest(new { success = false, message = result.Error.Description });

            return Ok(new { success = true, message = result.Value });
        }

        // ==============================
        // POST /api/studentauth/login
        // ==============================
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            try
            {
                var result = await _authService.LoginAsync(request);
                if (!result.IsSuccess)
                    return BadRequest(new { success = false, message = result.Error.Description });

                return Ok(new
                {
                    success = true,
                    message = "Login successful",
                    data = result.Value
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "An unexpected error occurred. " + ex.Message });
            }
        }
    }
}