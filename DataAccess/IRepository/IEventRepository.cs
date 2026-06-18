using System.Collections.Generic;
using System.Threading.Tasks;
using DataAccess.Entities.Events;
using DataAccess.Abstractions;

namespace DataAccess.IRepository
{
    public interface IEventRepository : IGenericRepository<Event>
    {
      
        Task<Result<Event>> GetByIdWithDetailsAsync(int id);
        Task<Result<IEnumerable<Event>>> GetAllWithDetailsAsync();
        Task<Result<IEnumerable<Event>>> GetPublishedEventsAsync();
        Task<Result<IEnumerable<Event>>> GetUpcomingEventsAsync();
        Task<Result<IEnumerable<Event>>> SearchEventsAsync(string searchTerm);
        Task<Result<IEnumerable<Event>>> GetLatestEventsAsync(int count = 20);
        Task<Result<IEnumerable<Event>>> GetTopEventsByPointsAsync(int count = 20);

        Task<Result<Event>> AddEventAsync(Event ev);
        Task<Result> UpdateAsync(Event ev);
        Task<Result> DeleteAsync(int id);

        Task<Result> ToggleStatusAsync(int id); 
        Task<Result> BulkUpdateStatusAsync(List<int> ids, bool isPublished);
        Task<Result> BulkDeleteAsync(List<int> ids);

        Task<bool> IsTitleExistsAsync(string title, int? excludeId = null);
    }
}
