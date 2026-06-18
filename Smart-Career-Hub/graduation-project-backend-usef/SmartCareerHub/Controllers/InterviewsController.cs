using Business_Logic.IService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace SmartCareerHub.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class InterviewsController : ControllerBase
    {
        private readonly IInterviewService _service;

        public InterviewsController(IInterviewService service)
        {
            _service = service;
        }

        #region Helper
        private string GetUserId() =>
            User?.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value
            ?? throw new UnauthorizedAccessException("User ID claim not found.");
        #endregion

        // ============================
        // Company Endpoints
        // ============================

        [Authorize(Roles = "Company")]
        [HttpGet]
        public async Task<IActionResult> GetAll([FromQuery] QueryParameters query) =>
            Ok(await _service.GetAllAsync(query));

        [Authorize(Roles = "Company")]
        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetById(int id)
        {
            var interview = await _service.GetByIdAsync(id);
            if (interview == null) return NotFound();
            return Ok(interview);
        }

        [Authorize(Roles = "Company")]
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] InterviewRequest request)
        {
            try
            {
                var userId = GetUserId();
                var result = await _service.AddAsync(request, userId);
                return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
            }
            catch (Exception ex)
            {
                var msg = ex.InnerException?.Message ?? ex.Message;
                return StatusCode(500, new { message = msg });
            }
        }
        [Authorize(Roles = "Company")]
        [HttpPut("{id:int}")]
        public async Task<IActionResult> Update(int id, [FromBody] InterviewRequest request)
        {
            var updated = await _service.UpdateAsync(id, request);
            if (!updated) return NotFound();
            return NoContent();
        }

        [Authorize(Roles = "Company")]
        [HttpDelete("{id:int}")]
        public async Task<IActionResult> Delete(int id)
        {
            var deleted = await _service.DeleteAsync(id);
            if (!deleted) return NotFound();
            return NoContent();
        }

        [Authorize(Roles = "Company")]
        [HttpPatch("{id:int}/status")]
        public async Task<IActionResult> UpdateStatus(int id, [FromQuery] string status)
        {
            if (!Enum.TryParse<InterviewStatus>(status, true, out var statusEnum))
                return BadRequest("Invalid status value");
            var updated = await _service.UpdateStatusAsync(id, statusEnum);
            if (!updated) return NotFound();
            return NoContent();
        }

        [Authorize(Roles = "Company")]
        [HttpPatch("bulkstatus")]
        public async Task<IActionResult> BulkUpdateStatus(
            [FromQuery] string status,
            [FromBody] List<int> ids)
        {
            if (ids == null || !ids.Any()) return BadRequest("No interview IDs provided");
            if (!Enum.TryParse<InterviewStatus>(status, true, out var statusEnum))
                return BadRequest("Invalid status value");
            var updated = await _service.BulkUpdateStatusAsync(ids, statusEnum);
            if (!updated) return NotFound();
            return NoContent();
        }

        [Authorize(Roles = "Company")]
        [HttpGet("today")]
        public async Task<IActionResult> GetToday([FromQuery] QueryParameters query) =>
            Ok(await _service.GetTodayInterviewsAsync(query));

        [Authorize(Roles = "Company")]
        [HttpGet("ai-recommended")]
        public async Task<IActionResult> GetAIRecommended([FromQuery] QueryParameters query) =>
            Ok(await _service.GetAIRecommendedAsync(query));

        [Authorize(Roles = "Company")]
        [HttpGet("roadmap/{roadmapId:int}")]
        public async Task<IActionResult> GetByRoadmap(
            int roadmapId,
            [FromQuery] QueryParameters query) =>
            Ok(await _service.GetByRoadmapAsync(roadmapId, query));

        [Authorize(Roles = "Company")]
        [HttpGet("search")]
        public async Task<IActionResult> Search(
            [FromQuery] string keyword,
            [FromQuery] QueryParameters query)
        {
            if (string.IsNullOrWhiteSpace(keyword))
                return BadRequest("Search keyword is required");
            return Ok(await _service.SearchInterviewsAsync(keyword, query));
        }

        [Authorize(Roles = "Company")]
        [HttpGet("count")]
        public async Task<IActionResult> GetTotalCount() =>
            Ok(await _service.GetTotalCountAsync());

        [Authorize(Roles = "Company")]
        [HttpGet("count/today")]
        public async Task<IActionResult> GetTodayCount() =>
            Ok(await _service.GetTodayCountAsync());

        [Authorize(Roles = "Company")]
        [HttpGet("latest")]
        public async Task<IActionResult> GetLatest(
            [FromQuery] int count = 10,
            [FromQuery] QueryParameters query = null)
        {
            query ??= new QueryParameters { Page = 1, PageSize = count };
            return Ok(await _service.GetLatestInterviewsAsync(count, query));
        }

        [Authorize(Roles = "Company")]
        [HttpDelete("bulkdelete")]
        public async Task<IActionResult> BulkDelete([FromBody] List<int> ids)
        {
            if (ids == null || !ids.Any()) return BadRequest("No interview IDs provided");
            var deleted = await _service.BulkDeleteAsync(ids);
            if (!deleted) return NotFound();
            return NoContent();
        }

        // ============================
        // Student / Graduate Endpoints
        // ============================

        [Authorize(Roles = "Student,Graduate")]
        [HttpGet("me/upcoming")]
        public async Task<IActionResult> GetMyUpcomingInterviews([FromQuery] QueryParameters query)
        {
            var userId = GetUserId();
            var result = await _service.GetUpcomingInterviewsAsync(userId, query);
            if (result.IsFailure) return BadRequest(result.Error.Description);
            return Ok(result.Value);
        }

        [Authorize(Roles = "Student,Graduate")]
        [HttpGet("me/past")]
        public async Task<IActionResult> GetMyPastInterviews([FromQuery] QueryParameters query)
        {
            var userId = GetUserId();
            var result = await _service.GetPastInterviewsAsync(userId, query);
            if (result.IsFailure) return BadRequest(result.Error.Description);
            return Ok(result.Value);
        }

        [Authorize(Roles = "Student,Graduate")]
        [HttpGet("me/{id:int}")]
        public async Task<IActionResult> GetMyInterviewById(int id)
        {
            var userId = GetUserId();
            var result = await _service.GetInterviewByIdForUserAsync(id, userId);
            if (result.IsFailure || result.Value == null) return NotFound();
            return Ok(result.Value);
        }

        [Authorize(Roles = "Student,Graduate")]
        [HttpPatch("me/{id:int}/accept")]
        public async Task<IActionResult> AcceptInterview(int id)
        {
            var userId = GetUserId();
            var result = await _service.AcceptInterviewAsync(id, userId);
            if (result.IsFailure) return BadRequest(result.Error.Description);
            return NoContent();
        }

        [Authorize(Roles = "Student,Graduate")]
        [HttpPatch("me/{id:int}/decline")]
        public async Task<IActionResult> DeclineInterview(int id)
        {
            var userId = GetUserId();
            var result = await _service.DeclineInterviewAsync(id, userId);
            if (result.IsFailure) return BadRequest(result.Error.Description);
            return NoContent();
        }
    }
}