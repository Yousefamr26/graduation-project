using System;

namespace DataAccess.Entities.Workshop
{
    public class WorkshopEnrollment
    {
        public string Id { get; set; }

        public int WorkshopId { get; set; }
        public string UserId { get; set; } // Student OR Graduate

        public DateTime RegisteredAt { get; set; }

        public bool CvUploaded { get; set; }
        public bool RoadmapCompleted { get; set; }

        public WorkshopSec1 Workshop { get; set; }
    }
}
