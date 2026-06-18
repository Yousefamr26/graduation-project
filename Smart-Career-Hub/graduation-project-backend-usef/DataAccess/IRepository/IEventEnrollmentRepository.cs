using DataAccess.Entities.Events;

namespace DataAccess.IRepository
{
    public interface IEventEnrollmentRepository
    {
        Task<bool> IsUserAlreadyEnrolledAsync(
            int eventId,
            string userId,
            CancellationToken cancellationToken = default);

        Task<EventEnrollment?> GetByEventAndUserAsync(
            int eventId,
            string userId,
            CancellationToken cancellationToken = default);

        Task AddAsync(
            EventEnrollment enrollment,
            CancellationToken cancellationToken = default);

        Task<List<EventEnrollment>> GetUserEnrollmentsAsync(string userId);
        void Remove(EventEnrollment enrollment);
        Task<List<EventEnrollment>> GetEventEnrollmentsAsync(int eventId); 

    }
}
