public record PartnershipResponse(
    int Id,
    string CompanyName,
    string? IndustryField,
    string PartnershipType,
    string? ContactPersonName,
    string? ContactEmail,
    string Phone,
    string? Website,
    string? Location,
    string? PartnershipDetails,
    DateTime StartDate,
    string Status,
    int EventsHosted,
    int StudentsReached,
    DateTime CreatedAt,
    DateTime UpdatedAt,
    // ✅ من Navigation Property
    string? CompanyLogo
);