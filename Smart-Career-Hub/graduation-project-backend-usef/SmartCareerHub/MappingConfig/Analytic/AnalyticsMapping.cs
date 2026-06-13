using DataAccess.Entities.Events;
using DataAccess.Entities.Interview;
using DataAccess.Entities.Job;
using DataAccess.Entities.RoadMap;
using DataAccess.Entities.Workshop;
using Mapster;
using SmartCareerHub.Contracts.Company.WorkShops;

public static class AnalyticsMapping
{
    public static void RegisterMappings()
    {
        TypeAdapterConfig<int, EventAnalyticsResponse>
            .NewConfig()
            .Map(dest => dest.TotalParticipants, src => src)
            .IgnoreNonMapped(true); 

        TypeAdapterConfig<int, WorkshopAnalyticsResponse>
            .NewConfig()
            .Map(dest => dest.TotalParticipants, src => src)
            .IgnoreNonMapped(true); 

        TypeAdapterConfig<int, RoadmapAnalyticsResponse>
            .NewConfig()
            .Map(dest => dest.TotalRoadmaps, src => src)
            .IgnoreNonMapped(true); 

        TypeAdapterConfig<Dictionary<string, int>, JobAnalyticsResponse>
            .NewConfig()
            .Map(dest => dest.ByTypeAndLevel, src => src);

        TypeAdapterConfig<(int Completed, int Scheduled), InterviewAnalyticsResponse>
            .NewConfig()
            .Map(dest => dest.CompletedCount, src => src.Completed)
            .Map(dest => dest.ScheduledCount, src => src.Scheduled)
            .IgnoreNonMapped(true); 
    }
}
