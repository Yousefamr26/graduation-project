using DataAccess.Abstractions;
using DataAccess.Contexts;
using DataAccess.IRepository;
using Microsoft.EntityFrameworkCore;
using Business_Logic.Errors;
using DataAccess.Entities.Interview;

namespace DataAccess.Repository
{
    public class InterviewRepository : GenericRepository<InterviewSchedule>, IInterviewRepository
    {
        private readonly ApplicationDbContext _context;

        public InterviewRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;
        }

        public async Task<Result<InterviewSchedule>> GetByIdWithDetailsAsync(int id)
        {
            var interview = await _context.interviews
                .Include(i => i.Roadmap)
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
                .OrderByDescending(i => i.Date)
                .ToListAsync();

            return Result.Success<IEnumerable<InterviewSchedule>>(interviews);
        }

        public async Task<Result<IEnumerable<InterviewSchedule>>> GetByStatusAsync(string status)
        {
            var interviews = await _context.interviews
                .Include(i => i.Roadmap)
                .Where(i => i.Status == status)
                .OrderByDescending(i => i.Date)
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
            var today = DateTime.Today;
            var interviews = await _context.interviews
                .Include(i => i.Roadmap)
                .Where(i => i.Date.Date == today)
                .OrderBy(i => i.Time)
                .ToListAsync();

            return Result.Success<IEnumerable<InterviewSchedule>>(interviews);
        }

        public async Task<Result<IEnumerable<InterviewSchedule>>> SearchInterviewsAsync(string searchTerm)
        {
            if (string.IsNullOrWhiteSpace(searchTerm))
                return await GetAllWithDetailsAsync();

            var interviews = await _context.interviews
                .Include(i => i.Roadmap)
                .Where(i => i.StudentName.Contains(searchTerm) ||
                           i.InterviewerName.Contains(searchTerm) ||
                           i.Location.Contains(searchTerm) ||
                           (i.Roadmap != null && i.Roadmap.Title.Contains(searchTerm)))
                .OrderByDescending(i => i.CreatedAt)
                .ToListAsync();

            return Result.Success<IEnumerable<InterviewSchedule>>(interviews);
        }

        public async Task<Result<InterviewSchedule>> AddInterviewAsync(InterviewSchedule interview)
        {
            try
            {
                interview.CreatedAt = DateTime.UtcNow;
                interview.Status = "Scheduled";

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
            try
            {
                var existingInterview = await _context.interviews.FindAsync(interview.Id);

                if (existingInterview == null)
                    return Result.Failure(InterviewErrors.InterviewNotFound);

                existingInterview.StudentName = interview.StudentName;
                existingInterview.RoadmapId = interview.RoadmapId;
                existingInterview.CV = interview.CV;
                existingInterview.IsAIPick = interview.IsAIPick;
                existingInterview.Date = interview.Date;
                existingInterview.Time = interview.Time;
                existingInterview.InterviewType = interview.InterviewType;
                existingInterview.Location = interview.Location;
                existingInterview.InterviewerName = interview.InterviewerName;
                existingInterview.AdditionalNotes = interview.AdditionalNotes;

                _context.interviews.Update(existingInterview);
                await _context.SaveChangesAsync();

                return Result.Success();
            }
            catch
            {
                return Result.Failure(InterviewErrors.InterviewUpdateFailed);
            }
        }

        public async Task<Result> DeleteAsync(int id)
        {
            try
            {
                var interview = await _context.interviews.FindAsync(id);

                if (interview == null)
                    return Result.Failure(InterviewErrors.InterviewNotFound);

                _context.interviews.Remove(interview);
                await _context.SaveChangesAsync();

                return Result.Success();
            }
            catch
            {
                return Result.Failure(InterviewErrors.InterviewDeleteFailed);
            }
        }

        public async Task<Result> BulkDeleteAsync(List<int> ids)
        {
            try
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
            catch
            {
                return Result.Failure(InterviewErrors.InterviewDeleteFailed);
            }
        }

        public async Task<Result> UpdateStatusAsync(int id, string status)
        {
            try
            {
                var interview = await _context.interviews.FindAsync(id);

                if (interview == null)
                    return Result.Failure(InterviewErrors.InterviewNotFound);

                interview.Status = status;
                _context.interviews.Update(interview);
                await _context.SaveChangesAsync();

                return Result.Success();
            }
            catch
            {
                return Result.Failure(InterviewErrors.InterviewUpdateFailed);
            }
        }

        public async Task<Result> BulkUpdateStatusAsync(List<int> ids, string status)
        {
            try
            {
                if (ids == null || !ids.Any())
                    return Result.Failure(InterviewErrors.InterviewNoIdsProvided);

                var interviews = await _context.interviews
                    .Where(i => ids.Contains(i.Id))
                    .ToListAsync();

                if (!interviews.Any())
                    return Result.Failure(InterviewErrors.InterviewBulkNotFound);

                foreach (var interview in interviews)
                {
                    interview.Status = status;
                }

                _context.interviews.UpdateRange(interviews);
                await _context.SaveChangesAsync();

                return Result.Success();
            }
            catch
            {
                return Result.Failure(InterviewErrors.InterviewUpdateFailed);
            }
        }

        public async Task<Result<int>> GetTotalCountAsync()
        {
            var count = await _context.interviews.CountAsync();
            return Result.Success(count);
        }

        public async Task<Result<int>> GetTodayCountAsync()
        {
            var today = DateTime.Today;
            var count = await _context.interviews
                .CountAsync(i => i.Date.Date == today);
            return Result.Success(count);
        }

        public async Task<Result<List<InterviewSchedule>>> GetLatestInterviewsAsync(int count)
        {
            var interviews = await _context.interviews
                .Include(i => i.Roadmap)
                .OrderByDescending(i => i.CreatedAt)
                .Take(count)
                .ToListAsync();

            return Result.Success(interviews);
        }
    }
}