using DataAccess.Entities.Job;

using Mapster;
using SmartCareerHub.Contracts.Company.Jobs;

namespace API.Configurations
{
    public static class JobMappingConfig
    {
        public static void RegisterMappings()
        {
           
            TypeAdapterConfig<Job, JobResponse>
                .NewConfig()
                .Map(dest => dest.Id, src => src.Id)
                .Map(dest => dest.Title, src => src.Title)
                .Map(dest => dest.Description, src => src.Description)
                .Map(dest => dest.RequiredSkills, src => src.RequiredSkills)
                .Map(dest => dest.ExperienceLevel, src => src.ExperienceLevel)
                .Map(dest => dest.JobType, src => src.JobType)
                .Map(dest => dest.Location, src => src.Location)
                .Map(dest => dest.SalaryRange, src => src.SalaryRange)
                .Map(dest => dest.CompanyLogo, src => src.CompanyLogo)
                .Map(dest => dest.CreatedAt, src => src.CreatedAt);

            
            TypeAdapterConfig<JobRequest, Job>
                .NewConfig()
                .Map(dest => dest.Title, src => src.Title)
                .Map(dest => dest.Description, src => src.Description)
                .Map(dest => dest.RequiredSkills, src => src.RequiredSkills)
                .Map(dest => dest.ExperienceLevel, src => src.ExperienceLevel)
                .Map(dest => dest.JobType, src => src.JobType)
                .Map(dest => dest.Location, src => src.Location)
                .Map(dest => dest.SalaryRange, src => src.SalaryRange)
                .Ignore(dest => dest.Id)
                .Ignore(dest => dest.CompanyLogo)  
                .Ignore(dest => dest.CreatedAt);
        }
    }
}