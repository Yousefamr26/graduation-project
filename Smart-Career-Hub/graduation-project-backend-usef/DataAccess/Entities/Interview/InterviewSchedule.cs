using DataAccess.Entities.RoadMap;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataAccess.Entities.Interview
{
    public class InterviewSchedule
    {
        public int Id { get; set; }

        public string StudentName { get; set; }
        public string? CompanyName { get; set; }

        public string UserId { get; set; }
        public ApplicationUser User { get; set; }

        public int RoadmapId { get; set; }
        public RoadmapSec1 Roadmap { get; set; }

        public string? CV { get; set; }
        public bool IsAIPick { get; set; }

        // بدل Date + Time نخليها واحدة
        public DateTime ScheduledAt { get; set; }

        public string InterviewType { get; set; }  // Online / Onsite

        public string? MeetingLink { get; set; }   // لو Online
        public string? Location { get; set; }      // لو Onsite

        public string InterviewerName { get; set; }

        public string? AdditionalNotes { get; set; }

        // Enum بدل string
        public InterviewStatus Status { get; set; } = InterviewStatus.Pending;

        public InterviewResult Result { get; set; } = InterviewResult.None;

        public string? Feedback { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
