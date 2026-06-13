namespace SmartCareerHub.Contracts.Company.Event
{
    public record EventRequest(
     string Title,
     string Description,
     IFormFile? Banner,
     string EventType,
     string Mode,
     DateTime StartDate,
     DateTime? EndDate,
     TimeSpan StartTime,
     TimeSpan? EndTime,
     int MinimumRequiredPoints,
     bool CompletedRoadmap,
     bool Completed50PercentCourses,
     bool HighCommunicationSkills,
     bool HighTechnicalSkills,
     bool Top30PercentProgress,
     bool InviteOnlyEligibleStudents,
     int MaxCapacity,
     bool AllowWaitingList,
     bool SendAutoEmailToEligibleStudents,
     int PointsForAttendance,
     int PointsForFullParticipation,
     bool IsPublished
        );


}
