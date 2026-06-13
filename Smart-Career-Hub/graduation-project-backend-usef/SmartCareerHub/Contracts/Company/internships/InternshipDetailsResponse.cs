public record InternshipDetailsResponse(
    int Id,
    string Title,
    string Description,
    IReadOnlyList<string> RequiredSkills,
    IReadOnlyList<string> Requirements,
    CompanyMiniResponse Company,
    int DurationInMonths,
    string Location,
    bool IsPaid,
    DateTime ApplicationDeadline,
    bool CanApply
);

public record CompanyMiniResponse(
    string Name,
    string? Logo
);
