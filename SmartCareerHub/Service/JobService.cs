
using Business_Logic.IService;
using DataAccess.Abstractions;
using DataAccess.Entities.Job;
using DataAccess.IRepository;
using Mapster;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using SmartCareerHub.Contracts.Company.Jobs;

namespace Business_Logic.Service
{
    public class JobService : IJobService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly string _jobsPath;

        public JobService(IUnitOfWork unitOfWork, IWebHostEnvironment env)
        {
            _unitOfWork = unitOfWork;
            _jobsPath = Path.Combine(env.WebRootPath ?? "wwwroot", "uploads", "jobs");
            if (!Directory.Exists(_jobsPath))
                Directory.CreateDirectory(_jobsPath);
        }

        private async Task<string> SaveFileAsync(IFormFile file, string subFolder, CancellationToken cancellationToken = default)
        {
            var folder = Path.Combine(_jobsPath, subFolder);
            if (!Directory.Exists(folder)) Directory.CreateDirectory(folder);

            var fileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
            var path = Path.Combine(folder, fileName);

            using var stream = new FileStream(path, FileMode.Create);
            await file.CopyToAsync(stream, cancellationToken);

            return $"/uploads/jobs/{subFolder}/{fileName}";
        }

        public async Task<IEnumerable<JobResponse>> GetAllAsync(CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Jobs.GetAllAsync();
            if (result.IsFailure) return Enumerable.Empty<JobResponse>();

            return result.Value.Adapt<IEnumerable<JobResponse>>();
        }

        public async Task<JobResponse?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Jobs.GetByIdAsync(id);
            if (result.IsFailure) return null;

            return result.Value.Adapt<JobResponse>();
        }

        public async Task<IEnumerable<JobResponse>> SearchJobsAsync(string searchTerm, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Jobs.SearchJobsAsync(searchTerm);
            if (result.IsFailure) return Enumerable.Empty<JobResponse>();

            return result.Value.Adapt<IEnumerable<JobResponse>>();
        }

        public async Task<IEnumerable<JobResponse>> GetJobsByTypeAsync(string jobType, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Jobs.GetJobsByTypeAsync(jobType);
            if (result.IsFailure) return Enumerable.Empty<JobResponse>();

            return result.Value.Adapt<IEnumerable<JobResponse>>();
        }

        public async Task<IEnumerable<JobResponse>> GetJobsByExperienceLevelAsync(string experienceLevel, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Jobs.GetJobsByExperienceLevelAsync(experienceLevel);
            if (result.IsFailure) return Enumerable.Empty<JobResponse>();

            return result.Value.Adapt<IEnumerable<JobResponse>>();
        }

        public async Task<IEnumerable<JobResponse>> GetJobsByLocationAsync(string location, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Jobs.GetJobsByLocationAsync(location);
            if (result.IsFailure) return Enumerable.Empty<JobResponse>();

            return result.Value.Adapt<IEnumerable<JobResponse>>();
        }

        public async Task<JobResponse> AddAsync(JobRequest request, CancellationToken cancellationToken = default)
        {
            await _unitOfWork.BeginTransactionAsync();
            try
            {
                var job = request.Adapt<Job>();
                job.CreatedAt = DateTime.UtcNow;

                if (request.CompanyLogo != null)
                {
                    job.CompanyLogo = await SaveFileAsync(request.CompanyLogo, "logos", cancellationToken);
                }

                var addResult = await _unitOfWork.Jobs.AddJobAsync(job);
                if (addResult.IsFailure)
                    throw new InvalidOperationException(addResult.Error.Description);

                await _unitOfWork.SaveChangesAsync();
                await _unitOfWork.CommitTransactionAsync();

                var fullResult = await _unitOfWork.Jobs.GetByIdAsync(addResult.Value.Id);
                return fullResult.Value.Adapt<JobResponse>();
            }
            catch
            {
                await _unitOfWork.RollbackTransactionAsync();
                throw;
            }
        }

        public async Task<bool> UpdateAsync(int id, JobRequest request, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Jobs.GetByIdAsync(id);
            if (result.IsFailure) return false;

            var job = result.Value;
            job.Title = request.Title;
            job.Description = request.Description;
            job.RequiredSkills = request.RequiredSkills;
            job.ExperienceLevel = request.ExperienceLevel;
            job.JobType = request.JobType;
            job.Location = request.Location;
            job.SalaryRange = request.SalaryRange;

            if (request.CompanyLogo != null)
            {
                job.CompanyLogo = await SaveFileAsync(request.CompanyLogo, "logos", cancellationToken);
            }

            var updateResult = await _unitOfWork.Jobs.UpdateAsync(job);
            if (updateResult.IsFailure) return false;

            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task<bool> DeleteAsync(int id, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Jobs.DeleteAsync(id);
            if (result.IsFailure) return false;

            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task<bool> BulkDeleteAsync(List<int> ids, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Jobs.BulkDeleteAsync(ids);
            if (result.IsFailure) return false;

            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task<bool> IsTitleExistsAsync(string title, int? excludeId = null, CancellationToken cancellationToken = default)
        {
            return await _unitOfWork.Jobs.IsTitleExistsAsync(title, excludeId);
        }

        public async Task<IEnumerable<JobResponse>> GetLatestJobsAsync(int count, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Jobs.GetLatestJobsAsync(count);
            if (result.IsFailure) return Enumerable.Empty<JobResponse>();

            return result.Value.Adapt<IEnumerable<JobResponse>>();
        }

        public async Task<int> GetTotalJobsCountAsync(CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Jobs.GetTotalJobsCountAsync();
            if (result.IsFailure) return 0;

            return result.Value;
        }
    }
}