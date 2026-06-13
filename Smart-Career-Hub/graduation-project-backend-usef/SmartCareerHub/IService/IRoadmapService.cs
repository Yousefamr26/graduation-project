using DataAccess.Abstractions;
using SmartCareerHub.Contracts.Company.CreateRoadmap;
using SmartCareerHub.Contracts.Student.Roadmaps;

public interface IRoadmapService
{
    // =================== GET ===================
    Task<PagedResponse<RoadmapResponse>> GetAllAsync(
        QueryParameters query,
        CancellationToken cancellationToken = default);

    Task<PagedResponse<RoadmapResponse>> GetPublishedAsync(
        QueryParameters query,
        CancellationToken cancellationToken = default);

    Task<PagedResponse<RoadmapResponse>> GetByTargetRoleAsync(
        string role,
        QueryParameters query,
        CancellationToken cancellationToken = default);

    Task<RoadmapResponse?> GetByIdAsync(
        int id,
        CancellationToken cancellationToken = default);

    Task<RoadmapDetailsAnalyticsResponse> GetRoadmapDetailsAsync(
        string userId,
        int roadmapId,
        CancellationToken cancellationToken = default);

    // =================== ADD ===================
    Task<RoadmapResponse> AddAsync(
        string userId,
        RoadmapRequest request,
        CancellationToken cancellationToken = default);

    // =================== UPDATE ===================
    Task<bool> UpdateAsync(
        string userId,
        int id,
        RoadmapRequest request,
        IFormFile? coverImage = null,
        CancellationToken cancellationToken = default);

    Task<bool> ToggleStatusAsync(
        string userId,
        int id,
        CancellationToken cancellationToken = default);

    Task<bool> BulkUpdateStatusAsync(
        string userId,
        List<int> ids,
        bool isPublished,
        CancellationToken cancellationToken = default);

    // =================== DELETE ===================
    Task<bool> DeleteWithAllChildrenAsync(
        string userId,
        int id,
        CancellationToken cancellationToken = default);

    Task<bool> BulkDeleteAsync(
        string userId,
        List<int> ids,
        CancellationToken cancellationToken = default);

    // =================== HELPERS ===================
    Task<bool> IsTitleExistsAsync(
        string title,
        int? excludeId = null,
        CancellationToken cancellationToken = default);

    // =================== ENROLL ===================
    Task EnrollAsync(
        string userId,
        EnrollRoadmapRequest request,
        CancellationToken cancellationToken = default);

    Task<Result> UnenrollAsync(
        string userId,
        int roadmapId);

    // =================== PROGRESS ===================
    Task UpdateProgressAsync(
        string userId,
        UpdateRoadmapProgressRequest request);

    Task<Result> AddOrUpdateUserProgressAsync(
        string userId,
        int userRoadmapId,
        int materialId,
        string materialType,
        int pointsEarned = 0);

    // =================== USER ROADMAPS ===================
    Task<IEnumerable<RoadmapCatalogItemResponse>> GetUserRoadmapsAsync(
        string userId,
        CancellationToken cancellationToken = default);

    Task<RoadmapDetailsResponse> GetUserRoadmapDetailsAsync(
        string userId,
        int roadmapId,
        CancellationToken cancellationToken = default);
    Task<Result<int>> GetOrCreateQuizAttemptIdAsync(string userId, int quizId);
    Task<Result> AddAiGeneratedQuizAsync(int roadmapId, string quizTitle, List<Question> generatedQuestions);

}