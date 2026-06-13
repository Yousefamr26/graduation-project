using DataAccess.Contexts;
using DataAccess.Entities.Job;
using DataAccess.IRepository;
using DataAccess.Abstractions;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DataAccess.Repository
{
    public class JobApplicationRepository : GenericRepository<JobApplication>, IJobApplicationRepository
    {
        private readonly ApplicationDbContext _context;

        public JobApplicationRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;
        }

        public async Task<Result<JobApplication>> GetByIdWithDetailsAsync(int id , CancellationToken cancellationToken = default)
        {
            var application = await _context.jobApplications
                .Include(j => j.Job)
                .Include(j => j.User)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (application == null)
                return Result.Failure<JobApplication>(new Error("NotFound", "Application not found"));

            return Result.Success(application);
        } 

        public async Task<Result<IEnumerable<JobApplication>>> GetAllWithDetailsAsync(CancellationToken cancellationToken = default)
        {
            var applications = await _context.jobApplications
                .Include(j => j.Job)
                .Include(j => j.User)
                .OrderByDescending(a => a.AppliedAt)
                .ToListAsync();

            return Result.Success(applications.AsEnumerable());
        }

        public async Task<Result<IEnumerable<JobApplication>>> GetByUserIdAsync(string userId , CancellationToken cancellationToken = default)
        {
            var applications = await _context.jobApplications
                .AsNoTracking() // ✅ مهم جداً
                .Where(a => a.UserId == userId)
                .Include(a => a.Job)
                    .ThenInclude(j => j.CompanyUser)
                .OrderByDescending(a => a.AppliedAt)
                .ToListAsync();

            // ✅ امسح الـ JobApplications يدوياً
            foreach (var app in applications)
            {
                if (app.Job != null)
                {
                    app.Job.JobApplications = new List<JobApplication>(); // قائمة فاضية بدل null
                }
            }

            return Result.Success(applications.AsEnumerable());
        }

        public async Task<bool> ExistsAsync(string userId, int jobId )
        {
            return await _context.jobApplications
                .AnyAsync(a => a.UserId == userId && a.JobId == jobId);
        }

        public async Task<int> CountAsync(string userId, ApplicationStatus? status = null , CancellationToken cancellationToken = default)
        {
            var query = _context.jobApplications.AsQueryable();
            query = query.Where(a => a.UserId == userId);
            if (status.HasValue)
                query = query.Where(a => a.Status == status.Value);

            return await query.CountAsync();
        }

        public async Task<Result<JobApplication>> AddApplicationAsync(JobApplication application, CancellationToken cancellationToken = default)
        {
            await _context.jobApplications.AddAsync(application);
            await _context.SaveChangesAsync();
            return Result.Success(application);
        }

        public async Task<Result> UpdateApplicationAsync(JobApplication application , CancellationToken cancellationToken = default)
        {
            _context.jobApplications.Update(application);
            await _context.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<Result> DeleteApplicationAsync(int id )
        {
            var application = await _context.jobApplications.FindAsync(id);
            if (application == null)
                return Result.Failure(new Error("NotFound", "Application not found"));

            _context.jobApplications.Remove(application);
            await _context.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<Result> UpdateStatusAsync(int id, ApplicationStatus status, CancellationToken cancellationToken = default)
        {
            var application = await _context.jobApplications.FindAsync(id);
            if (application == null)
                return Result.Failure(new Error("NotFound", "Application not found"));

            application.Status = status;
            application.LastUpdatedAt = DateTime.UtcNow;

            _context.jobApplications.Update(application);
            await _context.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<Result> BulkUpdateStatusAsync(List<int> ids, ApplicationStatus status , CancellationToken cancellationToken = default)
        {
            var applications = await _context.jobApplications
                .Where(a => ids.Contains(a.Id))
                .ToListAsync();

            if (!applications.Any())
                return Result.Failure(new Error("NotFound", "No applications found"));

            applications.ForEach(a =>
            {
                a.Status = status;
                a.LastUpdatedAt = DateTime.UtcNow;
            });

            _context.jobApplications.UpdateRange(applications);
            await _context.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<Result> BulkDeleteAsync(List<int> ids , CancellationToken cancellationToken = default)
        {
            var applications = await _context.jobApplications
                .Where(a => ids.Contains(a.Id))
                .ToListAsync();

            if (!applications.Any())
                return Result.Failure(new Error("NotFound", "No applications found"));

            _context.jobApplications.RemoveRange(applications);
            await _context.SaveChangesAsync();
            return Result.Success();
        }
        public async Task<Result<IEnumerable<JobApplication>>> GetByJobIdAsync(int jobId, CancellationToken cancellationToken = default)
        {
            var apps = await _context.jobApplications
                .Include(a => a.Job)
                .Include(a => a.User)
                .Where(a => a.JobId == jobId)
                .ToListAsync(cancellationToken);

            return Result.Success(apps.AsEnumerable());
        }
    }
}
