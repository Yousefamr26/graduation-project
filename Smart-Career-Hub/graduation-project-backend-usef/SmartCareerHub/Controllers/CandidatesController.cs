using Business_Logic.IService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace SmartCareerHub.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CandidatesController : ControllerBase
    {
        private readonly ICandidateService _service;

        public CandidatesController(ICandidateService service)
        {
            _service = service;
        }

        private string GetUserId()
        {
            return User?.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value
                   ?? throw new UnauthorizedAccessException("User ID claim not found.");
        }

        [Authorize(Roles = "Company,TrainingCenter")]
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var result = await _service.GetAllCandidatesAsync();
            if (result.IsFailure) return BadRequest(result.Error.Description);
            return Ok(result.Value);
        }

        [Authorize(Roles = "Company,TrainingCenter")]
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            var result = await _service.GetCandidateByIdAsync(id);
            if (result.IsFailure) return NotFound(result.Error.Description);
            return Ok(result.Value);
        }
    }
}