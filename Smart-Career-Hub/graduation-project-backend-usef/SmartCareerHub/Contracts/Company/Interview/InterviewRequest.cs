public record InterviewRequest(
    string StudentUserId,    // ← ID بتاع الطالب من الجدول
    string? StudentName,     // ← اختياري كـ fallback
    int? RoadmapId,
    DateTime ScheduledDate,
    string InterviewType,
    string InterviewerName,
    string? AdditionalNotes
);