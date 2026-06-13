// QuizGenerationJobService.cs
using DataAccess.Contexts;
using DataAccess.Entities.RoadMap;
using Microsoft.EntityFrameworkCore;
using SendGrid.Helpers.Mail;

public class QuizGenerationJobService : IQuizGenerationJobService
{
    private readonly ApplicationDbContext _dbContext;

    public QuizGenerationJobService(ApplicationDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<QuizGenerationJobDto> CreateJobAsync(string topic, int roadmapId, string quizType, int numQuestions)
    {
        var job = new QuizGenerationJob
        {
            RoadmapId = roadmapId,
            QuizType = quizType,        // تأكد إن البروبرتي دي موجودة في الـ Entity
            NumQuestions = numQuestions, // تأكد إن البروبرتي دي موجودة في الـ Entity
            Status = "Pending",
            CreatedAt = DateTime.UtcNow
        };

        _dbContext.QuizGenerationJobs.Add(job);
        await _dbContext.SaveChangesAsync();

        // املأ الـ DTO ورجعه
        return new QuizGenerationJobDto { Id = job.Id, Status = job.Status /* ... بقية البيانات */ };
    }

    public async Task<QuizGenerationJobDto> GetJobAsync(int jobId)
    {
        var job = await _dbContext.QuizGenerationJobs.FirstOrDefaultAsync(j => j.Id == jobId);
        if (job == null) return null;

        return new QuizGenerationJobDto
        {
            Id = job.Id,
           
            RoadmapId = job.RoadmapId,
            ResultQuizId = job.ResultQuizId,
            Status = job.Status,
            CreatedAt = job.CreatedAt,
            CompletedAt = job.CompletedAt
        };
    }

    public async Task<List<QuizGenerationJobDto>> GetPendingJobsAsync()
    {
        var jobs = await _dbContext.QuizGenerationJobs
            .Where(j => j.Status == "Pending")
            .ToListAsync();

        return jobs.Select(j => new QuizGenerationJobDto
        {
            Id = j.Id,
          
            RoadmapId = j.RoadmapId,
            Status = j.Status,
            CreatedAt = j.CreatedAt
        }).ToList();
    }

    public async Task MarkJobAsCompletedAsync(int jobId, int resultQuizId)
    {
        var job = await _dbContext.QuizGenerationJobs.FirstOrDefaultAsync(j => j.Id == jobId);
        if (job == null) throw new Exception("Job not found");

        job.Status = "Completed";
        job.ResultQuizId = resultQuizId;
        job.CompletedAt = DateTime.UtcNow;

        await _dbContext.SaveChangesAsync();
    }
    public async Task MarkJobAsFailedAsync(int jobId, string errorMessage)
    {
        // بنجيب الـ Job من الداتابيز
        var job = await _dbContext.QuizGenerationJobs.FindAsync(jobId);
        if (job != null)
        {
            job.Status = "Failed"; // ✅ تغيير الحالة عشان الـ Worker ميبصش عليها تاني
            job.ErrorMessage = errorMessage; // تخزين سبب المشكلة (سواء Path أو AI Error)
           

            _dbContext.QuizGenerationJobs.Update(job);
            await _dbContext.SaveChangesAsync();
        }
    }
}