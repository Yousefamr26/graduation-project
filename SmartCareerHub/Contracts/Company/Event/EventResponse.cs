namespace SmartCareerHub.Contracts.Company.Event
{
    public record EventResponse(
      int Id,
      string Title,
      string Description,
      string? BannerUrl,
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
      int EligibleStudentsCount,
      int ExpectedAttendees,
      int CurrentRegistrations,
      int MaxCapacity,
      bool AllowWaitingList,
      bool SendAutoEmailToEligibleStudents,
      int PointsForAttendance,
      int PointsForFullParticipation,
      bool IsPublished,
      DateTime CreatedAt,
      DateTime UpdatedAt
        );


}
