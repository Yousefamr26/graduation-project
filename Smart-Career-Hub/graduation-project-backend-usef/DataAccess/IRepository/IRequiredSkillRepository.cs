using DataAccess.Entities.RoadMap;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DataAccess.IRepository
{
    public interface IRequiredSkillRepository : IGenericRepository<RequiredSkillSec2>
    {
        Task<IEnumerable<RequiredSkillSec2>> GetByRoadmapIdAsync(int roadmapId);

        Task<IEnumerable<RequiredSkillSec2>> SearchSkillsAsync(int roadmapId, string searchTerm);

        Task<bool> BulkDeleteAsync(List<int> ids);

        Task BulkUpdateAsync(List<RequiredSkillSec2> skills);
    }
}
