public record JobApplicantResponse(
    int ApplicationId,
    string ApplicantName,
    string JobTitle,
    string CompanyName,
    int JobId,
    DateTime AppliedDate,
    string Status,
    string UserId
);