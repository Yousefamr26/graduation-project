using DataAccess.Abstractions;
using DataAccess.Entities.Job;
using SmartCareerHub.Contracts.Company.Jobs;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Business_Logic.IService
{
    public interface IJobApplicationService
    {
        // ================== APPLY ==================
        Task<Result<JobApplicantResponse>> ApplyAsync(string userId, int jobId , CancellationToken cancellationToken = default);

        // ================== GET MY APPLICATIONS ==================
        // في IJobApplicationService غير السطر ده
        Task<Result<PagedResponse<JobApplicantResponse>>> GetMyApplicationsAsync(
            string userId,
            QueryParameters query,
            CancellationToken cancellationToken = default);
        // ================== DASHBOARD STATS ==================
        Task<Result<JobApplicationStatsDto>> GetDashboardStatsAsync(string userId , CancellationToken cancellationToken = default);

        // ================== UPDATE STATUS ==================
        Task<Result> UpdateStatusAsync(int applicationId, ApplicationStatus status , CancellationToken cancellationToken = default);

        // ================== BULK OPERATIONS ==================
        Task<Result> BulkUpdateStatusAsync(List<int> applicationIds, ApplicationStatus status , CancellationToken cancellationToken = default);
        Task<Result> BulkDeleteAsync(List<int> applicationIds , CancellationToken cancellationToken = default);
        Task<IEnumerable<JobApplicantResponse>> GetApplicantsByJobIdAsync(int jobId, CancellationToken cancellationToken = default);
        Task<Result> WithdrawAsync(string userId, int applicationId, CancellationToken cancellationToken = default);

    }
}
