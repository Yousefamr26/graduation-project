namespace SmartCareerHub.Contracts.Company.CreateRoadmap
{
  
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

        List<RequiredSkillResponse> RequiredSkills,
        List<ProjectResponse> Projects,
        List<QuizResponse> Quizzes,
        List<LearningMaterialResponse> LearningMaterials

  
    );
}