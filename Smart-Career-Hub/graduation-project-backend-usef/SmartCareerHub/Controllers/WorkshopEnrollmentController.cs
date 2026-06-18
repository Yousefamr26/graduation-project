using Business_Logic.IService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartCareerHub.Contracts.Workshops.Enrollment;
using System.Security.Claims;

namespace SmartCareerHub.Controllers
{
    [Authorize(Roles = "Student,Graduate")]
    [ApiController]
    [Route("api/[controller]")]
    public class WorkshopEnrollmentController : ControllerBase
    {
        private readonly IWorkshopEnrollmentService _enrollmentService;

        public WorkshopEnrollmentController(IWorkshopEnrollmentService enrollmentService)
        {
            _enrollmentService = enrollmentService;
        }

        private string? GetUserId() =>
            User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        [HttpPost("enroll")]
        public async Task<IActionResult> Enroll([FromBody] EnrollWorkshopRequest request)
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            try
            {
                var result = await _enrollmentService.EnrollAsync(userId, request);
                if (result.IsFailure) return BadRequest(result.Error);
                return Ok(result.Value);
            }
            catch (Exception ex)
            {
                var msg = ex.InnerException?.Message ?? ex.Message;
                return StatusCode(500, new { message = msg });
            }
        }

        [HttpGet("my-workshops")]
        public async Task<IActionResult> GetMyWorkshops([FromQuery] QueryParameters query)
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            var result = await _enrollmentService.GetMyEnrollmentsAsync(userId, query);
            if (result.IsFailure) return BadRequest(result.Error);
            return Ok(result.Value);
        }

        [HttpGet("available")]
        public async Task<IActionResult> GetAvailableWorkshops([FromQuery] QueryParameters query)
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            var result = await _enrollmentService.GetAvailableWorkshopsAsync(userId, query);
            if (result.IsFailure) return BadRequest(result.Error);
            return Ok(result.Value);
        }

        [HttpGet("{workshopId}/participants")]
        public async Task<IActionResult> GetWorkshopParticipants(
            int workshopId,
            [FromQuery] QueryParameters query)
        {
            var result = await _enrollmentService.GetWorkshopParticipantsAsync(workshopId, query);
            if (result.IsFailure) return BadRequest(result.Error);
            return Ok(result.Value);
        }

        [HttpDelete("{workshopId}")]
        public async Task<IActionResult> CancelEnrollment(int workshopId)
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            var result = await _enrollmentService.CancelEnrollmentAsync(workshopId, userId);
            if (result.IsFailure) return BadRequest(result.Error);
            return Ok(new { message = "Enrollment cancelled successfully" });
        }

        [HttpGet("{workshopId}/details")]
        public async Task<IActionResult> GetWorkshopDetails(int workshopId)
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            var result = await _enrollmentService.GetWorkshopDetailsAsync(workshopId, userId);
            if (result.IsFailure) return BadRequest(result.Error);
            return Ok(result.Value);
        }
    }
}