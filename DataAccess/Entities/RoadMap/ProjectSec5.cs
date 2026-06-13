using System;

namespace DataAccess.Entities.RoadMap
{
    public class ProjectSec5
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }

        public string Difficulty { get; set; } 

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }
        public int Points { get; set; }

        public int RoadmapId { get; set; }

        public virtual RoadmapSec1 Roadmap { get; set; }
    }
}
