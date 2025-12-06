using Business_Logic.IService;
using Microsoft.AspNetCore.Mvc;
using SmartCareerHub.Contracts.Company.Interview;

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

      
        [HttpGet]
        public async Task<IActionResult> GetAll() =>
            Ok(await _service.GetAllAsync());

        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetById(int id)
        {
            var interview = await _service.GetByIdAsync(id);
            if (interview == null) return NotFound();
            return Ok(interview);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] InterviewRequest request)
        {
            var result = await _service.AddAsync(request);
            return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
        }

        [HttpPut("{id:int}")]
        public async Task<IActionResult> Update(int id, [FromBody] InterviewRequest request)
        {
            var updated = await _service.UpdateAsync(id, request);
            if (!updated) return NotFound();
            return NoContent();
        }

        [HttpDelete("{id:int}")]
        public async Task<IActionResult> Delete(int id)
        {
            var deleted = await _service.DeleteAsync(id);
            if (!deleted) return NotFound();
            return NoContent();
        }

       
        [HttpGet("today")]
        public async Task<IActionResult> GetToday() =>
            Ok(await _service.GetTodayInterviewsAsync());

        [HttpGet("ai-recommended")]
        public async Task<IActionResult> GetAIRecommended() =>
            Ok(await _service.GetAIRecommendedAsync());

        [HttpGet("roadmap/{roadmapId:int}")]
        public async Task<IActionResult> GetByRoadmap(int roadmapId) =>
            Ok(await _service.GetByRoadmapAsync(roadmapId));

        [HttpGet("search")]
        public async Task<IActionResult> Search([FromQuery] string keyword)
        {
            if (string.IsNullOrWhiteSpace(keyword)) return BadRequest("Search keyword is required");
            return Ok(await _service.SearchInterviewsAsync(keyword));
        }

       
        [HttpPatch("{id:int}/status")]
        public async Task<IActionResult> UpdateStatus(int id, [FromQuery] string status)
        {
            var updated = await _service.UpdateStatusAsync(id, status);
            if (!updated) return NotFound();
            return NoContent();
        }

        [HttpPatch("bulkstatus")]
        public async Task<IActionResult> BulkUpdateStatus([FromQuery] string status, [FromBody] List<int> ids)
        {
            if (ids == null || !ids.Any()) return BadRequest("No interview IDs provided");
            var updated = await _service.BulkUpdateStatusAsync(ids, status);
            if (!updated) return NotFound();
            return NoContent();
        }

        
        [HttpGet("count")]
        public async Task<IActionResult> GetTotalCount() =>
            Ok(await _service.GetTotalCountAsync());

        [HttpGet("count/today")]
        public async Task<IActionResult> GetTodayCount() =>
            Ok(await _service.GetTodayCountAsync());

        [HttpGet("latest")]
        public async Task<IActionResult> GetLatest([FromQuery] int count = 10) =>
            Ok(await _service.GetLatestInterviewsAsync(count));

       
        [HttpDelete("bulkdelete")]
        public async Task<IActionResult> BulkDelete([FromBody] List<int> ids)
        {
            if (ids == null || !ids.Any()) return BadRequest("No interview IDs provided");
            var deleted = await _service.BulkDeleteAsync(ids);
            if (!deleted) return NotFound();
            return NoContent();
        }
    }
}
