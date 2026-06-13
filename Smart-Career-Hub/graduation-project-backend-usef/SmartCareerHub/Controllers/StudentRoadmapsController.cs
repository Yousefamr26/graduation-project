using Business_Logic.IService;
using Business_Logic.Service;
using Business_Logic.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartCareerHub.Contracts.Student.Roadmaps;
using SmartCareerHub.Extensions;
using System.Security.Claims;

[Authorize(Roles = "Student")]
[ApiController]
[Route("api/student/roadmaps")]
public class StudentRoadmapsController : ControllerBase
{
    private readonly IRoadmapService _roadmapService;
    private readonly IInterviewService _interviewService;
    private readonly IQuizService _quizService;

    public StudentRoadmapsController(
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
            string studentId = GetCurrentStudentId();
            await _roadmapService.EnrollAsync(studentId, request);
            return Ok(new { Message = "Student enrolled successfully." });
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
            string studentId = GetCurrentStudentId();
            var result = await _roadmapService.UnenrollAsync(studentId, roadmapId);

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
        string studentId = GetCurrentStudentId();
        var response = await _roadmapService.GetUserRoadmapsAsync(studentId);
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
        string studentId = GetCurrentStudentId();
        var response = await _roadmapService.GetUserRoadmapDetailsAsync(studentId, roadmapId);
        return Ok(response);
    }

    [HttpPost("progress")]
    public async Task<IActionResult> UpdateProgress([FromBody] UpdateRoadmapProgressRequest request)
    {
        string studentId = GetCurrentStudentId();
        await _roadmapService.UpdateProgressAsync(studentId, request);
        return Ok(new { Message = "Progress updated successfully." });
    }

    [HttpGet("my-interviews")]
    public async Task<IActionResult> GetMyInterviews([FromQuery] QueryParameters query)
    {
        string studentId = GetCurrentStudentId();
        var result = await _interviewService.GetUpcomingInterviewsAsync(studentId, query);
        if (!result.IsSuccess) return BadRequest(result.Error);
        return Ok(result.Value);
    }

    // ===================== QUIZZES =====================

    // ===================== QUIZZES =====================

    [HttpPost("{roadmapId}/quizzes/{quizId}/submit")]
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> SubmitAnswer(
        int quizId,
        [FromForm] int questionId, // يفضل تكون من الفورم
        [FromForm] string? answerText,
        IFormFile? answerFile)
    {
        string studentId = GetCurrentStudentId();

        // 1. الأفضل تنادي الـ QuizService مباشرة لإدارة المحاولة
        var attemptResult = await _quizService.StartQuizAttemptAsync(studentId, quizId);

        if (!attemptResult.IsSuccess)
            return BadRequest(new { Message = attemptResult.Error.Description });

        var attemptId = attemptResult.Value;

        // 2. إرسال الإجابة
        var result = await _quizService.SubmitQuizAnswerAsync(
            studentId,
            attemptId,
            questionId,
            answerText,
            answerFile
        );

        return result.ToActionResult();
    }

    // Get all submitted answers for a quiz
    [HttpGet("{roadmapId}/quizzes/{quizId}/answers")]
    public async Task<IActionResult> GetMyAnswers(int roadmapId, int quizId)
    {
        string studentId = GetCurrentStudentId();
        var result = await _quizService.GetStudentAnswersAsync(studentId, quizId);
        return result.ToActionResult();
    }
    // ===================== FINISH QUIZ & GET SCORE =====================


    [HttpPost("{roadmapId}/quizzes/{quizId}/finish")]
    public async Task<IActionResult> FinishQuiz(int roadmapId, int quizId)
    {
        string studentId = GetCurrentStudentId();

        var result = await _quizService.FinishQuizAttemptAsync(studentId, quizId);

        if (!result.IsSuccess)
            return BadRequest(new { Message = result.Error.Description });

        return Ok(result.Value);
    }


    [HttpGet("{roadmapId}/quizzes/{quizId}/score")]
    public async Task<IActionResult> GetQuizScore(int roadmapId, int quizId)
    {
        string studentId = GetCurrentStudentId();

        var result = await _quizService.GetQuizScoreAsync(studentId, quizId);

        if (!result.IsSuccess)
            return BadRequest(new { Message = result.Error.Description });

        return Ok(result.Value);
    }

    // ===================== Helper =====================

    private string GetCurrentStudentId()
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (string.IsNullOrEmpty(userId))
            throw new UnauthorizedAccessException("User ID not found in token.");

        return userId;
    }
}