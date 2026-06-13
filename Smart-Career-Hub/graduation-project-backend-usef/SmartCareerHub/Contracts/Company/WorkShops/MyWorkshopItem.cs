public record MyWorkshopItem(
    int WorkshopId,
    string Title,
    string? BannerUrl,
    bool CvUploaded,
    bool RoadmapCompleted,
    DateTime RegisteredAt,
    int TotalPoints
);
