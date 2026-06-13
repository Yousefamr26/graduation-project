using Business_Logic.DTOs.StudentProgress;

public record UserRoadmapResponse(
         int Id,
    string UserId,
    int RoadmapId,
    int ProgressPercent,
    string Status,
    DateTime JoinedAt,
    DateTime? UpdatedAt,
    IEnumerable<UserProgressRespons> ProgressItems
    );