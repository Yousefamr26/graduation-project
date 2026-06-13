public record TrainingCenterRegisterResponse(
    int Id,
    string Name,
    string Email,
    string? PhoneNumber,
    string? Country,
    string? City,
    string? OrganizationLogoUrl,
    DateTime CreatedAt
);