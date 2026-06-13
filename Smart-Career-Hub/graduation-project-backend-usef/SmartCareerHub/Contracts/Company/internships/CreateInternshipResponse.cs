public record CreateInternshipResponse(
    int Id,
    string Title,
    InternshipStatus Status,
    InternshipType Type,
    bool IsPaid,
    int DurationInMonths,
    string Location,
    DateTime ApplicationDeadline,
    string CompanyName,
    DateTime CreatedAt
);
