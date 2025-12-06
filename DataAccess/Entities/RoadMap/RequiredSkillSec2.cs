using System;
using System.Collections.Generic;

namespace DataAccess.Entities.RoadMap
{
    public class RequiredSkillSec2
    {
        public int Id { get; set; }
        public string SkillName { get; set; }

        public string Level { get; set; } 

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }
        public int Points { get; set; }


        public int RoadmapId { get; set; }
        public virtual RoadmapSec1 Roadmap { get; set; }
    }
}
