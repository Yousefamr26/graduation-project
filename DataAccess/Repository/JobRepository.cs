using Business_Logic.Errors;
using DataAccess.Abstractions;
using DataAccess.Contexts;
using DataAccess.Entities.Job;
using DataAccess.IRepository;
using Microsoft.EntityFrameworkCore;

namespace DataAccess.Repository
{
    public class JobRepository : GenericRepository<Job>, IJobRepository
    {
        private readonly ApplicationDbContext _context;

        public JobRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;
        }

        public async Task<Result<Job>> GetByIdAsync(int id)
        {
            var job = await _context.jobs.FindAsync(id);
            if (job == null)
                return Result.Failure<Job>(JobErrors.JobNotFound);
            return Result.Success(job);
        }

        public async Task<Result<IEnumerable<Job>>> GetAllAsync()
        {
            var jobs = await _context.jobs.OrderByDescending(j => j.CreatedAt).ToListAsync();
            return Result.Success<IEnumerable<Job>>(jobs);
        }

        public async Task<Result<IEnumerable<Job>>> SearchJobsAsync(string searchTerm)
        {
            if (string.IsNullOrWhiteSpace(searchTerm))
                return await GetAllAsync();

            var jobs = await _context.jobs
                .Where(j => j.Title.Contains(searchTerm) ||
                           j.Description.Contains(searchTerm) ||
                           j.RequiredSkills.Contains(searchTerm) ||
                           j.Location.Contains(searchTerm))
                .OrderByDescending(j => j.CreatedAt)
                .ToListAsync();

            return Result.Success<IEnumerable<Job>>(jobs);
        }

        public async Task<Result<IEnumerable<Job>>> GetJobsByTypeAsync(string jobType)
        {
            var jobs = await _context.jobs
                .Where(j => j.JobType == jobType)
                .OrderByDescending(j => j.CreatedAt)
                .ToListAsync();
            return Result.Success<IEnumerable<Job>>(jobs);
        }

        public async Task<Result<IEnumerable<Job>>> GetJobsByExperienceLevelAsync(string experienceLevel)
        {
            var jobs = await _context.jobs
                .Where(j => j.ExperienceLevel == experienceLevel)
                .OrderByDescending(j => j.CreatedAt)
                .ToListAsync();
            return Result.Success<IEnumerable<Job>>(jobs);
        }

        public async Task<Result<IEnumerable<Job>>> GetJobsByLocationAsync(string location)
        {
            var jobs = await _context.jobs
                .Where(j => j.Location.Contains(location))
                .OrderByDescending(j => j.CreatedAt)
                .ToListAsync();
            return Result.Success<IEnumerable<Job>>(jobs);
        }

        public async Task<Result<Job>> AddJobAsync(Job job)
        {
            try
            {
                job.CreatedAt = DateTime.UtcNow;
                await _context.jobs.AddAsync(job);
                await _context.SaveChangesAsync();
                return Result.Success(job);
            }
            catch
            {
                return Result.Failure<Job>(JobErrors.JobCreationFailed);
            }
        }

        public async Task<Result> UpdateAsync(Job job)
        {
            try
            {
                var existingJob = await _context.jobs.FindAsync(job.Id);
                if (existingJob == null)
                    return Result.Failure(JobErrors.JobNotFound);

                existingJob.Title = job.Title;
                existingJob.Description = job.Description;
                existingJob.RequiredSkills = job.RequiredSkills;
                existingJob.ExperienceLevel = job.ExperienceLevel;
                existingJob.JobType = job.JobType;
                existingJob.Location = job.Location;
                existingJob.SalaryRange = job.SalaryRange;
                existingJob.CompanyLogo = job.CompanyLogo;

                _context.jobs.Update(existingJob);
                await _context.SaveChangesAsync();
                return Result.Success();
            }
            catch
            {
                return Result.Failure(JobErrors.JobUpdateFailed);
            }
        }

        public async Task<Result> DeleteAsync(int id)
        {
            try
            {
                var job = await _context.jobs.FindAsync(id);
                if (job == null)
                    return Result.Failure(JobErrors.JobNotFound);

                _context.jobs.Remove(job);
                await _context.SaveChangesAsync();
                return Result.Success();
            }
            catch
            {
                return Result.Failure(JobErrors.JobDeleteFailed);
            }
        }

        public async Task<Result> BulkDeleteAsync(List<int> ids)
        {
            try
            {
                if (ids == null || !ids.Any())
                    return Result.Failure(JobErrors.JobNoIdsProvided);

                var jobs = await _context.jobs.Where(j => ids.Contains(j.Id)).ToListAsync();
                if (!jobs.Any())
                    return Result.Failure(JobErrors.JobBulkNotFound);

                _context.jobs.RemoveRange(jobs);
                await _context.SaveChangesAsync();
                return Result.Success();
            }
            catch
            {
                return Result.Failure(JobErrors.JobDeleteFailed);
            }
        }

        public async Task<bool> IsTitleExistsAsync(string title, int? excludeId = null)
        {
            return await _context.jobs
                .AnyAsync(j => j.Title == title && (!excludeId.HasValue || j.Id != excludeId.Value));
        }

        public async Task<Result<List<Job>>> GetLatestJobsAsync(int count)
        {
            var jobs = await _context.jobs
                .OrderByDescending(j => j.CreatedAt)
                .Take(count)
                .ToListAsync();
            return Result.Success(jobs);
        }

        public async Task<Result<int>> GetTotalJobsCountAsync()
        {
            var count = await _context.jobs.CountAsync();
            return Result.Success(count);
        }
    }
}