using Business_Logic.Errors;
using Business_Logic.IService;
using DataAccess.Abstractions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartCareerHub.Contracts.Company.CreateRoadmap;
using SmartCareerHub.Extensions;
using System.Security.Claims;

namespace SmartCareerHub.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Company,TrainingCenter")]
public class RoadmapsController : ControllerBase
{
    private readonly IRoadmapService _roadmapService;
    private readonly IQuizService _quizService;
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly IQuizGenerationJobService _quizJobService; // ضيف السطر ده
    private readonly IBackgroundJobQueue _jobQueue;

    public RoadmapsController(IRoadmapService roadmapService, IQuizService quizService, IBackgroundJobQueue jobQueue ,  IServiceScopeFactory scopeFactory , IQuizGenerationJobService jobService)
    {
        _roadmapService = roadmapService;
        _quizService = quizService;
        _jobQueue = jobQueue;
        _scopeFactory = scopeFactory;
        _quizJobService = jobService; // ضيف السطر ده
    }

    // =================== GET ===================

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] QueryParameters query)
    {
        var roadmaps = await _roadmapService.GetAllAsync(query);
        return Result.Success(roadmaps).ToActionResult();
    }

    [HttpGet("published")]
    public async Task<IActionResult> GetPublished([FromQuery] QueryParameters query)
    {
        var roadmaps = await _roadmapService.GetPublishedAsync(query);
        return Result.Success(roadmaps).ToActionResult();
    }

    [HttpGet("search")]
    public async Task<IActionResult> Search(
        [FromQuery] string keyword,
        [FromQuery] QueryParameters query)
    {
        if (string.IsNullOrWhiteSpace(keyword))
            return Result.Failure<PagedResponse<RoadmapResponse>>(
                RoadmapErrors.RoadmapInvalidRequest).ToActionResult();

        query.Search = keyword;
        var roadmaps = await _roadmapService.GetAllAsync(query);
        return Result.Success(roadmaps).ToActionResult();
    }

    [HttpGet("targetrole/{role}")]
    public async Task<IActionResult> GetByTargetRole(
        string role,
        [FromQuery] QueryParameters query)
    {
        if (string.IsNullOrWhiteSpace(role))
            return Result.Failure<PagedResponse<RoadmapResponse>>(
                RoadmapErrors.RoadmapInvalidRequest).ToActionResult();

        var roadmaps = await _roadmapService.GetByTargetRoleAsync(role, query);
        return Result.Success(roadmaps).ToActionResult();
    }

    [HttpGet("latest")]
    public async Task<IActionResult> GetLatest([FromQuery] int count = 10)
    {
        if (count <= 0 || count > 100)
            return Result.Failure<PagedResponse<RoadmapResponse>>(
                RoadmapErrors.RoadmapInvalidRequest).ToActionResult();

        var query = new QueryParameters
        {
            Page = 1,
            PageSize = count,
            SortBy = "createdAt",
            SortDirection = "desc"
        };
        var roadmaps = await _roadmapService.GetAllAsync(query);
        return Result.Success(roadmaps).ToActionResult();
    }

    [HttpGet("top")]
    public async Task<IActionResult> GetTopByPoints([FromQuery] int count = 10)
    {
        if (count <= 0 || count > 100)
            return Result.Failure<PagedResponse<RoadmapResponse>>(
                RoadmapErrors.RoadmapInvalidRequest).ToActionResult();

        var query = new QueryParameters
        {
            Page = 1,
            PageSize = count,
            SortBy = "points",
            SortDirection = "desc"
        };
        var roadmaps = await _roadmapService.GetAllAsync(query);
        return Result.Success(roadmaps).ToActionResult();
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var roadmap = await _roadmapService.GetByIdAsync(id);
        if (roadmap == null)
            return Result.Failure<RoadmapResponse>(RoadmapErrors.RoadmapNotFound).ToActionResult();

        return Result.Success(roadmap with { CompanyName = roadmap.CompanyName ?? "" }).ToActionResult();
    }

    [HttpGet("{id:int}/details")]
    public async Task<IActionResult> GetDetails(int id)
    {
        var userId = GetUserId();
        var result = await _roadmapService.GetRoadmapDetailsAsync(userId, id);
        return Result.Success(result).ToActionResult();
    }

    // =================== CREATE ===================

    [HttpPost]
    public async Task<IActionResult> Create([FromForm] RoadmapRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Title))
            return Result.Failure<RoadmapResponse>(RoadmapErrors.RoadmapInvalidRequest).ToActionResult();

        try
        {
            var userId = GetUserId();
            var roadmap = await _roadmapService.AddAsync(userId, request);
            return Result.Success(roadmap with { CompanyName = roadmap.CompanyName ?? "" })
                .ToCreatedResult(nameof(GetById), new { id = roadmap.Id });
        }
        catch (Exception ex)
        {
            var msg = ex.InnerException?.Message ?? ex.Message;
            return StatusCode(500, new { message = msg });
        }
    }

    // =================== UPDATE ===================

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromForm] RoadmapRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Title))
            return Result.Failure<RoadmapResponse>(RoadmapErrors.RoadmapInvalidRequest).ToActionResult();

        var userId = GetUserId();
        var updated = await _roadmapService.UpdateAsync(userId, id, request, request.CoverImage);
        if (!updated)
            return Result.Failure<RoadmapResponse>(RoadmapErrors.RoadmapNotFound).ToActionResult();

        return Result.Success().ToActionResult();
    }

    [HttpPatch("toggle/{id:int}")]
    public async Task<IActionResult> ToggleStatus(int id)
    {
        var userId = GetUserId();
        var result = await _roadmapService.ToggleStatusAsync(userId, id);
        if (!result)
            return Result.Failure(RoadmapErrors.RoadmapNotFound).ToActionResult();

        return Result.Success().ToActionResult();
    }

    [HttpPatch("bulkstatus")]
    public async Task<IActionResult> BulkStatus([FromQuery] bool isPublished, [FromBody] List<int> ids)
    {
        if (ids == null || !ids.Any())
            return Result.Failure<IEnumerable<RoadmapResponse>>(
                RoadmapErrors.RoadmapNoIdsProvided).ToActionResult();

        var userId = GetUserId();
        var result = await _roadmapService.BulkUpdateStatusAsync(userId, ids, isPublished);
        return Result.Success(new { updatedCount = ids.Count, success = result }).ToActionResult();
    }

    // =================== DELETE ===================

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var userId = GetUserId();
        var result = await _roadmapService.DeleteWithAllChildrenAsync(userId, id);
        if (!result)
            return Result.Failure(RoadmapErrors.RoadmapNotFound).ToActionResult();

        return Result.Success().ToActionResult();
    }

    [HttpDelete("bulkdelete")]
    public async Task<IActionResult> BulkDelete([FromBody] List<int> ids)
    {
        if (ids == null || !ids.Any())
            return Result.Failure<IEnumerable<RoadmapResponse>>(
                RoadmapErrors.RoadmapNoIdsProvided).ToActionResult();

        var userId = GetUserId();
        var result = await _roadmapService.BulkDeleteAsync(userId, ids);
        return Result.Success(new { deletedCount = ids.Count, success = result }).ToActionResult();
    }

    // =================== QUIZZES ===================

    [HttpGet("{roadmapId:int}/quizzes")]
    public async Task<IActionResult> GetQuizzes(int roadmapId)
    {
        var quizzes = await _quizService.GetQuizzesByRoadmapIdAsync(roadmapId);
        return quizzes.ToActionResult();
    }

    [HttpGet("{roadmapId:int}/quizzes/{quizId:int}")]
    public async Task<IActionResult> GetQuizById(int roadmapId, int quizId)
    {
        var quiz = await _quizService.GetQuizByIdAsync(quizId);
        if (quiz.IsFailure) return quiz.ToActionResult();
        return Result.Success(quiz.Value).ToActionResult();
    }

    [HttpPost("{roadmapId:int}/quizzes")]
    public async Task<IActionResult> AddQuiz(int roadmapId, [FromForm] QuizRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Title))
            return Result.Failure(QuizErrors.QuizEmptyTitle).ToActionResult();

        var result = await _quizService.AddQuizToRoadmapAsync(roadmapId, request);
        return result.ToActionResult();
    }

    [HttpPut("quizzes/{quizId:int}")]
    public async Task<IActionResult> UpdateQuiz(int quizId, [FromForm] QuizRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Title))
            return Result.Failure(QuizErrors.QuizEmptyTitle).ToActionResult();

        var result = await _quizService.UpdateQuizAsync(quizId, request);
        return result.ToActionResult();
    }

    [HttpDelete("quizzes/{quizId:int}")]
    public async Task<IActionResult> DeleteQuiz(int quizId)
    {
        var result = await _quizService.DeleteQuizAsync(quizId);
        return result.ToActionResult();
    }

    // 🔹 Submit AI quiz generation job


    // في الـ Controller:
    [HttpPost("{roadmapId:int}/generate-quiz")]
    public async Task<IActionResult> GenerateQuizWithAI(int roadmapId, [FromQuery] string quizType = "MCQ", [FromQuery] int numQuestions = 5)
    {
        // 1. Validation سريع
        if (numQuestions < 1 || numQuestions > 20)
            return Result.Failure(new Error("Quiz.InvalidCount", "Number of questions must be between 1 and 20")).ToActionResult();

        // 2. التحقق من وجود الرودماب قبل البدء في الـ Job (خطوة استباقية مهمة)
        var roadmap = await _roadmapService.GetByIdAsync(roadmapId);
        if (roadmap == null)
            return Result.Failure(RoadmapErrors.RoadmapNotFound).ToActionResult();

        // 3. إضافة Job في الجدول
        // ملاحظة: الـ Job Worker هو من سيقوم في النهاية بمناداة _roadmapService.AddAiGeneratedQuizAsync
        var job = await _quizJobService.CreateJobAsync("AI Quiz Generation", roadmapId, quizType, numQuestions);

        return Accepted(new
        {
            jobId = job.Id,
            message = "تم استلام الطلب، الـ Worker سيبدأ المعالجة فوراً",
            status = "PENDING",
            roadmapId
        });
    }

    [HttpGet("{roadmapId:int}/generated-quiz")]
    [AllowAnonymous]
    public async Task<IActionResult> GetGeneratedQuiz(int roadmapId)
    {
        var result = await _quizService.GetGeneratedQuizzesByRoadmapIdAsync(roadmapId);

        if (result.IsFailure)
            return result.ToActionResult(); // استخدم الـ Extension اللي عندك لتوحيد شكل الـ Error

        var quizzes = result.Value;

        if (quizzes == null || !quizzes.Any())
        {
            return Accepted(new
            {
                message = "الذكاء الاصطناعي لا يزال يعمل أو لا يوجد كويزات مولدة لهذا الرودماب",
                status = "PENDING",
                code = "QUIZ_NOT_READY"
            });
        }

        return Ok(new
        {
            message = "تم استرجاع الكويزات بنجاح",
            status = "COMPLETED",
            data = quizzes
        });
    }

    [HttpGet("job-status/{jobId}")]
    public IActionResult GetJobStatus(string jobId)
    {
        // Lookup job status from your background job tracking (Pending/Completed/Failed)
        var status = _jobQueue.GetStatus(jobId);
        return Ok(new { jobId, status });
    }



    // =================== HELPER ===================

    private string GetUserId() =>
        User?.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value
        ?? throw new UnauthorizedAccessException("User ID claim not found.");
}