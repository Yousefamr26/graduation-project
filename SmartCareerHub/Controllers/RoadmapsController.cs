using Business_Logic.Errors;
using Business_Logic.IService;
using DataAccess.Abstractions;
using Microsoft.AspNetCore.Mvc;
using SmartCareerHub.Contracts.Company.CreateRoadmap;
using SmartCareerHub.Extensions;

namespace SmartCareerHub.Controllers;

[ApiController]
[Route("api/[controller]")]
public class RoadmapsController : ControllerBase
{
    private readonly IRoadmapService _roadmapService;
    private readonly IQuizService _quizService;

    public RoadmapsController(IRoadmapService roadmapService, IQuizService quizService)
    {
        _roadmapService = roadmapService;
        _quizService = quizService;
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var roadmap = await _roadmapService.GetByIdAsync(id);
        if (roadmap == null)
            return Result.Failure<RoadmapResponse>(RoadmapErrors.RoadmapNotFound).ToActionResult();

        return Result.Success(roadmap).ToActionResult();
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var roadmaps = await _roadmapService.GetAllAsync();
        return Result.Success(roadmaps).ToActionResult();
    }

    [HttpGet("published")]
    public async Task<IActionResult> GetPublished()
    {
        var roadmaps = await _roadmapService.GetAllAsync();
        var published = roadmaps.Where(r => r.IsPublished);
        return Result.Success(published).ToActionResult();
    }

    [HttpGet("targetrole/{role}")]
    public async Task<IActionResult> GetByTargetRole(string role)
    {
        if (string.IsNullOrWhiteSpace(role))
            return Result.Failure<IEnumerable<RoadmapResponse>>(RoadmapErrors.RoadmapInvalidRequest).ToActionResult();

        var roadmaps = await _roadmapService.GetAllAsync();
        var filtered = roadmaps.Where(r =>
            !string.IsNullOrEmpty(r.TargetRole) &&
            r.TargetRole.Equals(role, StringComparison.OrdinalIgnoreCase));

        return Result.Success(filtered).ToActionResult();
    }

    [HttpGet("search")]
    public async Task<IActionResult> Search([FromQuery] string keyword)
    {
        if (string.IsNullOrWhiteSpace(keyword))
            return Result.Failure<IEnumerable<RoadmapResponse>>(RoadmapErrors.RoadmapInvalidRequest).ToActionResult();

        var roadmaps = await _roadmapService.GetAllAsync();
        var filtered = roadmaps.Where(r =>
            !string.IsNullOrEmpty(r.Title) &&
            r.Title.Contains(keyword, StringComparison.OrdinalIgnoreCase));

        return Result.Success(filtered).ToActionResult();
    }

    [HttpGet("latest")]
    public async Task<IActionResult> GetLatest([FromQuery] int count = 10)
    {
        if (count <= 0 || count > 100)
            return Result.Failure<IEnumerable<RoadmapResponse>>(RoadmapErrors.RoadmapInvalidRequest).ToActionResult();

        var roadmaps = await _roadmapService.GetAllAsync();
        var latest = roadmaps.OrderByDescending(r => r.CreatedAt).Take(count);

        return Result.Success(latest).ToActionResult();
    }

    [HttpGet("top")]
    public async Task<IActionResult> GetTopByPoints([FromQuery] int count = 10)
    {
        if (count <= 0 || count > 100)
            return Result.Failure<IEnumerable<RoadmapResponse>>(RoadmapErrors.RoadmapInvalidRequest).ToActionResult();

        var roadmaps = await _roadmapService.GetAllAsync();
        var top = roadmaps.OrderByDescending(r => r.totalPoints).Take(count);

        return Result.Success(top).ToActionResult();
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromForm] RoadmapRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Title))
            return Result.Failure<RoadmapResponse>(RoadmapErrors.RoadmapInvalidRequest).ToActionResult();

        var titleExists = await _roadmapService.IsTitleExistsAsync(request.Title);
        if (titleExists)
            return Result.Failure<RoadmapResponse>(RoadmapErrors.RoadmapTitleExists).ToActionResult();

        var roadmap = await _roadmapService.AddAsync(request);
        return Result.Success(roadmap).ToCreatedResult(nameof(GetById), new { id = roadmap.Id });
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromForm] RoadmapRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Title))
            return Result.Failure<RoadmapResponse>(RoadmapErrors.RoadmapInvalidRequest).ToActionResult();

        var titleExists = await _roadmapService.IsTitleExistsAsync(request.Title, id);
        if (titleExists)
            return Result.Failure<RoadmapResponse>(RoadmapErrors.RoadmapTitleExists).ToActionResult();

        var updated = await _roadmapService.UpdateAsync(id, request, request.CoverImage);
        if (!updated)
            return Result.Failure<RoadmapResponse>(RoadmapErrors.RoadmapNotFound).ToActionResult();

        return Result.Success().ToActionResult();
    }

    [HttpPatch("toggle/{id:int}")]
    public async Task<IActionResult> ToggleStatus(int id)
    {
        var result = await _roadmapService.ToggleStatusAsync(id);
        if (!result)
            return Result.Failure(RoadmapErrors.RoadmapNotFound).ToActionResult();

        return Result.Success().ToActionResult();
    }

    [HttpPatch("bulkstatus")]
    public async Task<IActionResult> BulkStatus([FromQuery] bool isPublished, [FromBody] List<int> ids)
    {
        if (ids == null || !ids.Any())
            return Result.Failure<IEnumerable<RoadmapResponse>>(RoadmapErrors.RoadmapNoIdsProvided).ToActionResult();

        var result = await _roadmapService.BulkUpdateStatusAsync(ids, isPublished);
        return Result.Success(new { updatedCount = ids.Count, success = result }).ToActionResult();
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _roadmapService.DeleteWithAllChildrenAsync(id);
        if (!result)
            return Result.Failure(RoadmapErrors.RoadmapNotFound).ToActionResult();

        return Result.Success().ToActionResult();
    }

    [HttpDelete("bulkdelete")]
    public async Task<IActionResult> BulkDelete([FromBody] List<int> ids)
    {
        if (ids == null || !ids.Any())
            return Result.Failure<IEnumerable<RoadmapResponse>>(RoadmapErrors.RoadmapNoIdsProvided).ToActionResult();

        var result = await _roadmapService.BulkDeleteAsync(ids);
        return Result.Success(new { deletedCount = ids.Count, success = result }).ToActionResult();
    }

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
        if (quiz.IsFailure)
            return quiz.ToActionResult();

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
}
