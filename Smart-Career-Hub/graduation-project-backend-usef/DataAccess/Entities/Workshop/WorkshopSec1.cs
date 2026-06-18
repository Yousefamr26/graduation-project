using DataAccess.Entities.User;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataAccess.Entities.Workshop
{
    public class WorkshopSec1
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string? BannerUrl { get; set; }
        public string Location { get; set; }
        public int MaxCapacity { get; set; }
        public string WorkshopType { get; set; }
        public int TotalPoints { get; set; }
        public bool RequireCV { get; set; }
        public bool RequireRoadmapCompletion { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public bool IsPublished { get; set; } = false;

        // HostType
        public string HostType { get; set; } // "University" or "Company"

        // University fields (nullable)
        public int? UniversityId { get; set; }
        public University? University { get; set; }

        // Company fields (nullable) - التعديل هنا
        public string? CompanyId { get; set; } // ✅ غيرناه من int? لـ string?
        public CompanyUser? Company { get; set; }

        // Date/Time fields
        public DateTime WorkshopDate { get; set; }
        public TimeSpan WorkshopTime { get; set; }
        public string Duration { get; set; }

        public int TotalActivities { get; set; }
        public int TotalMaterials { get; set; }
        public ICollection<WorkshopMaterial> Materials { get; set; }
        public ICollection<WorkshopActivity> Activities { get; set; }
        public ICollection<WorkshopEnrollment> Enrollments { get; set; }
    }
}