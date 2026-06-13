using System.ComponentModel.DataAnnotations;
namespace DataAccess.Entities.Events
{
    public class Event
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string? BannerUrl { get; set; }
        public string EventType { get; set; }
        public string Mode { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan? EndTime { get; set; }
        public int MinimumRequiredPoints { get; set; } = 0;
        public bool CompletedRoadmap { get; set; }
        public bool Completed50PercentCourses { get; set; }
        public bool HighCommunicationSkills { get; set; }
        public bool HighTechnicalSkills { get; set; }
        public bool Top30PercentProgress { get; set; }
        public bool InviteOnlyEligibleStudents { get; set; }
        public int EligibleStudentsCount { get; set; } = 0;
        public int ExpectedAttendees { get; set; } = 0;
        public int CurrentRegistrations { get; set; } = 0;
        public int MaxCapacity { get; set; }
        public bool AllowWaitingList { get; set; }
        public bool SendAutoEmailToEligibleStudents { get; set; }
        public int PointsForAttendance { get; set; } = 0;
        public int PointsForFullParticipation { get; set; } = 0;
        public bool IsPublished { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}