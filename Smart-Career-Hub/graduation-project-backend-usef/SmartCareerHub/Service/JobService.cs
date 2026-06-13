using Business_Logic.IService;
using DataAccess.Abstractions;
using DataAccess.Entities.Job;
using DataAccess.IRepository;
using Mapster;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using SmartCareerHub.Contracts.Company.Jobs;
using System.IO;
using System.Threading;

namespace Business_Logic.Service
{
    public class JobService : IJobService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IRealTimeNotificationService _realTimeNotificationService;
        private readonly string _jobsPath;

        public JobService(
            IUnitOfWork unitOfWork,
            IWebHostEnvironment env,
            IHttpContextAccessor httpContextAccessor,
            IRealTimeNotificationService realTimeNotificationService)
        {
            _unitOfWork = unitOfWork;
            _httpContextAccessor = httpContextAccessor;
            _realTimeNotificationService = realTimeNotificationService;
            _jobsPath = Path.Combine(env.WebRootPath ?? "wwwroot", "uploads", "jobs");

            if (!Directory.Exists(_jobsPath))
                Directory.CreateDirectory(_jobsPath);
        }

        private async Task<string?> SaveFileAsync(IFormFile file, string subFolder, CancellationToken cancellationToken = default)
        {
            if (file == null || file.Length == 0)
                return null;

            var folder = Path.Combine(_jobsPath, subFolder);
            if (!Directory.Exists(folder))
                Directory.CreateDirectory(folder);

            var fileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
            var path = Path.Combine(folder, fileName);

            using var stream = new FileStream(path, FileMode.Create);
            await file.CopyToAsync(stream, cancellationToken);

            return $"/uploads/jobs/{subFolder}/{fileName}";
        }

        // ============================= Jobs CRUD =============================

        public async Task<PagedResponse<JobResponse>> GetAllAsync(
            QueryParameters query,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Jobs.GetAllAsync();
            if (result.IsFailure)
                return PagedResponse<JobResponse>.Create(
                    Enumerable.Empty<JobResponse>(), query.Page, query.PageSize);

            var jobs = result.Value.AsEnumerable();

            // Filtering
            if (!string.IsNullOrWhiteSpace(query.Search))
                jobs = jobs.Where(j =>
                    j.Title.Contains(query.Search, StringComparison.OrdinalIgnoreCase) ||
                    j.Location.Contains(query.Search, StringComparison.OrdinalIgnoreCase) ||
                    j.JobType.Contains(query.Search, StringComparison.OrdinalIgnoreCase));

            // Sorting
            jobs = query.SortBy?.ToLower() switch
            {
                "title" => query.SortDirection == "asc"
                    ? jobs.OrderBy(j => j.Title)
                    : jobs.OrderByDescending(j => j.Title),
                "location" => query.SortDirection == "asc"
                    ? jobs.OrderBy(j => j.Location)
                    : jobs.OrderByDescending(j => j.Location),
                _ => jobs.OrderByDescending(j => j.CreatedAt)
            };

            var responses = new List<JobResponse>();
            foreach (var job in jobs)
            {
                var company = await _unitOfWork.companyAuthRepository
                    .GetCompanyProfileByUserIdAsync(job.CompanyUserId);
                var response = job.Adapt<JobResponse>();
                response = response with { CompanyName = company?.OrganizationName ?? "" };
                responses.Add(response);
            }

            return PagedResponse<JobResponse>.Create(responses, query.Page, query.PageSize);
        }

        public async Task<JobResponse?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Jobs.GetByIdAsync(id);
            if (result.IsFailure)
                return null;

            var job = result.Value;
            var company = await _unitOfWork.companyAuthRepository
                .GetCompanyProfileByUserIdAsync(job.CompanyUserId);
            var response = job.Adapt<JobResponse>();
            response = response with { CompanyName = company?.OrganizationName ?? "" };
            return response;
        }

        public async Task<JobResponse> AddAsync(string userId, JobRequest request, CancellationToken cancellationToken = default)
        {
            var company = await _unitOfWork.companyAuthRepository.GetCompanyProfileByUserIdAsync(userId);
            if (company == null)
                throw new InvalidOperationException("Company profile not found.");

            if (await IsTitleExistsAsync(request.Title))
                throw new InvalidOperationException("Job title already exists.");

            await _unitOfWork.BeginTransactionAsync();
            try
            {
                var job = request.Adapt<Job>();
                job.CreatedAt = DateTime.UtcNow;
                job.CompanyUserId = company.Id;

                if (request.CompanyLogo != null)
                    job.CompanyLogo = await SaveFileAsync(request.CompanyLogo, "logos", cancellationToken);

                var addResult = await _unitOfWork.Jobs.AddJobAsync(job);
                if (addResult.IsFailure)
                    throw new InvalidOperationException(addResult.Error.Description);

                await _unitOfWork.SaveChangesAsync();
                await _unitOfWork.CommitTransactionAsync();

                await _realTimeNotificationService.SendToUserAsync(
                    userId,
                    "New Job Created ✅",
                    $"Your job '{job.Title}' has been successfully created."
                );

                var fullJob = await _unitOfWork.Jobs.GetByIdAsync(addResult.Value.Id);
                var response = fullJob.Value.Adapt<JobResponse>();
                response = response with { CompanyName = company.OrganizationName };

                return response;
            }
            catch
            {
                await _unitOfWork.RollbackTransactionAsync();
                throw;
            }
        }

        public async Task<bool> UpdateAsync(string userId, int id, JobRequest request, CancellationToken cancellationToken = default)
        {
            var company = await _unitOfWork.companyAuthRepository.GetCompanyProfileByUserIdAsync(userId);
            if (company == null)
                throw new InvalidOperationException("Company profile not found.");

            var result = await _unitOfWork.Jobs.GetByIdAsync(id);
            if (result.IsFailure)
                return false;

            var job = result.Value;
            if (job.CompanyUserId != company.Id)
                throw new UnauthorizedAccessException("You cannot update this job");

            job.Title = request.Title;
            job.Description = request.Description;
            job.RequiredSkills = request.RequiredSkills;
            job.ExperienceLevel = request.ExperienceLevel;
            job.JobType = request.JobType;
            job.Location = request.Location;
            job.SalaryRange = request.SalaryRange;

            if (request.CompanyLogo != null)
                job.CompanyLogo = await SaveFileAsync(request.CompanyLogo, "logos", cancellationToken);

            var updateResult = await _unitOfWork.Jobs.UpdateAsync(job);
            if (updateResult.IsFailure)
                return false;

            await _unitOfWork.SaveChangesAsync();

            await _realTimeNotificationService.SendToUserAsync(
                userId,
                "Job Updated ✏️",
                $"Your job '{job.Title}' has been updated successfully."
            );

            return true;
        }

        public async Task<bool> DeleteAsync(string userId, int id, CancellationToken cancellationToken = default)
        {
            var company = await _unitOfWork.companyAuthRepository.GetCompanyProfileByUserIdAsync(userId);
            if (company == null)
                throw new InvalidOperationException("Company profile not found.");

            var result = await _unitOfWork.Jobs.GetByIdAsync(id);
            if (result.IsFailure)
                return false;

            var job = result.Value;
            if (job.CompanyUserId != company.Id)
                throw new UnauthorizedAccessException("You cannot delete this job");

            var deleteResult = await _unitOfWork.Jobs.DeleteAsync(id);
            if (deleteResult.IsFailure)
                return false;

            await _unitOfWork.SaveChangesAsync();

            await _realTimeNotificationService.SendToUserAsync(
                userId,
                "Job Deleted ❌",
                $"Your job '{job.Title}' has been deleted."
            );

            return true;
        }

        public async Task<bool> BulkDeleteAsync(string userId, List<int> ids, CancellationToken cancellationToken = default)
        {
            if (ids == null || !ids.Any())
                throw new InvalidOperationException("No job IDs provided.");

            var company = await _unitOfWork.companyAuthRepository.GetCompanyProfileByUserIdAsync(userId);
            if (company == null)
                throw new InvalidOperationException("Company profile not found.");

            foreach (var id in ids)
                await DeleteAsync(userId, id, cancellationToken);

            await _realTimeNotificationService.SendToUserAsync(
                userId,
                "Bulk Job Delete ⚠️",
                $"You have deleted {ids.Count} jobs successfully."
            );

            return true;
        }

        // ============================= Jobs Queries =============================

        public async Task<PagedResponse<JobResponse>> SearchJobsAsync(
            string searchTerm,
            QueryParameters query,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Jobs.SearchJobsAsync(searchTerm);
            if (result.IsFailure)
                return PagedResponse<JobResponse>.Create(
                    Enumerable.Empty<JobResponse>(), query.Page, query.PageSize);

            var jobs = result.Value.AsEnumerable();

            // Sorting
            jobs = query.SortBy?.ToLower() switch
            {
                "title" => query.SortDirection == "asc"
                    ? jobs.OrderBy(j => j.Title)
                    : jobs.OrderByDescending(j => j.Title),
                _ => jobs.OrderByDescending(j => j.CreatedAt)
            };

            var responses = new List<JobResponse>();
            foreach (var job in jobs)
            {
                var company = await _unitOfWork.companyAuthRepository
                    .GetCompanyProfileByUserIdAsync(job.CompanyUserId);
                var response = job.Adapt<JobResponse>();
                response = response with { CompanyName = company?.OrganizationName ?? "" };
                responses.Add(response);
            }

            return PagedResponse<JobResponse>.Create(responses, query.Page, query.PageSize);
        }

        public async Task<PagedResponse<JobResponse>> GetJobsByTypeAsync(
            string jobType,
            QueryParameters query,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Jobs.GetJobsByTypeAsync(jobType);
            if (result.IsFailure)
                return PagedResponse<JobResponse>.Create(
                    Enumerable.Empty<JobResponse>(), query.Page, query.PageSize);

            var jobs = result.Value.AsEnumerable();

            // Sorting
            jobs = query.SortBy?.ToLower() switch
            {
                "title" => query.SortDirection == "asc"
                    ? jobs.OrderBy(j => j.Title)
                    : jobs.OrderByDescending(j => j.Title),
                _ => jobs.OrderByDescending(j => j.CreatedAt)
            };

            var responses = new List<JobResponse>();
            foreach (var job in jobs)
            {
                var company = await _unitOfWork.companyAuthRepository
                    .GetCompanyProfileByUserIdAsync(job.CompanyUserId);
                var response = job.Adapt<JobResponse>();
                response = response with { CompanyName = company?.OrganizationName ?? "" };
                responses.Add(response);
            }

            return PagedResponse<JobResponse>.Create(responses, query.Page, query.PageSize);
        }

        public async Task<PagedResponse<JobResponse>> GetJobsByExperienceLevelAsync(
            string experienceLevel,
            QueryParameters query,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Jobs.GetJobsByExperienceLevelAsync(experienceLevel);
            if (result.IsFailure)
                return PagedResponse<JobResponse>.Create(
                    Enumerable.Empty<JobResponse>(), query.Page, query.PageSize);

            var jobs = result.Value.AsEnumerable();

            // Sorting
            jobs = query.SortBy?.ToLower() switch
            {
                "title" => query.SortDirection == "asc"
                    ? jobs.OrderBy(j => j.Title)
                    : jobs.OrderByDescending(j => j.Title),
                _ => jobs.OrderByDescending(j => j.CreatedAt)
            };

            var responses = new List<JobResponse>();
            foreach (var job in jobs)
            {
                var company = await _unitOfWork.companyAuthRepository
                    .GetCompanyProfileByUserIdAsync(job.CompanyUserId);
                var response = job.Adapt<JobResponse>();
                response = response with { CompanyName = company?.OrganizationName ?? "" };
                responses.Add(response);
            }

            return PagedResponse<JobResponse>.Create(responses, query.Page, query.PageSize);
        }

        public async Task<PagedResponse<JobResponse>> GetJobsByLocationAsync(
            string location,
            QueryParameters query,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Jobs.GetJobsByLocationAsync(location);
            if (result.IsFailure)
                return PagedResponse<JobResponse>.Create(
                    Enumerable.Empty<JobResponse>(), query.Page, query.PageSize);

            var jobs = result.Value.AsEnumerable();

            // Sorting
            jobs = query.SortBy?.ToLower() switch
            {
                "title" => query.SortDirection == "asc"
                    ? jobs.OrderBy(j => j.Title)
                    : jobs.OrderByDescending(j => j.Title),
                "location" => query.SortDirection == "asc"
                    ? jobs.OrderBy(j => j.Location)
                    : jobs.OrderByDescending(j => j.Location),
                _ => jobs.OrderByDescending(j => j.CreatedAt)
            };

            var responses = new List<JobResponse>();
            foreach (var job in jobs)
            {
                var company = await _unitOfWork.companyAuthRepository
                    .GetCompanyProfileByUserIdAsync(job.CompanyUserId);
                var response = job.Adapt<JobResponse>();
                response = response with { CompanyName = company?.OrganizationName ?? "" };
                responses.Add(response);
            }

            return PagedResponse<JobResponse>.Create(responses, query.Page, query.PageSize);
        }

        public async Task<PagedResponse<JobResponse>> GetLatestJobsAsync(
            int count,
            QueryParameters query,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Jobs.GetLatestJobsAsync(count);
            if (result.IsFailure)
                return PagedResponse<JobResponse>.Create(
                    Enumerable.Empty<JobResponse>(), query.Page, query.PageSize);

            var responses = new List<JobResponse>();
            foreach (var job in result.Value)
            {
                var company = await _unitOfWork.companyAuthRepository
                    .GetCompanyProfileByUserIdAsync(job.CompanyUserId);
                var response = job.Adapt<JobResponse>();
                response = response with { CompanyName = company?.OrganizationName ?? "" };
                responses.Add(response);
            }

            return PagedResponse<JobResponse>.Create(responses, query.Page, query.PageSize);
        }

        public async Task<int> GetTotalJobsCountAsync(CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Jobs.GetTotalJobsCountAsync();
            if (result.IsFailure)
                return 0;
            return result.Value;
        }

        public async Task<bool> IsTitleExistsAsync(string title, int? excludeId = null, CancellationToken cancellationToken = default)
        {
            return await _unitOfWork.Jobs.IsTitleExistsAsync(title, excludeId);
        }

        // ============================= Applicants =============================

        public async Task<PagedResponse<JobApplicantResponse>> GetApplicantsByJobIdAsync(
            int jobId,
            QueryParameters query,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.jobApplicationRepository.GetByJobIdAsync(jobId, cancellationToken);
            if (result.IsFailure)
                return PagedResponse<JobApplicantResponse>.Create(
                    Enumerable.Empty<JobApplicantResponse>(), query.Page, query.PageSize);

            var applicants = result.Value.AsEnumerable();

            // Filtering
            if (!string.IsNullOrWhiteSpace(query.Search))
                applicants = applicants.Where(a =>
                    a.User?.FirstName.Contains(query.Search, StringComparison.OrdinalIgnoreCase) == true ||
                    a.User?.Email.Contains(query.Search, StringComparison.OrdinalIgnoreCase) == true);

            // Sorting
            applicants = query.SortBy?.ToLower() switch
            {
                "name" => query.SortDirection == "asc"
                    ? applicants.OrderBy(a => a.User?.FirstName)
                    : applicants.OrderByDescending(a => a.User?.FirstName),
                _ => applicants.OrderByDescending(a => a.AppliedAt)
            };

            var mapped = applicants.Select(a => new JobApplicantResponse(
                ApplicationId: a.Id,
                ApplicantName: $"{a.User?.FirstName} {a.User?.LastName}",
                JobTitle: a.Job?.Title ?? "N/A",
                CompanyName: a.Job?.CompanyUser?.OrganizationName ?? "N/A",
                JobId: a.JobId,
                AppliedDate: a.AppliedAt,
                Status: a.Status.ToString(),
                UserId: a.UserId
            ));

            return PagedResponse<JobApplicantResponse>.Create(mapped, query.Page, query.PageSize);
        }


    }
}