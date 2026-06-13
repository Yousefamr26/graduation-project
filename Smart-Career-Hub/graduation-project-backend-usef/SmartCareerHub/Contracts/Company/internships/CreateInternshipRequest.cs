public record CreateInternshipRequest(
    string Title,
    InternshipType Type,
    bool IsPaid,
    int MaxTrainees,
    int DurationInMonths,
    DateTime ApplicationDeadline,
    string Location,
    string Description,
    IReadOnlyList<string> RequiredSkills,
    IReadOnlyList<string> Requirements
);
