using DataAccess.Abstractions;
using DataAccess.Contexts;
using DataAccess.IRepository;
using Microsoft.EntityFrameworkCore;
using Business_Logic.Errors;
using DataAccess.Entities.Interview;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DataAccess.Repository
{
    public class InterviewRepository : GenericRepository<InterviewSchedule>, IInterviewRepository
    {
        private readonly ApplicationDbContext _context;

        public InterviewRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;
        }

        // =============================
        // Queries
        // =============================
        public async Task<Result<InterviewSchedule>> GetByIdWithDetailsAsync(int id)
        {
            var interview = await _context.interviews
                .Include(i => i.Roadmap)
                .Include(i => i.User)
                .FirstOrDefaultAsync(i => i.Id == id);

            if (interview == null)
                return Result.Failure<InterviewSchedule>(InterviewErrors.InterviewNotFound);

            return Result.Success(interview);
        }

        public async Task<Result<IEnumerable<InterviewSchedule>>> GetAllWithDetailsAsync()
        {
            var interviews = await _context.interviews
                .Include(i => i.Roadmap)
                .OrderByDescending(i => i.CreatedAt)
                .ToListAsync();

            return Result.Success<IEnumerable<InterviewSchedule>>(interviews);
        }

        public async Task<Result<IEnumerable<InterviewSchedule>>> GetByRoadmapAsync(int roadmapId)
        {
            var interviews = await _context.interviews
                .Include(i => i.Roadmap)
                .Where(i => i.RoadmapId == roadmapId)
                .OrderByDescending(i => i.ScheduledAt)
                .ToListAsync();

            return Result.Success<IEnumerable<InterviewSchedule>>(interviews);
        }

        public async Task<Result<IEnumerable<InterviewSchedule>>> GetByStatusAsync(InterviewStatus status)
        {
            var interviews = await _context.interviews
                .Include(i => i.Roadmap)
                .Where(i => i.Status == status)
                .OrderByDescending(i => i.ScheduledAt)
                .ToListAsync();

            return Result.Success<IEnumerable<InterviewSchedule>>(interviews);
        }

        public async Task<Result<IEnumerable<InterviewSchedule>>> GetAIRecommendedAsync()
        {
            var interviews = await _context.interviews
                .Include(i => i.Roadmap)
                .Where(i => i.IsAIPick)
                .OrderByDescending(i => i.CreatedAt)
                .ToListAsync();

            return Result.Success<IEnumerable<InterviewSchedule>>(interviews);
        }

        public async Task<Result<IEnumerable<InterviewSchedule>>> GetTodayInterviewsAsync()
        {
            var today = DateTime.UtcNow.Date;
            var interviews = await _context.interviews
                .Include(i => i.Roadmap)
                .Where(i => i.ScheduledAt.Date == today)
                .OrderBy(i => i.ScheduledAt)
                .ToListAsync();

            return Result.Success<IEnumerable<InterviewSchedule>>(interviews);
        }

        public async Task<Result<IEnumerable<InterviewSchedule>>> SearchInterviewsAsync(string searchTerm)
        {
            if (string.IsNullOrWhiteSpace(searchTerm))
                return await GetAllWithDetailsAsync();

            var interviews = await _context.interviews
                .Include(i => i.Roadmap)
                .Where(i =>
                    i.StudentName.Contains(searchTerm) ||
                    i.InterviewerName.Contains(searchTerm) ||
                    (i.Location != null && i.Location.Contains(searchTerm)) ||
                    (i.Roadmap != null && i.Roadmap.Title.Contains(searchTerm)))
                .OrderByDescending(i => i.CreatedAt)
                .ToListAsync();

            return Result.Success<IEnumerable<InterviewSchedule>>(interviews);
        }

        public async Task<Result<IEnumerable<InterviewSchedule>>> GetStudentInterviewsAsync(string userId)
        {
            var interviews = await _context.interviews
                .Include(i => i.Roadmap)
                .Include(i => i.User)
                .Where(i => i.UserId == userId)
                .OrderByDescending(i => i.ScheduledAt)
                .ToListAsync();

            return Result.Success<IEnumerable<InterviewSchedule>>(interviews);
        }

        public async Task<Result<int>> GetTotalCountAsync()
        {
            var count = await _context.interviews.CountAsync();
            return Result.Success(count);
        }

        public async Task<Result<int>> GetTodayCountAsync()
        {
            var today = DateTime.UtcNow.Date;
            var count = await _context.interviews.CountAsync(i => i.ScheduledAt.Date == today);
            return Result.Success(count);
        }

        public async Task<Result<IEnumerable<InterviewSchedule>>> GetLatestInterviewsAsync(int count)
        {
            var interviews = await _context.interviews
                .Include(i => i.Roadmap)
                .OrderByDescending(i => i.CreatedAt)
                .Take(count)
                .ToListAsync();

            return Result.Success<IEnumerable<InterviewSchedule>>(interviews);
        }

        // =============================
        // Commands
        // =============================
        public async Task<Result<InterviewSchedule>> AddInterviewAsync(InterviewSchedule interview)
        {
            try
            {
                interview.CreatedAt = DateTime.UtcNow;
                interview.Status = InterviewStatus.Pending;

                await _context.interviews.AddAsync(interview);
                await _context.SaveChangesAsync();

                return Result.Success(interview);
            }
            catch
            {
                return Result.Failure<InterviewSchedule>(InterviewErrors.InterviewCreationFailed);
            }
        }

        public async Task<Result> UpdateAsync(InterviewSchedule interview)
        {
            var existing = await _context.interviews.FindAsync(interview.Id);
            if (existing == null)
                return Result.Failure(InterviewErrors.InterviewNotFound);

            existing.StudentName = interview.StudentName;
            existing.RoadmapId = interview.RoadmapId;
            existing.CV = interview.CV;
            existing.IsAIPick = interview.IsAIPick;
            existing.ScheduledAt = interview.ScheduledAt;
            existing.InterviewType = interview.InterviewType;
            existing.MeetingLink = interview.MeetingLink;
            existing.Location = interview.Location;
            existing.InterviewerName = interview.InterviewerName;
            existing.AdditionalNotes = interview.AdditionalNotes;

            await _context.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<Result> DeleteAsync(int id)
        {
            var interview = await _context.interviews.FindAsync(id);
            if (interview == null)
                return Result.Failure(InterviewErrors.InterviewNotFound);

            _context.interviews.Remove(interview);
            await _context.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<Result> BulkDeleteAsync(List<int> ids)
        {
            if (ids == null || !ids.Any())
                return Result.Failure(InterviewErrors.InterviewNoIdsProvided);

            var interviews = await _context.interviews
                .Where(i => ids.Contains(i.Id))
                .ToListAsync();

            if (!interviews.Any())
                return Result.Failure(InterviewErrors.InterviewBulkNotFound);

            _context.interviews.RemoveRange(interviews);
            await _context.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<Result> UpdateStatusAsync(int id, InterviewStatus status)
        {
            var interview = await _context.interviews.FindAsync(id);
            if (interview == null)
                return Result.Failure(InterviewErrors.InterviewNotFound);

            interview.Status = status;
            await _context.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<Result> BulkUpdateStatusAsync(List<int> ids, InterviewStatus status)
        {
            if (ids == null || !ids.Any())
                return Result.Failure(InterviewErrors.InterviewNoIdsProvided);

            var interviews = await _context.interviews
                .Where(i => ids.Contains(i.Id))
                .ToListAsync();

            if (!interviews.Any())
                return Result.Failure(InterviewErrors.InterviewBulkNotFound);

            interviews.ForEach(i => i.Status = status);
            await _context.SaveChangesAsync();
            return Result.Success();
        }

        // =============================
        // Student / Graduate specific
        // =============================
        public async Task<Result<IEnumerable<InterviewSchedule>>> GetUpcomingInterviewsAsync(string userId)
        {
            var now = DateTime.UtcNow;
            var interviews = await _context.interviews
                .Include(i => i.Roadmap)
                .Include(i => i.User)
                .Where(i => i.UserId == userId && i.ScheduledAt > now)
                .OrderBy(i => i.ScheduledAt)
                .ToListAsync();

            return Result.Success<IEnumerable<InterviewSchedule>>(interviews);
        }

        public async Task<Result<IEnumerable<InterviewSchedule>>> GetPastInterviewsAsync(string userId)
        {
            var now = DateTime.UtcNow;
            var interviews = await _context.interviews
                .Include(i => i.Roadmap)
                .Include(i => i.User)
                .Where(i => i.UserId == userId && i.ScheduledAt <= now)
                .OrderByDescending(i => i.ScheduledAt)
                .ToListAsync();

            return Result.Success<IEnumerable<InterviewSchedule>>(interviews);
        }

        public async Task<Result<InterviewSchedule>> GetByIdForUserAsync(int id, string userId)
        {
            var interview = await _context.interviews
                .Include(i => i.Roadmap)
                .Include(i => i.User)
                .FirstOrDefaultAsync(i => i.Id == id && i.UserId == userId);

            if (interview == null)
                return Result.Failure<InterviewSchedule>(InterviewErrors.InterviewNotFound);

            return Result.Success(interview);
        }

        public async Task<Result> AcceptInterviewAsync(int id, string userId)
        {
            var interview = await _context.interviews
                .FirstOrDefaultAsync(i => i.Id == id && i.UserId == userId);

            if (interview == null)
                return Result.Failure(InterviewErrors.InterviewNotFound);

            interview.Status = InterviewStatus.Accepted;
            await _context.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<Result> DeclineInterviewAsync(int id, string userId)
        {
            var interview = await _context.interviews
                .FirstOrDefaultAsync(i => i.Id == id && i.UserId == userId);

            if (interview == null)
                return Result.Failure(InterviewErrors.InterviewNotFound);

            interview.Status = InterviewStatus.Declined;
            await _context.SaveChangesAsync();
            return Result.Success();
        }
    }
}