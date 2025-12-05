using SmartCareerHub.Contracts.Company.Interview;

namespace Business_Logic.IService
{
    public interface IInterviewService
    {
        Task<IEnumerable<InterviewResponse>> GetAllAsync(CancellationToken cancellationToken = default);
        Task<InterviewResponse?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
        Task<IEnumerable<InterviewResponse>> GetByRoadmapAsync(int roadmapId, CancellationToken cancellationToken = default);
        Task<IEnumerable<InterviewResponse>> GetByStatusAsync(string status, CancellationToken cancellationToken = default);
        Task<IEnumerable<InterviewResponse>> GetAIRecommendedAsync(CancellationToken cancellationToken = default);
        Task<IEnumerable<InterviewResponse>> GetTodayInterviewsAsync(CancellationToken cancellationToken = default);
        Task<IEnumerable<InterviewResponse>> SearchInterviewsAsync(string searchTerm, CancellationToken cancellationToken = default);

        Task<InterviewResponse> AddAsync(InterviewRequest request, CancellationToken cancellationToken = default);
        Task<bool> UpdateAsync(int id, InterviewRequest request, CancellationToken cancellationToken = default);

        Task<bool> UpdateStatusAsync(int id, string status, CancellationToken cancellationToken = default);
        Task<bool> BulkUpdateStatusAsync(List<int> ids, string status, CancellationToken cancellationToken = default);

        Task<bool> DeleteAsync(int id, CancellationToken cancellationToken = default);
        Task<bool> BulkDeleteAsync(List<int> ids, CancellationToken cancellationToken = default);

        Task<int> GetTotalCountAsync(CancellationToken cancellationToken = default);
        Task<int> GetTodayCountAsync(CancellationToken cancellationToken = default);
        Task<IEnumerable<InterviewResponse>> GetLatestInterviewsAsync(int count, CancellationToken cancellationToken = default);
    }
}