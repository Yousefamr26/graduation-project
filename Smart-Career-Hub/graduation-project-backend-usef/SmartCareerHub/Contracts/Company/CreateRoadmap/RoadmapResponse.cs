using SmartCareerHub.Contracts.Company.CreateRoadmap;

public record RoadmapResponse(
    int Id,
    string Title,
    string Description,
    string TargetRole,
    string CoverImageUrl,
    DateTime? StartDate,
    DateTime? EndDate,
    bool IsPublished,
    DateTime CreatedAt,
    int totalPoints,
    string CompanyName,
    decimal? Price,
    List<RequiredSkillResponse> RequiredSkills,
    List<ProjectResponse> Projects,
    List<LearningMaterialResponse> LearningMaterials,
    List<QuizResponse>? Quizzes // ← ضيف ده
);