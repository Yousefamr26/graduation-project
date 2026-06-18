using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/[controller]")]
[Authorize] // ← عام بس
public class PartnershipsController : ControllerBase
{
    private readonly IPartnershipService _partnershipService;

    public PartnershipsController(IPartnershipService partnershipService)
    {
        _partnershipService = partnershipService;
    }

    [HttpGet]
    [AllowAnonymous]
    public async Task<IActionResult> GetAll()
    {
        try
        {
            var result = await _partnershipService.GetAllAsync();
            if (!result.IsSuccess) return BadRequest(result.Error);
            return Ok(result.Value);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.InnerException?.Message ?? ex.Message });
        }
    }

    [HttpGet("{id}")]
    [AllowAnonymous]
    public async Task<IActionResult> GetById(int id)
    {
        try
        {
            var result = await _partnershipService.GetByIdAsync(id);
            if (!result.IsSuccess) return NotFound(result.Error);
            return Ok(result.Value);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.InnerException?.Message ?? ex.Message });
        }
    }

    [HttpPost]
    [Authorize(Roles = "University")]
    public async Task<IActionResult> Create([FromBody] CreatePartnershipRequest request)
    {
        try
        {
            var universityId = User.FindFirst("UniversityId")?.Value;
            if (string.IsNullOrEmpty(universityId))
                return Unauthorized(new { message = "University ID not found in token." });

            request = request with { UniversityId = int.Parse(universityId) };

            var result = await _partnershipService.CreateAsync(request);
            if (!result.IsSuccess) return BadRequest(result.Error);
            return CreatedAtAction(nameof(GetById), new { id = result.Value.Id }, result.Value);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.InnerException?.Message ?? ex.Message });
        }
    }

    [HttpPut("{id}")]
    [Authorize(Roles = "University")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdatePartnershipRequest request)
    {
        try
        {
            if (request == null || request.Id != id)
                return BadRequest("Request Id does not match route Id.");

            var result = await _partnershipService.UpdateAsync(request);
            if (!result.IsSuccess) return BadRequest(result.Error);
            return Ok(result.Value);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.InnerException?.Message ?? ex.Message });
        }
    }

    [HttpPatch("{id}/approve")]
    [Authorize(Roles = "Company")]
    public async Task<IActionResult> Approve(int id)
    {
        try
        {
            var result = await _partnershipService.ApproveAsync(id);
            if (!result.IsSuccess) return BadRequest(result.Error);
            return Ok(new { message = "Partnership approved successfully." });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.InnerException?.Message ?? ex.Message });
        }
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "University")]
    public async Task<IActionResult> Delete(int id)
    {
        try
        {
            var result = await _partnershipService.DeleteAsync(id);
            if (!result.IsSuccess) return NotFound(result.Error);
            return NoContent();
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.InnerException?.Message ?? ex.Message });
        }
    }
}