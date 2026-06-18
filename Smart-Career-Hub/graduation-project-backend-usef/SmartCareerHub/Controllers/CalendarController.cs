using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

[ApiController]
[Route("api/calendar")]
[Authorize]
public class CalendarController : ControllerBase
{
    private readonly ICalendarService _calendarService;

    public CalendarController(ICalendarService calendarService)
    {
        _calendarService = calendarService;
    }

    [HttpGet("events")]
    public async Task<IActionResult> GetEvents(
        [FromQuery] int month,
        [FromQuery] int year)
    {
        if (month < 1 || month > 12 || year < 2000)
            return BadRequest("Invalid month or year");

        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var role = User.FindFirstValue(ClaimTypes.Role);

        if (string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(role))
            return Unauthorized();

        var events = await _calendarService
            .GetCalendarEventsAsync(userId, role, month, year);

        return Ok(events);
    }
}