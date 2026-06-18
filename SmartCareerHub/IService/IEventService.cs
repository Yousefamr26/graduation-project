using DataAccess.Entities.Events;
using Microsoft.AspNetCore.Http;
using SmartCareerHub.Contracts.Company.Event;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Business_Logic.IService
{
    public interface IEventService
    {
        Task<IEnumerable<EventResponse>> GetAllAsync(CancellationToken cancellationToken = default);
        Task<EventResponse?> GetByIdAsync(int id, CancellationToken cancellationToken = default);

        Task<EventResponse> AddAsync(Event request, IFormFile? banner = null, CancellationToken cancellationToken = default);
        Task<bool> UpdateAsync(int id, Event request, IFormFile? banner = null, CancellationToken cancellationToken = default);

        Task<bool> ToggleStatusAsync(int id, CancellationToken cancellationToken = default);
        Task<bool> BulkUpdateStatusAsync(List<int> ids, bool isPublished, CancellationToken cancellationToken = default);
        Task<bool> DeleteAsync(int id, CancellationToken cancellationToken = default);
        Task<bool> BulkDeleteAsync(List<int> ids, CancellationToken cancellationToken = default);

        Task<bool> IsTitleExistsAsync(string title, int? excludeId = null, CancellationToken cancellationToken = default);
    }
}
