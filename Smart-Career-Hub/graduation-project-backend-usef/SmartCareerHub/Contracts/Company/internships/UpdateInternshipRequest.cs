public record UpdateInternshipRequest(
    int Id,
    string Title,
    string Description,
    InternshipType Type,
    InternshipStatus Status,
    bool IsPaid,
    int MaxTrainees,
    int DurationInMonths,
    string Location,
    DateTime ApplicationDeadline
);