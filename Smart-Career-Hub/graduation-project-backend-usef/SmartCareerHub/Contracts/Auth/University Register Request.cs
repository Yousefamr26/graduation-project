public record UniversityRegisterRequest(
    IFormFile? OrganizationLogo,   // للـ upload
    string Name,                   // Organization Name
    string Email,                  // Official Email
    string Password,
    string ConfirmPassword,
    string PhoneNumber,
    string Country,                // Location
    string City                    // City/State
);