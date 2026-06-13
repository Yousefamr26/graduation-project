public record StudentResponse(
    string Id,
    string Email,
    string FirstName,
    string LastName,

    string Major,
    string Degree,
    string University,
    string GitHub,
    string LinkedIn,
    DateTime? ExpectedGraduation,
    string? ProfileImage,

    string City,
    string Country,

    bool IsActive,
    bool IsEmailVerified,
    DateTime CreatedAt
);
