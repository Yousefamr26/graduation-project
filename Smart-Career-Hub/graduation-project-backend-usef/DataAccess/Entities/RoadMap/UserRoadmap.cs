using System;
using System.Collections.Generic;
using DataAccess.Entities.RoadMap;

namespace DataAccess.Entities.Users
{
    public class UserRoadmap
    {
        public int Id { get; set; }

        // ---- العلاقة بالطالب ----
        public string UserId { get; set; }
        public ApplicationUser User { get; set; }

        // ---- العلاقة بالرود ماب ----
        public int RoadmapId { get; set; }       // FK → RoadmapSec1
        public virtual RoadmapSec1 Roadmap { get; set; }

        // ---- تتبع التقدم العام ----
        public int ProgressPercent { get; set; } = 0;
        public string Status { get; set; } = "In Progress"; // أو "Completed"
        public DateTime JoinedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }
        public DateTime? CompletedAt { get; set; } 


        // ---- تقدم كل مادة / مشروع / كويز ----
        public virtual ICollection<UserProgress> ProgressItems { get; set; } = new List<UserProgress>();
        public DateTime EnrolledAt { get; set; }
    }
}
