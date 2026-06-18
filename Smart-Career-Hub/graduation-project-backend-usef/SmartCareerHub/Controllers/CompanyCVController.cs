using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Resend;
using System.Security.Claims;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;

[ApiController]
[Route("api/company/cv")]
[Authorize(Roles = "Company")]
public class CompanyCVController : ControllerBase
{
    private readonly ICVService _cvService;

    public CompanyCVController(ICVService cvService)
    {
        _cvService = cvService;
    }

    // ✅ جيب تمبليتس الشركة
    [HttpGet("templates")]
    public async Task<IActionResult> GetMyTemplates()
    {
        var companyId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(companyId))
            return Unauthorized();

        var templates = await _cvService.GetCompanyTemplatesAsync(companyId);
        return Ok(templates);
    }

    // ✅ رفع تمبليت
    [HttpPost("upload-template")]
    public async Task<IActionResult> UploadTemplate([FromForm] UploadTemplateRequest request)
    {
        var companyId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(companyId))
            return Unauthorized();

        var result = await _cvService.UploadTemplateAsync(request, companyId);
        return Ok(result);
    }

    // ✅ مسح تمبليت
    [HttpDelete("templates/{templateId:int}")]
    public async Task<IActionResult> DeleteTemplate(int templateId)
    {
        var companyId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(companyId))
            return Unauthorized();

        await _cvService.DeleteTemplateAsync(templateId, companyId);
        return Ok(new { message = "Template deleted successfully" });
    }
}
