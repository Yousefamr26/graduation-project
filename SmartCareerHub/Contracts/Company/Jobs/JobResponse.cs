namespace SmartCareerHub.Contracts.Company.Jobs
{
    public record JobResponse(
      int Id,
      string Title,
      string Description,
      string RequiredSkills,
      string ExperienceLevel,
      string JobType,
      string Location,
      string SalaryRange,
      string? CompanyLogo,
      DateTime CreatedAt
        );


}
