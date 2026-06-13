using System.Collections.Concurrent;
using System.Net.NetworkInformation;
using static IBackgroundJobQueue;

public class BackgroundJobQueue : IBackgroundJobQueue
{
    private readonly ConcurrentQueue<Func<Task>> _jobs = new();
    private readonly SemaphoreSlim _signal = new(0);
    private readonly ConcurrentDictionary<string, JobStatus> _status = new();


    public void Enqueue(Func<Task> job)
    {
        if (job == null)
            throw new ArgumentNullException(nameof(job));

        _jobs.Enqueue(job);
        _signal.Release();
    }

    public async Task<Func<Task>> DequeueAsync(CancellationToken cancellationToken)
    {
        await _signal.WaitAsync(cancellationToken);
        _jobs.TryDequeue(out var job);
        return job;
    }
    public JobStatus? GetStatus(string jobId)
    {
        if (_status.TryGetValue(jobId, out var status))
            return status;
        return null;
    }
}