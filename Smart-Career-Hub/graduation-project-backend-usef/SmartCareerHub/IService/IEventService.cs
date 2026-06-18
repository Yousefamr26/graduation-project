using SmartCareerHub.Contracts.Company.Event;
using Microsoft.AspNetCore.Http;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Business_Logic.IService
{
    public interface IEventService
    {
        Task<PagedResponse<EventResponse>> GetAllAsync(
           QueryParameters query,
           CancellationToken cancellationToken = default);
        Task<EventResponse?> GetByIdAsync(int id, CancellationToken cancellationToken = default);

        // creatorId لتحديد من الذي أنشأ الحدث (Company أو University)
        Task<EventResponse> AddAsync(EventRequest request, string creatorId, CancellationToken cancellationToken = default);

        Task<bool> UpdateAsync(int id, EventRequest request, CancellationToken cancellationToken = default);

        Task<bool> ToggleStatusAsync(int id, CancellationToken cancellationToken = default);
        Task<bool> BulkUpdateStatusAsync(List<int> ids, bool isPublished, CancellationToken cancellationToken = default);
        Task<bool> DeleteAsync(int id, CancellationToken cancellationToken = default);
        Task<bool> BulkDeleteAsync(List<int> ids, CancellationToken cancellationToken = default);

        Task<bool> IsTitleExistsAsync(string title, int? excludeId = null, CancellationToken cancellationToken = default);
    }
}