using DataAccess.Contexts;
using DataAccess.Entities.RoadMap;
using DataAccess.IRepository;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DataAccess.Repository
{
    public class RequiredSkillRepository : GenericRepository<RequiredSkillSec2>, IRequiredSkillRepository
    {
        private ApplicationDbContext _db;
        public RequiredSkillRepository(ApplicationDbContext db) : base(db) { _db = db; }

        public async Task<IEnumerable<RequiredSkillSec2>> GetByRoadmapIdAsync(int roadmapId)
        {
            return await _dbSet
                .Where(s => s.RoadmapId == roadmapId)
                .ToListAsync();
        }

        public async Task<IEnumerable<RequiredSkillSec2>> SearchSkillsAsync(int roadmapId, string searchTerm)
        {
            if (string.IsNullOrWhiteSpace(searchTerm))
                return await GetByRoadmapIdAsync(roadmapId);

            searchTerm = searchTerm.ToLower();
            return await _dbSet
                .Where(s => s.RoadmapId == roadmapId &&
                            s.SkillName.ToLower().Contains(searchTerm))
                .ToListAsync();
        }

        public async Task<bool> BulkDeleteAsync(List<int> ids)
        {
            var skills = await _dbSet.Where(s => ids.Contains(s.Id)).ToListAsync();
            if (!skills.Any()) return false;

            DeleteRange(skills);
            return true;
        }

        public async Task BulkUpdateAsync(List<RequiredSkillSec2> skills)
        {
            _dbSet.UpdateRange(skills);
            await Task.CompletedTask;
        }
    }
}
