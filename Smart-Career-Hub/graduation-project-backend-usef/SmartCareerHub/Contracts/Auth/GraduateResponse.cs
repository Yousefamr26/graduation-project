using System;

namespace SmartCareerHub.Contracts.Auth
{
    public record GraduateResponse(
        string Id,
        string Email,
        string FirstName,
        string LastName,

        string Major,
        string Degree,
        string University,
        int GraduationYear,
        int YearsOfExperience,

        string? LinkedIn,
        string? GitHub,
        string? Portfolio,
        string? ProfileImage,

        string City,
        string Country,

        bool IsActive,
        bool IsEmailVerified,
        DateTime CreatedAt
    );
}
