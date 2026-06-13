namespace SmartCareerHub.Contracts.Auth
{
    public record CompanyResponse(
        string Id,
        string Email,
        string FirstName,
        string LastName,
        string OrganizationName,
        string? OrganizationLogoUrl, 
        string Country,
        string City,
        bool IsActive,
        bool IsEmailVerified,
        DateTime CreatedAt
    );
}
