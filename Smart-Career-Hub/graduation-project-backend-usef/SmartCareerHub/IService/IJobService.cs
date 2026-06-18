using DataAccess.Abstractions;
using Microsoft.AspNetCore.Http;
using SmartCareerHub.Contracts.Company.Jobs;

namespace Business_Logic.IService
{
    public interface IJobService
    {
        // =============================
        // 🔓 Read
        // =============================
        Task<PagedResponse<JobResponse>> GetAllAsync(
            QueryParameters query,
            CancellationToken cancellationToken = default);

        Task<JobResponse?> GetByIdAsync(
            int id,
            CancellationToken cancellationToken = default);

        Task<PagedResponse<JobResponse>> SearchJobsAsync(
            string searchTerm,
            QueryParameters query,
            CancellationToken cancellationToken = default);

        Task<PagedResponse<JobResponse>> GetJobsByTypeAsync(
            string jobType,
            QueryParameters query,
            CancellationToken cancellationToken = default);

        Task<PagedResponse<JobResponse>> GetJobsByExperienceLevelAsync(
            string experienceLevel,
            QueryParameters query,
            CancellationToken cancellationToken = default);

        Task<PagedResponse<JobResponse>> GetJobsByLocationAsync(
            string location,
            QueryParameters query,
            CancellationToken cancellationToken = default);

        Task<PagedResponse<JobResponse>> GetLatestJobsAsync(
            int count,
            QueryParameters query,
            CancellationToken cancellationToken = default);

        Task<int> GetTotalJobsCountAsync(
            CancellationToken cancellationToken = default);

        Task<bool> IsTitleExistsAsync(
            string title,
            int? excludeId = null,
            CancellationToken cancellationToken = default);

        // =============================
        // 🔐 Create / Update / Delete
        // =============================
        Task<JobResponse> AddAsync(
            string userId,
            JobRequest request,
            CancellationToken cancellationToken = default);

        Task<bool> UpdateAsync(
            string userId,
            int id,
            JobRequest request,
            CancellationToken cancellationToken = default);

        Task<bool> DeleteAsync(
            string userId,
            int id,
            CancellationToken cancellationToken = default);

        Task<bool> BulkDeleteAsync(
            string userId,
            List<int> ids,
            CancellationToken cancellationToken = default);

        Task<PagedResponse<JobApplicantResponse>> GetApplicantsByJobIdAsync(
            int jobId,
            QueryParameters query,
            CancellationToken cancellationToken = default);
        // في IJobApplicationService ضيف query
       
    }
}