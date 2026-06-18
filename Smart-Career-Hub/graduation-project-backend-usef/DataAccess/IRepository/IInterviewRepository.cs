using DataAccess.Abstractions;
using DataAccess.Entities.Interview;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DataAccess.IRepository
{
    public interface IInterviewRepository : IGenericRepository<InterviewSchedule>
    {
        // =============================
        // Queries
        // =============================
        Task<Result<InterviewSchedule>> GetByIdWithDetailsAsync(int id);
        Task<Result<IEnumerable<InterviewSchedule>>> GetAllWithDetailsAsync();
        Task<Result<IEnumerable<InterviewSchedule>>> GetByRoadmapAsync(int roadmapId);
        Task<Result<IEnumerable<InterviewSchedule>>> GetByStatusAsync(InterviewStatus status);
        Task<Result<IEnumerable<InterviewSchedule>>> GetAIRecommendedAsync();
        Task<Result<IEnumerable<InterviewSchedule>>> GetTodayInterviewsAsync();
        Task<Result<IEnumerable<InterviewSchedule>>> SearchInterviewsAsync(string searchTerm);
        Task<Result<IEnumerable<InterviewSchedule>>> GetStudentInterviewsAsync(string userId);
        Task<Result<int>> GetTotalCountAsync();
        Task<Result<int>> GetTodayCountAsync();
        Task<Result<IEnumerable<InterviewSchedule>>> GetLatestInterviewsAsync(int count); // IEnumerable بدل List

        // =============================
        // Commands
        // =============================
        Task<Result<InterviewSchedule>> AddInterviewAsync(InterviewSchedule interview);
        Task<Result> UpdateAsync(InterviewSchedule interview);
        Task<Result> DeleteAsync(int id);
        Task<Result> BulkDeleteAsync(List<int> ids);
        Task<Result> UpdateStatusAsync(int id, InterviewStatus status);
        Task<Result> BulkUpdateStatusAsync(List<int> ids, InterviewStatus status);

        // =============================
        // Student / Graduate specific
        // =============================
        Task<Result<IEnumerable<InterviewSchedule>>> GetUpcomingInterviewsAsync(string userId);
        Task<Result<IEnumerable<InterviewSchedule>>> GetPastInterviewsAsync(string userId);
        Task<Result<InterviewSchedule>> GetByIdForUserAsync(int id, string userId);
        Task<Result> AcceptInterviewAsync(int id, string userId);
        Task<Result> DeclineInterviewAsync(int id, string userId);
    }
}