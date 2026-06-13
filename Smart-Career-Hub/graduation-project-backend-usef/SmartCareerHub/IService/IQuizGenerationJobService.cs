// IQuizGenerationJobService.cs
public interface IQuizGenerationJobService
{
    Task<QuizGenerationJobDto> CreateJobAsync(string topic, int roadmapId, string quizType, int numQuestions);
    Task<QuizGenerationJobDto> GetJobAsync(int jobId);
    Task<List<QuizGenerationJobDto>> GetPendingJobsAsync();
    Task MarkJobAsCompletedAsync(int jobId, int resultQuizId);
    Task MarkJobAsFailedAsync(int jobId, string errorMessage);
}