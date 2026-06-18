namespace SmartCareerHub.Contracts.Workshops.Enrollment
{
    public record WorkshopAvailableItem(
        int WorkshopId,
        string Title,
        string Description,
        string? BannerUrl,
        string Location,
        string WorkshopType,  // Online | Onsite | Hybrid
        int MaxCapacity,
        int CurrentEnrollments,
        bool RequireCV,
        bool RequireRoadmapCompletion,
        int TotalPoints
    );

    public record WorkshopsAvailableResponse(
        List<WorkshopAvailableItem> Workshops
    );
}