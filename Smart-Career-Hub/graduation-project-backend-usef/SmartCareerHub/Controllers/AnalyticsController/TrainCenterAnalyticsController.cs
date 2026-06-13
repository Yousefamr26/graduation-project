using Business_Logic.IService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace SmartCareerHub.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "TrainingCenter")]
public class TrainCenterAnalyticsController : ControllerBase
{
    private readonly ITrainCenterAnalyticsService _analyticsService;

    public TrainCenterAnalyticsController(ITrainCenterAnalyticsService analyticsService)
    {
        _analyticsService = analyticsService;
    }

    // GET api/traincenteranalytics
    // Returns full dashboard data in one call
    [HttpGet]
    public async Task<IActionResult> GetFullAnalytics()
    {
        var trainingCenterId = GetTrainingCenterId();
        var result = await _analyticsService.GetFullAnalyticsAsync(trainingCenterId);
        return Ok(result);
    }

    // GET api/traincenteranalytics/summary
    [HttpGet("summary")]
    public async Task<IActionResult> GetSummary()
    {
        var trainingCenterId = GetTrainingCenterId();
        var result = await _analyticsService.GetSummaryAsync(trainingCenterId);
        return Ok(result);
    }

    // GET api/traincenteranalytics/attendance?months=6
    [HttpGet("attendance")]
    public async Task<IActionResult> GetAttendanceOverTime([FromQuery] int months = 6)
    {
        if (months <= 0 || months > 24)
            return BadRequest("months must be between 1 and 24.");

        var trainingCenterId = GetTrainingCenterId();
        var result = await _analyticsService.GetAttendanceOverTimeAsync(trainingCenterId, months);
        return Ok(result);
    }

    // GET api/traincenteranalytics/courses
    [HttpGet("courses")]
    public async Task<IActionResult> GetCourseCompletionRates()
    {
        var trainingCenterId = GetTrainingCenterId();
        var result = await _analyticsService.GetCourseCompletionRatesAsync(trainingCenterId);
        return Ok(result);
    }

    // GET api/traincenteranalytics/performance
    [HttpGet("performance")]
    public async Task<IActionResult> GetPerformanceDistribution()
    {
        var trainingCenterId = GetTrainingCenterId();
        var result = await _analyticsService.GetPerformanceDistributionAsync(trainingCenterId);
        return Ok(result);
    }

    // GET api/traincenteranalytics/enrollment?months=6
    [HttpGet("enrollment")]
    public async Task<IActionResult> GetMonthlyEnrollmentVsCompletion([FromQuery] int months = 6)
    {
        if (months <= 0 || months > 24)
            return BadRequest("months must be between 1 and 24.");

        var trainingCenterId = GetTrainingCenterId();
        var result = await _analyticsService.GetMonthlyEnrollmentVsCompletionAsync(trainingCenterId, months);
        return Ok(result);
    }

    // ── Helper ────────────────────────────────────────────────────────────────

    private int GetTrainingCenterId()
    {
        var claim = User?.Claims.FirstOrDefault(c => c.Type == "TrainingCenterId")?.Value
            ?? throw new UnauthorizedAccessException("TrainingCenterId claim not found.");

        if (!int.TryParse(claim, out var id))
            throw new UnauthorizedAccessException("Invalid TrainingCenterId claim.");

        return id;
    }
}