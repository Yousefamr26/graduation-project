using Business_Logic.IService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace SmartCareerHub.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Company")]
    public class AnalyticsController : ControllerBase
    {
        private readonly IAnalyticsService _analyticsService;

        public AnalyticsController(IAnalyticsService analyticsService)
        {
            _analyticsService = analyticsService;
        }

        [HttpGet("dashboard-overview")]
        public async Task<IActionResult> GetDashboardOverview(CancellationToken cancellationToken)
        {
            var result = await _analyticsService.GetDashboardOverviewAsync(cancellationToken);
            return Ok(result);
        }

        [HttpGet("roadmaps")]
        public async Task<IActionResult> GetRoadmapAnalytics(CancellationToken cancellationToken)
        {
            var result = await _analyticsService.GetRoadmapAnalyticsAsync(cancellationToken);
            return Ok(result);
        }

        [HttpGet("roadmaps/dashboard")]
        public async Task<IActionResult> GetRoadmapDashboard(CancellationToken cancellationToken)
        {
            var result = await _analyticsService.GetRoadmapDashboardAsync(cancellationToken);
            return Ok(result);
        }

        [HttpGet("jobs")]
        public async Task<IActionResult> GetJobAnalytics(CancellationToken cancellationToken)
        {
            var result = await _analyticsService.GetJobAnalyticsAsync(cancellationToken);
            return Ok(result);
        }

        [HttpGet("internships")]
        public async Task<IActionResult> GetInternshipAnalytics(CancellationToken cancellationToken)
        {
            var result = await _analyticsService.GetInternshipAnalyticsAsync(cancellationToken);
            return Ok(result);
        }

        [HttpGet("workshops")]
        public async Task<IActionResult> GetWorkshopAnalytics(CancellationToken cancellationToken)
        {
            var result = await _analyticsService.GetWorkshopAnalyticsAsync(cancellationToken);
            return Ok(result);
        }

        [HttpGet("events")]
        public async Task<IActionResult> GetEventAnalytics(CancellationToken cancellationToken)
        {
            var result = await _analyticsService.GetEventAnalyticsAsync(cancellationToken);
            return Ok(result);
        }

        [HttpGet("interviews")]
        public async Task<IActionResult> GetInterviewAnalytics(CancellationToken cancellationToken)
        {
            var result = await _analyticsService.GetInterviewAnalyticsAsync(cancellationToken);
            return Ok(result);
        }

        [HttpGet("interviews/overtime")]
        public async Task<IActionResult> GetInterviewOverTime(
            [FromQuery] string period = "monthly",
            [FromQuery] int? year = null,
            CancellationToken cancellationToken = default)
        {
            var result = await _analyticsService.GetInterviewCompletionRateOverTimeAsync(
                period, year ?? DateTime.Now.Year, cancellationToken);
            return Ok(result);
        }

        [HttpGet("universities")]
        public async Task<IActionResult> GetUniversityAnalytics(CancellationToken cancellationToken)
        {
            var result = await _analyticsService.GetUniversityAnalyticsAsync(cancellationToken);
            return Ok(result);
        }
    }
}