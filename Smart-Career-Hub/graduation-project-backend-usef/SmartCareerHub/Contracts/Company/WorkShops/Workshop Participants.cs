namespace SmartCareerHub.Contracts.Workshops.Enrollment
{
    public record WorkshopParticipantResponse(
        string UserId,
        string UserName,
        bool CvUploaded,
        bool RoadmapCompleted,
        DateTime RegisteredAt
    );
}
