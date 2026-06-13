using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartCareerHub.IService.UserProfileService;
using System.Security.Claims;

namespace SmartCareerHub.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ProfileController : ControllerBase
    {
        private readonly IUserProfileService _profileService;

        public ProfileController(IUserProfileService profileService)
        {
            _profileService = profileService;
        }

        [Authorize(Roles = "Student,Graduate")]
        [HttpGet("summary")]
        public async Task<ActionResult<UserProfileResponse>> GetMyProfile()
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId))
                    return Unauthorized(new { Message = "User not logged in" });

                var profile = await _profileService.GetMyProfileAsync(userId);
                return Ok(profile);
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }

        [Authorize(Roles = "Company")]
        [HttpGet("public/{userId}")]
        public async Task<ActionResult<UserProfileResponse>> GetPublicProfile(string userId)  
        {
            try
            {
                var profile = await _profileService.GetPublicProfileAsync(userId);  // ✅ معدّل
                return Ok(profile);
            }
            catch (Exception ex)
            {
                return NotFound(new { Message = ex.Message });
            }
        }
        [Authorize(Roles = "Student,Graduate")]
        [HttpPut("update")]
        public async Task<IActionResult> UpdateProfile([FromForm] UpdateProfileRequest request)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
                return Unauthorized(new { Message = "User not logged in" });

            var result = await _profileService.UpdateProfileAsync(userId, request);
            return Ok(result);
        }
    }
}