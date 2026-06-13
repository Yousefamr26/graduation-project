public record CourseStudentCardResponse(
    string UserId,
    string FullName,
    string Email,
    string BatchName,
    double CourseProgress,
    double AttendancePercentage,
    string AssignmentsStatus,   // 8/10
    double QuizAverage,
    DateTime EnrolledOn
);