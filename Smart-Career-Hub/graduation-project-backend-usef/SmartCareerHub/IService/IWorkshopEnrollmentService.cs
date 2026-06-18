using DataAccess.Abstractions;
using SmartCareerHub.Contracts.Workshops.Enrollment;

public interface IWorkshopEnrollmentService
{
    Task<Result<EnrollWorkshopResponse>> EnrollAsync(
        string userId,
        EnrollWorkshopRequest request);

    Task<Result<PagedResponse<EnrollWorkshopResponse>>> GetMyEnrollmentsAsync(
        string userId,
        QueryParameters query);

    Task<Result<PagedResponse<WorkshopParticipantResponse>>> GetWorkshopParticipantsAsync(
        int workshopId,
        QueryParameters query);

    Task<Result> CancelEnrollmentAsync(
        int workshopId,
        string userId);

    Task<Result<PagedResponse<WorkshopAvailableItem>>> GetAvailableWorkshopsAsync(
        string userId,
        QueryParameters query);

    Task<Result<WorkshopDetailsResponse>> GetWorkshopDetailsAsync(
        int workshopId,
        string userId);
}