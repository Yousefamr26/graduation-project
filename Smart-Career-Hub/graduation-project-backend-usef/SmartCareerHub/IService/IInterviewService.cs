using DataAccess.Abstractions;
using DataAccess.Entities.Interview;

public interface IInterviewService
{
    // =================== GET ===================
    Task<PagedResponse<InterviewResponse>> GetAllAsync(
        QueryParameters query,
        CancellationToken cancellationToken = default);

    Task<InterviewResponse?> GetByIdAsync(
        int id,
        CancellationToken cancellationToken = default);

    Task<PagedResponse<InterviewResponse>> GetByRoadmapAsync(
        int roadmapId,
        QueryParameters query,
        CancellationToken cancellationToken = default);

    Task<PagedResponse<InterviewResponse>> GetByStatusAsync(
        InterviewStatus status,
        QueryParameters query,
        CancellationToken cancellationToken = default);

    Task<PagedResponse<InterviewResponse>> GetAIRecommendedAsync(
        QueryParameters query,
        CancellationToken cancellationToken = default);

    Task<PagedResponse<InterviewResponse>> GetTodayInterviewsAsync(
        QueryParameters query,
        CancellationToken cancellationToken = default);

    Task<PagedResponse<InterviewResponse>> SearchInterviewsAsync(
        string searchTerm,
        QueryParameters query,
        CancellationToken cancellationToken = default);

    Task<PagedResponse<InterviewResponse>> GetLatestInterviewsAsync(
        int count,
        QueryParameters query,
        CancellationToken cancellationToken = default);

    Task<Result<PagedResponse<InterviewResponse>>> GetUpcomingInterviewsAsync(
        string userId,
        QueryParameters query,
        CancellationToken cancellationToken = default);

    Task<Result<PagedResponse<InterviewResponse>>> GetPastInterviewsAsync(
        string userId,
        QueryParameters query,
        CancellationToken cancellationToken = default);

    Task<Result<InterviewResponse?>> GetInterviewByIdForUserAsync(
        int id,
        string userId,
        CancellationToken cancellationToken = default);

    // =================== COUNT ===================
    Task<int> GetTotalCountAsync(CancellationToken cancellationToken = default);
    Task<int> GetTodayCountAsync(CancellationToken cancellationToken = default);

    // =================== ADD ===================
    Task<InterviewResponse> AddAsync(
        InterviewRequest request,
        string userId,
        CancellationToken cancellationToken = default);

    // =================== UPDATE ===================
    Task<bool> UpdateAsync(
        int id,
        InterviewRequest request,
        CancellationToken cancellationToken = default);

    Task<bool> UpdateStatusAsync(
        int id,
        InterviewStatus status,
        CancellationToken cancellationToken = default);

    Task<Result<bool>> AcceptInterviewAsync(
        int id,
        string userId,
        CancellationToken cancellationToken = default);

    Task<Result<bool>> DeclineInterviewAsync(
        int id,
        string userId,
        CancellationToken cancellationToken = default);

    Task<bool> BulkUpdateStatusAsync(
        List<int> ids,
        InterviewStatus status,
        CancellationToken cancellationToken = default);

    // =================== DELETE ===================
    Task<bool> DeleteAsync(
        int id,
        CancellationToken cancellationToken = default);

    Task<bool> BulkDeleteAsync(
        List<int> ids,
        CancellationToken cancellationToken = default);
}