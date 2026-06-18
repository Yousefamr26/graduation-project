public record EventEnrollmentSimpleResponse(
    string EnrollmentId,
    DateTime EnrolledAt,
    string Message,
    string? HostName // ← ضيف ده
);