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
        public int UniversityId { get; set; }
        public University University { get; set; }
        public int TotalActivities { get; set; }
        public int TotalMaterials { get; set; }
        public ICollection<WorkshopMaterial> Materials { get; set; }
        public ICollection<WorkshopActivity> Activities { get; set; }
        
    }
}
