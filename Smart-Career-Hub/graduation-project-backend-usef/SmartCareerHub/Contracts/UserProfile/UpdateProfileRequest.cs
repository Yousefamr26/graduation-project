public class UpdateProfileRequest
{
    public string? PhoneNumber { get; set; }
    public string? Country { get; set; }
    public string? City { get; set; }
    public string? GitHub { get; set; }
    public string? LinkedIn { get; set; }
    public IFormFile? ProfileImage { get; set; }
    // Student only
    public string? Major { get; set; }
    public string? University { get; set; }
    public string? Degree { get; set; }
    public DateTime? ExpectedGraduation { get; set; }
    // Graduate only
    public int? GraduationYear { get; set; }
    public int? YearsOfExperience { get; set; }
    public string? ExperienceSummary { get; set; }
}