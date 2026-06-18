public record InternshipCardResponse(
    int Id,
    string Title,
    string CompanyName,
    string Location,
    InternshipType Type,
    bool IsPaid,
    int DurationInMonths,
    InternshipStatus Status,
    bool IsApplied
);
