using DataAccess.Abstractions;
using DataAccess.Entities.Interview;

namespace DataAccess.IRepository
{
    public interface IInterviewRepository : IGenericRepository<InterviewSchedule>
    {
       
        Task<Result<InterviewSchedule>> GetByIdWithDetailsAsync(int id);
        Task<Result<IEnumerable<InterviewSchedule>>> GetAllWithDetailsAsync();
        Task<Result<IEnumerable<InterviewSchedule>>> GetByRoadmapAsync(int roadmapId);
        Task<Result<IEnumerable<InterviewSchedule>>> GetByStatusAsync(string status);
        Task<Result<IEnumerable<InterviewSchedule>>> GetAIRecommendedAsync();
        Task<Result<IEnumerable<InterviewSchedule>>> GetTodayInterviewsAsync();
        Task<Result<IEnumerable<InterviewSchedule>>> SearchInterviewsAsync(string searchTerm);

       
        Task<Result<InterviewSchedule>> AddInterviewAsync(InterviewSchedule interview);
        Task<Result> UpdateAsync(InterviewSchedule interview);
        Task<Result> DeleteAsync(int id);
        Task<Result> BulkDeleteAsync(List<int> ids);

       
        Task<Result> UpdateStatusAsync(int id, string status);
        Task<Result> BulkUpdateStatusAsync(List<int> ids, string status);

        Task<Result<int>> GetTotalCountAsync();
        Task<Result<int>> GetTodayCountAsync();
        Task<Result<List<InterviewSchedule>>> GetLatestInterviewsAsync(int count);
    }
}