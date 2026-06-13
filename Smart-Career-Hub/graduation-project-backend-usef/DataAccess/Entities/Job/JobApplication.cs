using DataAccess.Entities.Users;
using DataAccess.Entities.Job;
using DataAccess.Entities.Interview;
using System;

namespace DataAccess.Entities.Job
{
    public enum ApplicationStatus
    {
        Applied,
        UnderReview,
        InterviewScheduled,
        OfferReceived,
        Rejected
    }

    public class JobApplication
    {
        public int Id { get; set; }

        // FK User
        public string UserId { get; set; }
        public ApplicationUser User { get; set; }

        // FK Job
        public int JobId { get; set; }
        public Job Job { get; set; }

        // Status as string
        public ApplicationStatus Status { get; set; } = ApplicationStatus.Applied;

        // Dates
        public DateTime AppliedAt { get; set; } = DateTime.UtcNow;
        public DateTime LastUpdatedAt { get; set; } = DateTime.UtcNow;

        // Optional Interview link
        public int? InterviewId { get; set; }
        public InterviewSchedule Interview { get; set; }
    }
}
