public record EnrollWorkshopResponse(
    string EnrollmentId,
    int WorkshopId,
    string UserId,
    DateTime RegisteredAt,
    bool CvUploaded,
    bool RoadmapCompleted,
    string? HostName  // ← ضيف ده
);