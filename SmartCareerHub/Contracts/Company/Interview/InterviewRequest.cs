namespace SmartCareerHub.Contracts.Company.Interview
{
    public record InterviewRequest(
       string StudentName,
       int RoadmapId,
       string? CV,
       bool IsAIPick,
       DateTime Date,
       TimeSpan Time,
       string InterviewType,  
       string Location,
       string InterviewerName,
       string? AdditionalNotes
   );
}
