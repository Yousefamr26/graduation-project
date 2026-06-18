
using Microsoft.AspNetCore.Http;
using SmartCareerHub.Contracts.Company.Jobs;

namespace Business_Logic.IService
{
    public interface IJobService
    {
        Task<IEnumerable<JobResponse>> GetAllAsync(CancellationToken cancellationToken = default);
        Task<JobResponse?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
        Task<IEnumerable<JobResponse>> SearchJobsAsync(string searchTerm, CancellationToken cancellationToken = default);
        Task<IEnumerable<JobResponse>> GetJobsByTypeAsync(string jobType, CancellationToken cancellationToken = default);
        Task<IEnumerable<JobResponse>> GetJobsByExperienceLevelAsync(string experienceLevel, CancellationToken cancellationToken = default);
        Task<IEnumerable<JobResponse>> GetJobsByLocationAsync(string location, CancellationToken cancellationToken = default);

        Task<JobResponse> AddAsync(JobRequest request, CancellationToken cancellationToken = default);
        Task<bool> UpdateAsync(int id, JobRequest request, CancellationToken cancellationToken = default);

        Task<bool> DeleteAsync(int id, CancellationToken cancellationToken = default);
        Task<bool> BulkDeleteAsync(List<int> ids, CancellationToken cancellationToken = default);

        Task<bool> IsTitleExistsAsync(string title, int? excludeId = null, CancellationToken cancellationToken = default);

        Task<IEnumerable<JobResponse>> GetLatestJobsAsync(int count, CancellationToken cancellationToken = default);
        Task<int> GetTotalJobsCountAsync(CancellationToken cancellationToken = default);
    }
}