using DataAccess.Entities.RoadMap;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DataAccess.IRepository
{
    public interface IProjectRepository : IGenericRepository<ProjectSec5>
    {
        Task<IEnumerable<ProjectSec5>> GetByRoadmapIdAsync(int roadmapId);

        Task<IEnumerable<ProjectSec5>> SearchProjectsAsync(int roadmapId, string searchTerm);

        Task<bool> BulkDeleteAsync(List<int> ids);

        Task BulkUpdateAsync(List<ProjectSec5> projects);
    }
}
