using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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
        public DateTime CreatedAt { get; set; }
       
    }
}
