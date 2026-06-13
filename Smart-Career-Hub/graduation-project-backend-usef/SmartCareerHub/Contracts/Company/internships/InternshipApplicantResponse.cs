public record InternshipApplicantResponse(
    string ApplicationId,
    string ApplicantName,
    string Email,
    string InternshipPosition,
    DateTime AppliedDate,
    string Status,
    string UserId // هتستخدمه للانتقال لبروفايل الطالب
);