namespace SmartCareerHub.Contracts.Workshops.Enrollment
{
    public record EnrollWorkshopRequest(
        int WorkshopId,
        bool CvUploaded = false,
    bool RoadmapCompleted = false
    );
}
