using Business_Logic.IService;
using DataAccess.Entities.Job;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace SmartCareerHub.Api.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/internships")]
    public class InternshipController : ControllerBase
    {
        private readonly IInternshipService _internshipService;

        public InternshipController(IInternshipService internshipService)
        {
            _internshipService = internshipService;
        }

        // ================== Create ==================
        [HttpPost]
        [Authorize(Roles = "Company")]
        public async Task<IActionResult> CreateInternship([FromBody] CreateInternshipRequest request)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
                return Unauthorized("User ID not found in token");

            var internship = new Internship
            {
                Title = request.Title,
                Type = request.Type,
                IsPaid = request.IsPaid,
                MaxTrainees = request.MaxTrainees,
                DurationInMonths = request.DurationInMonths,
                ApplicationDeadline = request.ApplicationDeadline,
                Location = request.Location,
                Description = request.Description,
                RequiredSkills = request.RequiredSkills?
                    .Select(skill => new InternshipRequiredSkill { Skill = skill })
                    .ToList(),
                Requirements = request.Requirements?
                    .Select(req => new InternshipRequirement { Requirement = req })
                    .ToList()
            };

            var result = await _internshipService.CreateInternshipAsync(internship, userId);
            return CreatedAtAction(nameof(GetInternshipById), new { id = result.Id }, result);
        }

        // ================== Get All ==================
        [HttpGet]
        [AllowAnonymous]
        public async Task<IActionResult> GetAll([FromQuery] QueryParameters query)
        {
            var internships = await _internshipService.GetAllInternshipsAsync(query);
            return Ok(internships);
        }

        // ================== Get By Id ==================
        [HttpGet("{id:int}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetInternshipById(int id)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var internship = await _internshipService.GetInternshipByIdAsync(id, userId);
            if (internship == null)
                return NotFound(new { Message = "Internship not found" });

            return Ok(internship);
        }

        // ================== Update ==================
        [HttpPut("{id:int}")]
        [Authorize(Roles = "Company")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateInternshipRequest request)
        {
            var internship = new Internship
            {
                Id = id,
                Title = request.Title,
                Description = request.Description,
                Type = request.Type,
                Status = request.Status,
                IsPaid = request.IsPaid,
                MaxTrainees = request.MaxTrainees,
                DurationInMonths = request.DurationInMonths,
                Location = request.Location,
                ApplicationDeadline = request.ApplicationDeadline
            };

            var updated = await _internshipService.UpdateInternshipAsync(internship);
            if (updated == null)
                return NotFound(new { Message = "Internship not found" });

            return Ok(updated);
        }

        // ================== Delete ==================
        [HttpDelete("{id:int}")]
        [Authorize(Roles = "Company")]
        public async Task<IActionResult> Delete(int id)
        {
            await _internshipService.DeleteInternshipAsync(id);
            return Ok(new { Message = "Deleted successfully" });
        }

        // ================== Apply ==================
        [HttpPost("{id:int}/apply")]
        [Authorize(Roles = "Student,Graduate")]
        public async Task<IActionResult> Apply(int id)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
                return Unauthorized(new { Message = "User not logged in" });

            try
            {
                await _internshipService.ApplyAsync(id, userId);
                return Ok(new { Message = "Applied successfully" });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = ex.Message });
            }
        }
        // ================== Check if Applied ==================
        [HttpGet("{id:int}/applied")]
        [Authorize(Roles = "Student,Graduate")]
        public async Task<IActionResult> HasApplied(int id)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
                return Unauthorized(new { Message = "User not logged in" });

            var applied = await _internshipService.HasUserAppliedAsync(id, userId);
            return Ok(new { Applied = applied });
        }

        // ================== Get Applicants ==================
        [HttpGet("{id:int}/applicants")]
        [Authorize(Roles = "Company")]
        public async Task<IActionResult> GetApplicants(int id, [FromQuery] QueryParameters query)
        {
            var applicants = await _internshipService.GetApplicantsByInternshipIdAsync(id, query);
            return Ok(applicants);
        }

        // ================== Search & Filter ==================
        [HttpGet("search")]
        [AllowAnonymous]
        public async Task<IActionResult> Search(
            [FromQuery] string? keyword,
            [FromQuery] string? type,
            [FromQuery] string? status,
            [FromQuery] QueryParameters query)
        {
            var internships = await _internshipService.SearchAsync(keyword, type, status, query);
            return Ok(internships);
        }

        // ================== Update Applicant Status ==================
        [HttpPatch("{internshipId:int}/applicants/{applicationId}/status")]
        [Authorize(Roles = "Company")]
        public async Task<IActionResult> UpdateApplicantStatus(
            int internshipId,
            string applicationId,
            [FromBody] UpdateInternshipApplicationStatusRequest request)
        {
            var result = await _internshipService.UpdateApplicantStatusAsync(applicationId, request.Status);
            if (!result)
                return NotFound(new { Message = "Application not found." });

            return Ok(new { Message = "Status updated successfully." });
        }

        // ================== My Applications ==================
        [HttpGet("my-applications")]
        [Authorize(Roles = "Student,Graduate")]
        public async Task<IActionResult> MyApplications([FromQuery] QueryParameters query)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
                return Unauthorized(new { Message = "User not logged in" });

            var applications = await _internshipService.GetMyApplicationsAsync(userId, query);
            return Ok(applications);
        }

        // ================== Withdraw ==================
        [HttpDelete("applications/{applicationId:int}/withdraw")]
        [Authorize(Roles = "Student,Graduate")]
        public async Task<IActionResult> Withdraw(int applicationId)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
                return Unauthorized(new { Message = "User not logged in" });

            var result = await _internshipService.WithdrawAsync(userId, applicationId);
            if (!result)
                return BadRequest(new { Message = "Cannot withdraw this application." });

            return Ok(new { Message = "Application withdrawn successfully." });
        }
    }
}