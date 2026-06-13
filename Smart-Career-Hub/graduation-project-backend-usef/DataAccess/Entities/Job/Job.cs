using DataAccess.Entities.Users;
using System;
using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace DataAccess.Entities.Job
{
    public class Job
    {
        public int Id { get; set; }

        public string Title { get; set; }
        public string Description { get; set; }
        public string RequiredSkills { get; set; }
        public string ExperienceLevel { get; set; }
        public string JobType { get; set; }
        public string Location { get; set; }
        public string SalaryRange { get; set; }
        public string? CompanyLogo { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // EF Core Navigation Property for JobApplications
        [JsonIgnore]
        public ICollection<JobApplication> JobApplications { get; set; } = new HashSet<JobApplication>();
        public string CompanyUserId { get; set; }  // FK → CompanyUser
        public virtual CompanyUser CompanyUser { get; set; }
    }
}
