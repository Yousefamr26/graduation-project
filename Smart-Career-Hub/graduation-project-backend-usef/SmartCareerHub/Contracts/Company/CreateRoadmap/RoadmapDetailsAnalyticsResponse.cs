// SmartCareerHub.Contracts/Company/CreateRoadmap/RoadmapDetailsAnalyticsResponse.cs
public record RoadmapDetailsAnalyticsResponse(
    int Id,
    string Title,
    string Description,
    string TargetRole,
    string? CoverImageUrl,
    bool IsPublished,
    DateTime CreatedAt,
    int EnrolledCount,
    int CompletedCount,
    double CompletionRate,
    double AverageProgress,
    int TotalMaterials,
    int TotalProjects,
    int TotalQuizzes,
    int TotalPoints
);