using DataAccess.Entities.RoadMap;
using System.Collections.Generic;
using System.Threading.Tasks;
using DataAccess.Entities;
using DataAccess.Abstractions;

namespace DataAccess.IRepository
{
    public interface IRoadmapRepository : IGenericRepository<RoadmapSec1>
    {
       
        Task<Result<RoadmapSec1>> GetByIdWithDetailsAsync(int id);
        Task<Result<IEnumerable<RoadmapSec1>>> GetAllWithDetailsAsync();
        Task<Result<IEnumerable<RoadmapSec1>>> GetPublishedRoadmapsAsync();
        Task<Result<IEnumerable<RoadmapSec1>>> GetByTargetRoleAsync(string targetRole);
        Task<Result<IEnumerable<RoadmapSec1>>> SearchRoadmapsAsync(string searchTerm);
        Task<Result<IEnumerable<RoadmapSec1>>> GetLatestRoadmapsAsync(int count = 20);
        Task<Result<IEnumerable<RoadmapSec1>>> GetTopRoadmapsByPointsAsync(int count = 20);

       
        Task<Result<RoadmapSec1>> AddRoadmapAsync(RoadmapSec1 roadmap);
        Task<Result> UpdateAsync(RoadmapSec1 roadmap);
        Task<Result> DeleteAsync(int id);

       
        Task<Result> ToggleStatusAsync(int id);
        Task<Result> BulkUpdateStatusAsync(List<int> ids, bool isPublished);
        Task<Result> BulkDeleteAsync(List<int> ids);

       
        Task<bool> IsTitleExistsAsync(string title, int? excludeId = null);
    }
}
