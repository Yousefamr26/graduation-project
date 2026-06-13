using DataAccess.Entities.Interview;
using Mapster;

namespace Business_Logic.Mapping
{
    public class InterviewMappingConfig : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {

            config.NewConfig<InterviewRequest, InterviewSchedule>()
                .Map(dest => dest.StudentName, src => src.StudentName)
                .Map(dest => dest.RoadmapId, src => src.RoadmapId)

                .Map(dest => dest.ScheduledAt, src => src.ScheduledDate)
                .Map(dest => dest.InterviewType, src => src.InterviewType)
                .Map(dest => dest.InterviewerName, src => src.InterviewerName)
                .Map(dest => dest.AdditionalNotes, src => src.AdditionalNotes)
                .Ignore(dest => dest.Id)
                .Ignore(dest => dest.Status)
                .Ignore(dest => dest.CreatedAt)
                .Ignore(dest => dest.Roadmap)
                .PreserveReference(true);


            config.NewConfig<InterviewSchedule, InterviewResponse>()
     .ConstructUsing(src => new InterviewResponse(
         src.Id,                                       // Id
         src.StudentName,                              // StudentName
         src.RoadmapId,                                // RoadmapId
         src.Roadmap != null ? src.Roadmap.Title : string.Empty, // RoadmapName
         src.ScheduledAt,                              // Date
         src.InterviewType,                            // InterviewType
         src.MeetingLink,                              // MeetingLink
         src.Location,                                 // Location
         src.InterviewerName,                          // InterviewerName
         src.AdditionalNotes,                          // AdditionalNotes
         src.Status,                                   // Status
         src.Result,                                   // Result
         src.Feedback,                                 // Feedback
         src.IsAIPick,                                 // IsAIPick
         src.Roadmap != null && src.Roadmap.Company != null ? src.Roadmap.Company.OrganizationName : string.Empty, // CompanyName
         src.CreatedAt                                 // CreatedAt
     ));
        }
    }
}