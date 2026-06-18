using DataAccess.Entities.Interview;
using Mapster;
using SmartCareerHub.Contracts.Company.Interview;

namespace Business_Logic.Mapping
{
    public class InterviewMappingConfig : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
           
            config.NewConfig<InterviewRequest, InterviewSchedule>()
                .Map(dest => dest.StudentName, src => src.StudentName)
                .Map(dest => dest.RoadmapId, src => src.RoadmapId)
                .Map(dest => dest.CV, src => src.CV)
                .Map(dest => dest.IsAIPick, src => src.IsAIPick)
                .Map(dest => dest.Date, src => src.Date)
                .Map(dest => dest.Time, src => src.Time)
                .Map(dest => dest.InterviewType, src => src.InterviewType)
                .Map(dest => dest.Location, src => src.Location)
                .Map(dest => dest.InterviewerName, src => src.InterviewerName)
                .Map(dest => dest.AdditionalNotes, src => src.AdditionalNotes)
                .Ignore(dest => dest.Id)
                .Ignore(dest => dest.Status)
                .Ignore(dest => dest.CreatedAt)
                .Ignore(dest => dest.Roadmap)
                .PreserveReference(true);

           
            config.NewConfig<InterviewSchedule, InterviewResponse>()
                .ConstructUsing(src => new InterviewResponse(
                    src.Id,
                    src.StudentName,
                    src.RoadmapId,
                    src.Roadmap != null ? src.Roadmap.Title : string.Empty,
                    src.CV,
                    src.IsAIPick,  
                    src.Date,
                    src.Time,
                    src.InterviewType,
                    src.Location,
                    src.InterviewerName,
                    src.AdditionalNotes,
                    src.Status,
                    src.CreatedAt
                ));
        }
    }
}