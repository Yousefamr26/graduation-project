public record WorkshopCatalogItem(
    int Id,
    string Title,
    string Description,
    string? BannerUrl,
    int MaxCapacity,
    int CurrentEnrollments,
    bool RequireCV,
    bool RequireRoadmapCompletion,
    int TotalPoints
);
