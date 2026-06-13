using Microsoft.Extensions.Hosting;

public class QueuedHostedService : BackgroundService
{
    private readonly IBackgroundJobQueue _jobQueue;

    public QueuedHostedService(IBackgroundJobQueue jobQueue)
    {
        _jobQueue = jobQueue;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            var job = await _jobQueue.DequeueAsync(stoppingToken);
            try
            {
                await job();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Background job failed: {ex}");
            }
        }
    }
}