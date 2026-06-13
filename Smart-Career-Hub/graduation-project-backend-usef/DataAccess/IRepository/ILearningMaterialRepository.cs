using DataAccess.Entities.RoadMap;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DataAccess.IRepository
{
    public interface ILearningMaterialRepository : IGenericRepository<LearningMaterialSec34>
    {
        Task<IEnumerable<LearningMaterialSec34>> GetByRoadmapIdAsync(int roadmapId);

        Task<IEnumerable<LearningMaterialSec34>> SearchMaterialsAsync(int roadmapId, string searchTerm);

        Task<bool> BulkDeleteAsync(List<int> ids);

        Task BulkUpdateAsync(List<LearningMaterialSec34> materials);
    }
}
