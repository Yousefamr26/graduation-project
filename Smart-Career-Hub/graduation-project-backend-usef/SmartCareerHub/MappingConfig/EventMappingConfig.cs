using Mapster;
using DataAccess.Entities.Events;
using SmartCareerHub.Contracts.Company.Event;

public static class EventMappingConfig
{
    public static void RegisterMappings()
    {
        TypeAdapterConfig<Event, EventResponse>
            .NewConfig()
            .Map(dest => dest.Id, src => src.Id)
            .Map(dest => dest.Title, src => src.Title)
            .Map(dest => dest.Description, src => src.Description)
            .Map(dest => dest.EventType, src => src.EventType.ToString())
            .Map(dest => dest.Mode, src => src.Mode.ToString())
            .Map(dest => dest.StartDate, src => src.StartDate)
            .Map(dest => dest.EndDate, src => src.EndDate)
            .Map(dest => dest.StartTime, src => src.StartTime.ToString())
             .Map(dest => dest.EndTime, src => src.EndTime != null ? src.EndTime.ToString() : null)
            .Map(dest => dest.MinimumRequiredPoints, src => src.MinimumRequiredPoints)
            .Map(dest => dest.CompletedRoadmap, src => src.CompletedRoadmap)
            .Map(dest => dest.Completed50PercentCourses, src => src.Completed50PercentCourses)
            .Map(dest => dest.HighCommunicationSkills, src => src.HighCommunicationSkills)
            .Map(dest => dest.HighTechnicalSkills, src => src.HighTechnicalSkills)
            .Map(dest => dest.Top30PercentProgress, src => src.Top30PercentProgress)
            .Map(dest => dest.InviteOnlyEligibleStudents, src => src.InviteOnlyEligibleStudents)
            .Map(dest => dest.MaxCapacity, src => src.MaxCapacity)
            .Map(dest => dest.AllowWaitingList, src => src.AllowWaitingList)
            .Map(dest => dest.SendAutoEmailToEligibleStudents, src => src.SendAutoEmailToEligibleStudents)
            .Map(dest => dest.PointsForAttendance, src => src.PointsForAttendance)
            .Map(dest => dest.PointsForFullParticipation, src => src.PointsForFullParticipation)
            .Map(dest => dest.IsPublished, src => src.IsPublished)
            .Map(dest => dest.BannerUrl, src => src.BannerUrl);
    }
}
