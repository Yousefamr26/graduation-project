using Business_Logic.Errors;
using Business_Logic.IService;
using DataAccess.Abstractions;
using Microsoft.AspNetCore.Mvc;
using SmartCareerHub.Contracts.Auth;

namespace SmartCareerHub.Controllers.Auth
{
    [ApiController]
    [Route("api/[controller]")]
    public class UniversityAuthController : ControllerBase
    {
        private readonly IUniversityAuthService _authService;

        public UniversityAuthController(IUniversityAuthService authService)
        {
            _authService = authService;
        }

        // ==============================
        // POST /api/universityauth/register
        // ==============================
        [HttpPost("register")]
        public async Task<IActionResult> RegisterUniversity([FromForm] UniversityRegisterRequest request)
        {
            try
            {
                var result = await _authService.RegisterUniversityAsync(request);
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
                return StatusCode(500, new Error("Auth.Exception", "An unexpected error occurred. " + ex.Message));
            }
        }

        // ==============================
        // POST /api/universityauth/verify-email
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
        // POST /api/universityauth/resend-otp
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
        // POST /api/universityauth/login
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