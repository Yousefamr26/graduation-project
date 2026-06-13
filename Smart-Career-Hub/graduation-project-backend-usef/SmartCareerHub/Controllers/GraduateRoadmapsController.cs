using Business_Logic.IService;
using Business_Logic.Service;
using Business_Logic.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartCareerHub.Contracts.Student.Roadmaps;
using SmartCareerHub.Extensions;
using System.Security.Claims;

[Authorize(Roles = "Graduate")]
[ApiController]
[Route("api/graduate/roadmaps")]
public class GraduateRoadmapsController : ControllerBase
{
    private readonly IRoadmapService _roadmapService;
    private readonly IInterviewService _interviewService;
    private readonly IQuizService _quizService;

    public GraduateRoadmapsController(
        IRoadmapService roadmapService,
        IInterviewService interviewService,
        IQuizService quizService)
    {
        _roadmapService = roadmapService;
        _interviewService = interviewService;
        _quizService = quizService;
    }

    [HttpPost("enroll")]
    public async Task<ActionResult> Enroll([FromBody] EnrollRoadmapRequest request)
    {
        try
        {
            string graduateId = GetCurrentGraduateId();
            await _roadmapService.EnrollAsync(graduateId, request);
            return Ok(new { Message = "Graduate enrolled successfully." });
        }
        catch (Exception ex)
        {
            var msg = ex.InnerException?.Message ?? ex.Message;
            return StatusCode(500, new { message = msg });
        }
    }
    [HttpDelete("{roadmapId:int}/unenroll")]
    public async Task<IActionResult> Unenroll(int roadmapId)
    {
        try
        {
            string graduateId = GetCurrentGraduateId();
            var result = await _roadmapService.UnenrollAsync(graduateId, roadmapId);

            if (!result.IsSuccess)
                return BadRequest(new { Message = result.Error.Description });

            return Ok(new { Message = "Unenrolled successfully from the roadmap." });
        }
        catch (Exception ex)
        {
            var msg = ex.InnerException?.Message ?? ex.Message;
            return StatusCode(500, new { message = msg });
        }
    }

    [HttpGet("my")]
    public async Task<ActionResult<IEnumerable<RoadmapCatalogItemResponse>>> GetMyRoadmaps()
    {
        string graduateId = GetCurrentGraduateId();
        var response = await _roadmapService.GetUserRoadmapsAsync(graduateId);
        return Ok(response);
    }

    [HttpGet("catalog")]
    public async Task<ActionResult<RoadmapCatalogResponse>> GetCatalog([FromQuery] QueryParameters query)
    {
        var response = await _roadmapService.GetAllAsync(query);
        return Ok(response);
    }

    [HttpGet("{roadmapId:int}")]
    public async Task<ActionResult<RoadmapDetailsResponse>> GetRoadmapDetails(int roadmapId)
    {
        try
        {
            string graduateId = GetCurrentGraduateId();
            var response = await _roadmapService.GetUserRoadmapDetailsAsync(graduateId, roadmapId);
            return Ok(response);
        }
        catch (Exception ex)
        {
            var msg = ex.InnerException?.Message ?? ex.Message;
            return StatusCode(500, new { message = msg });
        }
    }

    [HttpPost("progress")]
    public async Task<IActionResult> UpdateProgress([FromBody] UpdateRoadmapProgressRequest request)
    {
        string graduateId = GetCurrentGraduateId();
        await _roadmapService.UpdateProgressAsync(graduateId, request);
        return Ok(new { Message = "Progress updated successfully." });
    }

    [HttpGet("my-interviews")]
    public async Task<IActionResult> GetMyInterviews([FromQuery] QueryParameters query)
    {
        string graduateId = GetCurrentGraduateId();
        var result = await _interviewService.GetUpcomingInterviewsAsync(graduateId, query);
        if (!result.IsSuccess) return BadRequest(result.Error);
        return Ok(result.Value);
    }

    // ===================== QUIZZES =====================

    [HttpPost("{roadmapId}/quizzes/{quizId}/questions/{questionId}/submit")]
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> SubmitAnswer(
        int roadmapId, int quizId, int questionId,
        [FromForm] string? answerText,
        IFormFile? answerFile)
    {
        string graduateId = GetCurrentGraduateId();

        var attemptResult = await _roadmapService.GetOrCreateQuizAttemptIdAsync(graduateId, quizId);

        if (!attemptResult.IsSuccess)
            return BadRequest(new { Message = attemptResult.Error.Description });

        var attemptId = attemptResult.Value;

        var result = await _quizService.SubmitQuizAnswerAsync(
            graduateId,
            attemptId,
            questionId,
            answerText,
            answerFile
        );

        return result.ToActionResult();
    }

    [HttpGet("{roadmapId}/quizzes/{quizId}/answers")]
    public async Task<IActionResult> GetMyAnswers(int roadmapId, int quizId)
    {
        string graduateId = GetCurrentGraduateId();
        var result = await _quizService.GetStudentAnswersAsync(graduateId, quizId);
        return result.ToActionResult();
    }

    [HttpPost("{roadmapId}/quizzes/{quizId}/finish")]
    public async Task<IActionResult> FinishQuiz(int roadmapId, int quizId)
    {
        string graduateId = GetCurrentGraduateId();

        var result = await _quizService.FinishQuizAttemptAsync(graduateId, quizId);

        if (!result.IsSuccess)
            return BadRequest(new { Message = result.Error.Description });

        return Ok(result.Value);
    }

    [HttpGet("{roadmapId}/quizzes/{quizId}/score")]
    public async Task<IActionResult> GetQuizScore(int roadmapId, int quizId)
    {
        string graduateId = GetCurrentGraduateId();

        var result = await _quizService.GetQuizScoreAsync(graduateId, quizId);

        if (!result.IsSuccess)
            return BadRequest(new { Message = result.Error.Description });

        return Ok(result.Value);
    }

    // ===================== Helper =====================
    private string GetCurrentGraduateId()
    {
        var claim = User.Claims.FirstOrDefault(c => c.Type == "GraduateId");
        if (claim == null || string.IsNullOrEmpty(claim.Value))
            throw new UnauthorizedAccessException("Graduate ID not found in user claims.");
        return claim.Value;
    }
}