using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

[ApiController]
[Route("api/student/cv")]
[Authorize(Roles = "Student,Graduate")]
public class CVController : ControllerBase
{
    private readonly ICVService _cvService;

    public CVController(ICVService cvService)
    {
        _cvService = cvService;
    }

    // ✅ جيب كل CVs بتاعت الطالب
    [HttpGet]
    public async Task<IActionResult> GetMyCVs()
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(userId))
            return Unauthorized();

        var cvs = await _cvService.GetUserCVsAsync(userId);
        return Ok(cvs);
    }

    // ✅ رفع CV
    [HttpPost("upload")]
    public async Task<IActionResult> UploadCV([FromForm] UploadCVRequest request)
    {
        var studentId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(studentId))
            return Unauthorized();

        var result = await _cvService.UploadAsync(request, studentId);
        return Ok(result);
    }

    // ✅ تحميل CV بتاعه
    [HttpGet("download/{cvId:int}")]
    public async Task<IActionResult> DownloadCV(int cvId)
    {
        var result = await _cvService.DownloadAsync(cvId);
        return File(result.file, result.contentType, result.fileName);
    }

    // ✅ مسح CV
    [HttpDelete("{cvId:int}")]
    public async Task<IActionResult> DeleteCV(int cvId)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(userId))
            return Unauthorized();

        await _cvService.DeleteCVAsync(cvId, userId);
        return Ok(new { message = "CV deleted successfully" });
    }

    // ✅ جيب كل التمبليتس
    [HttpGet("templates")]
    public async Task<IActionResult> GetTemplates()
    {
        var templates = await _cvService.GetAllTemplatesAsync();
        return Ok(templates);
    }

    // ✅ تحميل تمبليت
    [HttpGet("download-template/{templateId:int}")]
    public async Task<IActionResult> DownloadTemplate(int templateId)
    {
        var result = await _cvService.DownloadTemplateAsync(templateId);
        return File(result.file, result.contentType, result.fileName);
    }
}