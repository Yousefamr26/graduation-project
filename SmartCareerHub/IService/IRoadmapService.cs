using Microsoft.AspNetCore.Http;
using SmartCareerHub.Contracts.Company.CreateRoadmap;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Business_Logic.IService
{
    public interface IRoadmapService
    {
        Task<IEnumerable<RoadmapResponse>> GetAllAsync(CancellationToken cancellationToken = default);
        Task<RoadmapResponse?> GetByIdAsync(int id, CancellationToken cancellationToken = default);

        Task<RoadmapResponse> AddAsync(RoadmapRequest request, CancellationToken cancellationToken = default);
        Task<bool> UpdateAsync(int id, RoadmapRequest request, IFormFile? coverImage = null, CancellationToken cancellationToken = default);

        Task<bool> ToggleStatusAsync(int id, CancellationToken cancellationToken = default);
        Task<bool> BulkUpdateStatusAsync(List<int> ids, bool isPublished, CancellationToken cancellationToken = default);
        Task<bool> DeleteWithAllChildrenAsync(int id, CancellationToken cancellationToken = default);
        Task<bool> BulkDeleteAsync(List<int> ids, CancellationToken cancellationToken = default);

        Task<bool> IsTitleExistsAsync(string title, int? excludeId = null, CancellationToken cancellationToken = default);
    }
}
