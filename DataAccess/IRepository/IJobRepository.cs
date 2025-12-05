using DataAccess.Abstractions;
using DataAccess.Entities.Job;


namespace DataAccess.IRepository
{
    public interface IJobRepository : IGenericRepository<Job>
    {
        
        Task<Result<Job>> GetByIdAsync(int id);
        Task<Result<IEnumerable<Job>>> GetAllAsync();
        Task<Result<IEnumerable<Job>>> SearchJobsAsync(string searchTerm);
        Task<Result<IEnumerable<Job>>> GetJobsByTypeAsync(string jobType);
        Task<Result<IEnumerable<Job>>> GetJobsByExperienceLevelAsync(string experienceLevel);
        Task<Result<IEnumerable<Job>>> GetJobsByLocationAsync(string location);

        Task<Result<Job>> AddJobAsync(Job job);
        Task<Result> UpdateAsync(Job job);
        Task<Result> DeleteAsync(int id);
        Task<Result> BulkDeleteAsync(List<int> ids);

        Task<bool> IsTitleExistsAsync(string title, int? excludeId = null);

        Task<Result<List<Job>>> GetLatestJobsAsync(int count);
        Task<Result<int>> GetTotalJobsCountAsync();
    }
}