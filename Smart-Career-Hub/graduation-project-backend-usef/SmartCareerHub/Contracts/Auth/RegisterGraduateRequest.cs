using Microsoft.AspNetCore.Http;
using System;

namespace SmartCareerHub.Contracts.Auth
{
    public record RegisterGraduateRequest(
        // Auth
        string Email,
        string Password,
        string FirstName,
        string LastName,

        // Academic
        string University,
        string Degree,
        string Major,
        int GraduationYear,

        // Experience
        int YearsOfExperience,
        string? ExperienceSummary,

        // Social
        string? LinkedIn,
        string? GitHub,
        string? Portfolio,

        // Location
        string City,
        string Country,

        // Media
        IFormFile? ProfileImage
    );
}
