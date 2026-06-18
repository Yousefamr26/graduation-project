using Business_Logic.IService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartCareerHub.Contracts.Company.Event;
using System.Security.Claims;

namespace SmartCareerHub.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EventsController : ControllerBase
    {
        private readonly IEventService _eventService;

        public EventsController(IEventService eventService)
        {
            _eventService = eventService;
        }

        // ================== CREATE EVENT ==================
        [Authorize(Roles = "Company,University")]
        [HttpPost]
        public async Task<IActionResult> Create([FromForm] EventRequest request, CancellationToken cancellationToken)
        {
            var creatorId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(creatorId))
                return Unauthorized("Invalid user");

            // تحقق إذا العنوان موجود مسبقاً
            if (await _eventService.IsTitleExistsAsync(request.Title))
                return Conflict(new { error = "Event title already exists." });

            try
            {
                var evt = await _eventService.AddAsync(request, creatorId, cancellationToken);
                return CreatedAtAction(nameof(GetById), new { id = evt.Id }, evt);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        // ================== GET EVENT BY ID ==================
        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetById(int id, CancellationToken cancellationToken)
        {
            var evt = await _eventService.GetByIdAsync(id, cancellationToken);
            if (evt == null) return NotFound();
            return Ok(evt);
        }

        // ================== GET ALL EVENTS ==================
        [HttpGet]
        public async Task<IActionResult> GetAll(
      [FromQuery] QueryParameters query,
      CancellationToken cancellationToken)
        {
            var events = await _eventService.GetAllAsync(query, cancellationToken);
            return Ok(events);
        }

        // ================== UPDATE EVENT ==================
        [Authorize(Roles = "Company,University")]
        [HttpPut("{id:int}")]
        public async Task<IActionResult> Update(int id, [FromForm] EventRequest request, CancellationToken cancellationToken)
        {
            var success = await _eventService.UpdateAsync(id, request, cancellationToken);
            if (!success) return NotFound();
            return Ok("Event updated successfully");
        }

        // ================== DELETE EVENT ==================
        [Authorize(Roles = "Company,University")]
        [HttpDelete("{id:int}")]
        public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
        {
            var success = await _eventService.DeleteAsync(id, cancellationToken);
            if (!success) return NotFound();
            return Ok("Event deleted successfully");
        }

        // ================== TOGGLE STATUS ==================
        [Authorize(Roles = "Company,University")]
        [HttpPatch("toggle/{id:int}")]
        public async Task<IActionResult> ToggleStatus(int id, CancellationToken cancellationToken)
        {
            var success = await _eventService.ToggleStatusAsync(id, cancellationToken);
            if (!success) return NotFound();
            return Ok("Event status toggled successfully");
        }

        // ================== BULK STATUS UPDATE ==================
        [Authorize(Roles = "Company,University")]
        [HttpPatch("bulkstatus")]
        public async Task<IActionResult> BulkStatus([FromQuery] bool isPublished, [FromBody] List<int> ids, CancellationToken cancellationToken)
        {
            if (ids == null || !ids.Any()) return BadRequest("No event IDs provided");

            await _eventService.BulkUpdateStatusAsync(ids, isPublished, cancellationToken);
            return Ok("Bulk status updated");
        }

        // ================== BULK DELETE ==================
        [Authorize(Roles = "Company,University")]
        [HttpDelete("bulkdelete")]
        public async Task<IActionResult> BulkDelete([FromBody] List<int> ids, CancellationToken cancellationToken)
        {
            if (ids == null || !ids.Any()) return BadRequest("No event IDs provided");

            await _eventService.BulkDeleteAsync(ids, cancellationToken);
            return Ok("Bulk delete completed");
        }
    }
}