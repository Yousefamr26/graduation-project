using SmartCareerHub.Contracts.Events;
using SmartCareerHub.Contracts.Events.Enrollment;

namespace Business_Logic.IService
{
    public interface IEventEnrollmentService
    {
        Task<EventEnrollmentSimpleResponse> EnrollAsync(
            string userId,
            EventEnrollmentRequest request,
            CancellationToken cancellationToken = default);

        Task<bool> CancelEnrollmentAsync(
            string userId,
            int eventId,
            CancellationToken cancellationToken = default);

        Task<PagedResponse<MyEventResponse>> GetMyEventsAsync(
            string userId,
            QueryParameters query,
            CancellationToken cancellationToken = default);

        Task<PagedResponse<EventParticipantResponse>> GetParticipantsAsync(
            int eventId,
            QueryParameters query,
            CancellationToken cancellationToken = default);
    }
}