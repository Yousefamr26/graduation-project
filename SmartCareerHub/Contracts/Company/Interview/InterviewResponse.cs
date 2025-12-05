namespace SmartCareerHub.Contracts.Company.Interview
{
    public record InterviewResponse(
        int Id,
        string StudentName,
        int RoadmapId,
        string RoadmapName,  
        string? CV,
        bool IsAIPick,
        DateTime Date,
        TimeSpan Time,
        string InterviewType,
        string Location,
        string InterviewerName,
        string? AdditionalNotes,
        string Status,
        DateTime CreatedAt
        );


}
