using Business_Logic.IService;
using DataAccess.Entities.Job;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartCareerHub.Contracts.Company.Jobs;
using System.Security.Claims;

namespace API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class JobsController : ControllerBase
    {
        private readonly IJobService _jobService;
        private readonly IJobApplicationService _jobApplicationService;

        public JobsController(IJobService jobService, IJobApplicationService jobApplicationService)
        {
            _jobService = jobService;
            _jobApplicationService = jobApplicationService;
        }

        private string GetUserId() =>
            User?.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value
            ?? throw new UnauthorizedAccessException("User ID claim not found.");

        // ============================
        // Company Endpoints
        // ============================

        [Authorize(Roles = "Company")]
        [HttpGet]
        public async Task<IActionResult> GetAll([FromQuery] QueryParameters query)
        {
            var jobs = await _jobService.GetAllAsync(query);
            return Ok(jobs);
        }

        [Authorize(Roles = "Company")]
        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetById(int id)
        {
            var job = await _jobService.GetByIdAsync(id);
            if (job == null) return NotFound();
            return Ok(job);
        }

        [Authorize(Roles = "Company")]
        [HttpPost]
        public async Task<IActionResult> Create([FromForm] JobRequest request)
        {
            var userId = GetUserId();
            var job = await _jobService.AddAsync(userId, request);
            return CreatedAtAction(nameof(GetById), new { id = job.Id }, job);
        }

        [Authorize(Roles = "Company")]
        [HttpPut("{id:int}")]
        public async Task<IActionResult> Update(int id, [FromForm] JobRequest request)
        {
            var userId = GetUserId();
            var updated = await _jobService.UpdateAsync(userId, id, request);
            if (!updated) return NotFound();
            var job = await _jobService.GetByIdAsync(id);
            return Ok(job);
        }

        [Authorize(Roles = "Company")]
        [HttpDelete("{id:int}")]
        public async Task<IActionResult> Delete(int id)
        {
            var userId = GetUserId();
            var deleted = await _jobService.DeleteAsync(userId, id);
            if (!deleted) return NotFound();
            return NoContent();
        }

        [Authorize(Roles = "Company")]
        [HttpDelete("bulkdelete")]
        public async Task<IActionResult> BulkDelete([FromBody] List<int> ids)
        {
            if (ids == null || !ids.Any())
                return BadRequest("No job IDs provided");
            var userId = GetUserId();
            var deleted = await _jobService.BulkDeleteAsync(userId, ids);
            if (!deleted) return BadRequest("Failed to delete jobs");
            return NoContent();
        }

        [Authorize(Roles = "Company")]
        [HttpGet("search")]
        public async Task<IActionResult> Search(
            [FromQuery] string keyword,
            [FromQuery] QueryParameters query)
        {
            if (string.IsNullOrWhiteSpace(keyword))
                return BadRequest("Search keyword is required");
            var jobs = await _jobService.SearchJobsAsync(keyword, query);
            return Ok(jobs);
        }

        [Authorize(Roles = "Company")]
        [HttpGet("type/{jobType}")]
        public async Task<IActionResult> GetByType(
            string jobType,
            [FromQuery] QueryParameters query)
        {
            var jobs = await _jobService.GetJobsByTypeAsync(jobType, query);
            return Ok(jobs);
        }

        [Authorize(Roles = "Company")]
        [HttpGet("level/{experienceLevel}")]
        public async Task<IActionResult> GetByExperienceLevel(
            string experienceLevel,
            [FromQuery] QueryParameters query)
        {
            var jobs = await _jobService.GetJobsByExperienceLevelAsync(experienceLevel, query);
            return Ok(jobs);
        }

        [Authorize(Roles = "Company")]
        [HttpGet("location/{location}")]
        public async Task<IActionResult> GetByLocation(
            string location,
            [FromQuery] QueryParameters query)
        {
            var jobs = await _jobService.GetJobsByLocationAsync(location, query);
            return Ok(jobs);
        }

        [Authorize(Roles = "Company")]
        [HttpGet("latest")]
        public async Task<IActionResult> GetLatest(
            [FromQuery] int count = 10,
            [FromQuery] QueryParameters query = null)
        {
            query ??= new QueryParameters { Page = 1, PageSize = count };
            var jobs = await _jobService.GetLatestJobsAsync(count, query);
            return Ok(jobs);
        }

        [Authorize(Roles = "Company")]
        [HttpGet("count")]
        public async Task<IActionResult> GetCount()
        {
            var count = await _jobService.GetTotalJobsCountAsync();
            return Ok(new { count });
        }

        [Authorize(Roles = "Company")]
        [HttpGet("{id:int}/applicants")]
        public async Task<IActionResult> GetApplicants(
            int id,
            [FromQuery] QueryParameters query)
        {
            var applicants = await _jobService.GetApplicantsByJobIdAsync(id, query);
            return Ok(applicants);
        }

        [Authorize(Roles = "Company")]
        [HttpPatch("{jobId:int}/applicants/{applicationId:int}/status")]
        public async Task<IActionResult> UpdateApplicantStatus(
            int jobId,
            int applicationId,
            [FromBody] UpdateApplicationStatusRequest request)
        {
            var result = await _jobApplicationService.UpdateStatusAsync(applicationId, request.Status);
            if (!result.IsSuccess) return BadRequest(result.Error);
            return Ok(new { Message = "Applicant status updated successfully." });
        }

        // ============================
        // Student / Graduate Endpoints
        // ============================

        [Authorize(Roles = "Student,Graduate")]
        [HttpGet("available")]
        public async Task<IActionResult> GetAvailable([FromQuery] QueryParameters query)
        {
            var jobs = await _jobService.GetAllAsync(query);
            return Ok(jobs);
        }

        [Authorize(Roles = "Student,Graduate")]
        [HttpPost("{id:int}/apply")]
        public async Task<IActionResult> Apply(int id)
        {
            var userId = GetUserId();
            var result = await _jobApplicationService.ApplyAsync(userId, id);
            if (result.IsFailure) return BadRequest(result.Error.Description);
            return NoContent();
        }

        [Authorize(Roles = "Student,Graduate")]
        [HttpGet("my-applications")]
        public async Task<IActionResult> GetMyApplications(
     [FromQuery] QueryParameters query,
     CancellationToken cancellationToken)
        {
            var userId = GetUserId();
            var result = await _jobApplicationService.GetMyApplicationsAsync(userId, query, cancellationToken);
            if (result.IsFailure) return BadRequest(result.Error.Description);
            return Ok(result.Value);
        }
    }
}