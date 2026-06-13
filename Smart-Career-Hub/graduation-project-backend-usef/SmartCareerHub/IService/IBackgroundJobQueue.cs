public interface IBackgroundJobQueue
{
    public enum JobStatus
    {
        Pending,
        Running,
        Completed,
        Failed
    }
    JobStatus? GetStatus(string jobId);
    void Enqueue(Func<Task> job);
    Task<Func<Task>> DequeueAsync(CancellationToken cancellationToken);
   
}