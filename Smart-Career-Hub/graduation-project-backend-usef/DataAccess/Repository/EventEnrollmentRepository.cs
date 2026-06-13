using DataAccess.Contexts;
using DataAccess.Entities.Events;
using DataAccess.IRepository;
using Microsoft.EntityFrameworkCore;

namespace DataAccess.Repository
{
    public class EventEnrollmentRepository : IEventEnrollmentRepository
    {
        private readonly ApplicationDbContext _context;

        public EventEnrollmentRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<bool> IsUserAlreadyEnrolledAsync(
            int eventId,
            string userId,
            CancellationToken cancellationToken = default)
        {
            return await _context.eventEnrollments
                .AnyAsync(e =>
                    e.EventId == eventId &&
                    e.UserId == userId,
                    cancellationToken);
        }

        public async Task<EventEnrollment?> GetByEventAndUserAsync(
            int eventId,
            string userId,
            CancellationToken cancellationToken = default)
        {
            return await _context.eventEnrollments
                .Include(e => e.Event)
                .FirstOrDefaultAsync(e =>
                    e.EventId == eventId &&
                    e.UserId == userId,
                    cancellationToken);
        }

        public async Task AddAsync(
            EventEnrollment enrollment,
            CancellationToken cancellationToken = default)
        {
            await _context.eventEnrollments
                .AddAsync(enrollment, cancellationToken);

            await _context.SaveChangesAsync(cancellationToken);
        }

        public async Task<List<EventEnrollment>> GetUserEnrollmentsAsync(string userId)
        {
            return await _context.eventEnrollments
                .Include(e => e.Event)
                .Where(e => e.UserId == userId)
                .OrderByDescending(e => e.EnrolledAt)
                .ToListAsync();
        }
        public async Task<List<EventEnrollment>> GetEventEnrollmentsAsync(int eventId)
        {
            return await _context.eventEnrollments.Include(e => e.Event)
                .Where(e => e.EventId == eventId)
                .Include(e => e.Event) // لو محتاج بيانات الحدث
                .ToListAsync();
        }

        public void Remove(EventEnrollment enrollment)
        {
            _context.eventEnrollments.Remove(enrollment);
        }
    }
}
