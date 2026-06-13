using SmartCareerHub.Contracts.Company.CreateRoadmap;

public record RoadmapRequest(
    string Title,
    string Description,
    string TargetRole,
    IFormFile? CoverImage,
    DateTime? StartDate,
    DateTime? EndDate,
    bool IsPublished,
    decimal? Price,
    List<RequiredSkillRequest> SkillRequests,
    List<LearningMaterialRequest> LearningMaterialRequests,
    List<ProjectRequest> ProjectRequests,
    List<QuizRequest>? QuizRequests // ← ضيف ده
);