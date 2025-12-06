namespace SmartCareerHub.Contracts.Company.Jobs
{
    public record JobRequest(
       string Title,
       string Description,
       string RequiredSkills,
       string ExperienceLevel,  
       string JobType,          
       string Location,
       string SalaryRange,
       IFormFile? CompanyLogo

        );


}
