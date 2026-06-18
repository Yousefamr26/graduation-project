using DataAccess.Contexts;
using DataAccess.Entities.RoadMap;
using DataAccess.IRepository;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DataAccess.Repository
{
    public class LearningMaterialRepository : GenericRepository<LearningMaterialSec34>, ILearningMaterialRepository
    {
        public LearningMaterialRepository(ApplicationDbContext context) : base(context) { }

        
        public async Task<IEnumerable<LearningMaterialSec34>> GetByRoadmapIdAsync(int roadmapId)
        {
            return await _dbSet
                .Where(m => m.RoadmapId == roadmapId)
                .ToListAsync();
        }

        public async Task<IEnumerable<LearningMaterialSec34>> SearchMaterialsAsync(int roadmapId, string searchTerm)
        {
            if (string.IsNullOrWhiteSpace(searchTerm))
                return await GetByRoadmapIdAsync(roadmapId);

            searchTerm = searchTerm.ToLower();
            return await _dbSet
                .Where(m => m.RoadmapId == roadmapId &&
                           (m.TitleVideos.ToLower().Contains(searchTerm) ||
                            m.TitlePdf.ToLower().Contains(searchTerm)))
                .ToListAsync();
        }

        public async Task<bool> BulkDeleteAsync(List<int> ids)
        {
            var materials = await _dbSet.Where(m => ids.Contains(m.Id)).ToListAsync();
            if (!materials.Any()) return false;

            DeleteRange(materials);
            return true;
        }

        public async Task BulkUpdateAsync(List<LearningMaterialSec34> materials)
        {
            _dbSet.UpdateRange(materials);
            await Task.CompletedTask;
        }
    }
}
