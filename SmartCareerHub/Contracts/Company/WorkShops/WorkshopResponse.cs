namespace SmartCareerHub.Contracts.Company.WorkShops
{
    public record WorkshopResponse(
         int Id,
         string Title,
         string Description,
         string? BannerUrl,
         int UniversityId,
         string UniversityName,
         string Location,
         int MaxCapacity,
         string WorkshopType,
         int TotalPoints,
         bool RequireCV,
          bool IsPublished,
         bool RequireRoadmapCompletion,
         DateTime CreatedAt,
         DateTime UpdatedAt,
         List<MaterialResponse> Materials,
         List<ActivityResponse> Activities
     );
}
