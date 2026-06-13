using Business_Logic.IService;

public class QuizJobWorker : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;

    public QuizJobWorker(IServiceScopeFactory scopeFactory)
    {
        _scopeFactory = scopeFactory;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var scope = _scopeFactory.CreateScope();
                var jobService = scope.ServiceProvider.GetRequiredService<IQuizGenerationJobService>();
                var quizService = scope.ServiceProvider.GetRequiredService<IQuizService>();

                var pendingJobs = await jobService.GetPendingJobsAsync();

                foreach (var job in pendingJobs)
                {
                    try
                    {
                        // 1. محاولة توليد الكويز
                        int generatedQuizId = await quizService.GenerateQuizFromAIJobAsync(
                            job.RoadmapId,
                            "MCQ",
                            5
                        );

                        // 2. النجاح
                        await jobService.MarkJobAsCompletedAsync(job.Id, generatedQuizId);
                        Console.WriteLine($"[Success] Job {job.Id} completed.");
                    }
                    catch (Exception ex)
                    {
                        // ✅ التعديل الجوهري: لازم نغير حالة الـ Job لـ Failed عشان الـ Loop يقف
                        Console.WriteLine($"[CRITICAL] Job {job.Id} failed: {ex.Message}");

                        // بننادي الميثود اللي ضفناها في الـ Interface
                        await jobService.MarkJobAsFailedAsync(job.Id, ex.Message);
                    }
                }
            }
            catch (Exception globalEx)
            {
                Console.WriteLine($"[Worker Error] {globalEx.Message}");
            }

            // بنستنى 10 ثواني بدل 5 عشان ندي السيرفر هدنة
            await Task.Delay(10000, stoppingToken);
        }
    }
}