public record InterviewResponse(
    int Id,
    string StudentName,
    int RoadmapId,
    string RoadmapName,
    DateTime Date,
    string InterviewType,
    string? MeetingLink,      // ✅ موجود في Entity
    string? Location,         // ✅ موجود في Entity
    string InterviewerName,
    string? AdditionalNotes,
    InterviewStatus Status,
    InterviewResult Result,   // ✅ موجود في Entity
    string? Feedback,         // ✅ موجود في Entity
    bool IsAIPick,            // ✅ موجود في Entity
    string? CompanyName,      // ✅ من Roadmap.Company
    DateTime CreatedAt
);