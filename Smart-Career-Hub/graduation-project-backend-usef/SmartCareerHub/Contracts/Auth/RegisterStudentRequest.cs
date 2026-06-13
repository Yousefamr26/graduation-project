public record RegisterStudentRequest(
    string Email,
    string Password,
    string FirstName,
    string LastName,
    string University,
    string Faculty,
    string Major,
    string Degree,
    DateTime ExpectedGraduation,
    string? LinkedIn,
    string? GitHub,
    string? Portfolio,
    string City,
    string Country,
    IFormFile? ProfileImage
);