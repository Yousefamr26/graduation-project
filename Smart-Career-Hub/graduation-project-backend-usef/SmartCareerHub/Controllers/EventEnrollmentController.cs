using Business_Logic.IService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartCareerHub.Contracts.Events.Enrollment;
using System.Security.Claims;

namespace SmartCareerHub.Controllers
{
    [ApiController]
    [Route("api/events")]
    public class EventEnrollmentController : ControllerBase
    {
        private readonly IEventEnrollmentService _eventEnrollmentService;

        public EventEnrollmentController(IEventEnrollmentService eventEnrollmentService)
        {
            _eventEnrollmentService = eventEnrollmentService;
        }

        [Authorize]
        [HttpPost("{eventId}/enroll")]
        public async Task<IActionResult> Enroll(
            int eventId,
            [FromBody] EventEnrollmentRequest request,
            CancellationToken cancellationToken)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (userId == null) return Unauthorized();
            if (eventId != request.EventId) return BadRequest("EventId mismatch");

            try
            {
                var result = await _eventEnrollmentService.EnrollAsync(userId, request, cancellationToken);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [Authorize]
        [HttpDelete("{eventId}/enroll")]
        public async Task<IActionResult> CancelEnrollment(
            int eventId,
            CancellationToken cancellationToken)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (userId == null) return Unauthorized();

            var result = await _eventEnrollmentService.CancelEnrollmentAsync(userId, eventId, cancellationToken);
            if (!result) return NotFound("Enrollment not found");
            return Ok(new { message = "Enrollment cancelled successfully" });
        }

        [Authorize]
        [HttpGet("my-events")]
        public async Task<IActionResult> GetMyEvents(
            [FromQuery] QueryParameters query,
            CancellationToken cancellationToken)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (userId == null) return Unauthorized();

            var result = await _eventEnrollmentService.GetMyEventsAsync(userId, query, cancellationToken);
            return Ok(result);
        }

        [Authorize(Roles = "Company")]
        [HttpGet("{eventId}/participants")]
        public async Task<IActionResult> GetParticipants(
            int eventId,
            [FromQuery] QueryParameters query,
            CancellationToken cancellationToken)
        {
            var result = await _eventEnrollmentService.GetParticipantsAsync(eventId, query, cancellationToken);
            return Ok(result);
        }
    }
}