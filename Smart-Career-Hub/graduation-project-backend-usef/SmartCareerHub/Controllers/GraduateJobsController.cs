using Business_Logic.IService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartCareerHub.Contracts.Company.Jobs;
using System.Security.Claims;
using System.Threading.Tasks;

namespace SmartCareerHub.Controllers.Graduate
{
    [ApiController]
    [Route("api/graduate/jobs")]
    [Authorize(Roles = "Student,Graduate")]
    public class GraduateJobsController : ControllerBase
    {
        private readonly IJobApplicationService _jobApplicationService;
        private readonly IInterviewService _interviewService;

        public GraduateJobsController(IJobApplicationService jobApplicationService, IInterviewService interviewService)
        {
            _jobApplicationService = jobApplicationService;
            _interviewService = interviewService;
        }

        // ================== APPLY FOR JOB ==================
        [HttpPost("apply")]
        public async Task<IActionResult> Apply([FromBody] ApplyJobRequest request, CancellationToken cancellationToken)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            var result = await _jobApplicationService.ApplyAsync(userId, request.JobId, cancellationToken);
            if (!result.IsSuccess)
                return BadRequest(result.Error);

            return Ok(result.Value);
        }

        // ================== MY APPLICATIONS ==================
        [HttpGet("applications")]
        public async Task<IActionResult> MyApplications(
      [FromQuery] QueryParameters query,
      CancellationToken cancellationToken)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var result = await _jobApplicationService.GetMyApplicationsAsync(userId, query, cancellationToken);
            if (!result.IsSuccess)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }

        // ================== DASHBOARD STATS ==================
        [HttpGet("applications/stats")]
        public async Task<IActionResult> ApplicationStats(CancellationToken cancellationToken)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            var result = await _jobApplicationService.GetDashboardStatsAsync(userId, cancellationToken);
            if (!result.IsSuccess)
                return BadRequest(result.Error);

            return Ok(result.Value);
        }
        // في GraduateJobsController.cs
        [HttpDelete("applications/{applicationId:int}/withdraw")]
        public async Task<IActionResult> Withdraw(int applicationId, CancellationToken cancellationToken)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var result = await _jobApplicationService.WithdrawAsync(userId, applicationId, cancellationToken);
            if (!result.IsSuccess)
                return BadRequest(result.Error);
            return Ok(new { Message = "Application withdrawn successfully." });
        }

        // ================== MY INTERVIEWS ==================
        [HttpGet("my-interviews")]
        public async Task<IActionResult> GetMyInterviews(
      [FromQuery] QueryParameters query,
      CancellationToken cancellationToken)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var result = await _interviewService.GetUpcomingInterviewsAsync(userId, query, cancellationToken);
            if (!result.IsSuccess)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
    }
}