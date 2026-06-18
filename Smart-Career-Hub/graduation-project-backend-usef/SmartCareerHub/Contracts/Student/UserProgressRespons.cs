using DataAccess.Entities.RoadMap;

public record UserProgressRespons(
    int Id,
    int RoadmapId,
    int ItemId,
    ProgressMaterialType ItemType,
    bool Completed,
    int PointsEarned,
    DateTime? CompletedAt
);
