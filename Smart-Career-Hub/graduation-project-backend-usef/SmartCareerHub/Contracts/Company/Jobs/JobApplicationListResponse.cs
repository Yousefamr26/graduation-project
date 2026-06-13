using DataAccess.Entities.Job;

namespace SmartCareerHub.Contracts.Company.Jobs
{
    public record JobApplicationListResponse(

     int ApplicationId,
    string JobTitle,
    string CompanyName,
    string? CompanyLogo,   
    ApplicationStatus Status,
    DateTime AppliedAt
);

}
