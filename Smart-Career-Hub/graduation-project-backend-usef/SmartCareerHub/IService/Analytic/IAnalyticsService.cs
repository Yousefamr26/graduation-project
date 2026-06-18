namespace Business_Logic.IService
{
    public interface IAnalyticsService
    {
        Task<object> GetDashboardOverviewAsync(CancellationToken cancellationToken = default);
        Task<object> GetRoadmapDashboardAsync(CancellationToken cancellationToken = default);
        Task<object> GetRoadmapAnalyticsAsync(CancellationToken cancellationToken = default);
        Task<object> GetJobAnalyticsAsync(CancellationToken cancellationToken = default);
        Task<object> GetInternshipAnalyticsAsync(CancellationToken cancellationToken = default);
        Task<object> GetWorkshopAnalyticsAsync(CancellationToken cancellationToken = default);
        Task<object> GetEventAnalyticsAsync(CancellationToken cancellationToken = default);
        Task<object> GetInterviewAnalyticsAsync(CancellationToken cancellationToken = default);
        Task<object> GetInterviewCompletionRateOverTimeAsync(string period, int year, CancellationToken cancellationToken = default);
        Task<object> GetUniversityAnalyticsAsync(CancellationToken cancellationToken = default);
    }
}