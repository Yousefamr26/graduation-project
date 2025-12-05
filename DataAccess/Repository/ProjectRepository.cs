using DataAccess.Contexts;
using DataAccess.Entities.RoadMap;
using DataAccess.IRepository;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DataAccess.Repository
{
    public class ProjectRepository : GenericRepository<ProjectSec5>, IProjectRepository
    {
        public ProjectRepository(ApplicationDbContext context) : base(context) { }

        public async Task<IEnumerable<ProjectSec5>> GetByRoadmapIdAsync(int roadmapId)
        {
            return await _dbSet
                .Where(p => p.RoadmapId == roadmapId)
                .ToListAsync();
        }

        public async Task<IEnumerable<ProjectSec5>> SearchProjectsAsync(int roadmapId, string searchTerm)
        {
            if (string.IsNullOrWhiteSpace(searchTerm))
                return await GetByRoadmapIdAsync(roadmapId);

            searchTerm = searchTerm.ToLower();
            return await _dbSet
                .Where(p => p.RoadmapId == roadmapId &&
                           (p.Title.ToLower().Contains(searchTerm) ||
                            p.Description.ToLower().Contains(searchTerm)))
                .ToListAsync();
        }

        public async Task<bool> BulkDeleteAsync(List<int> ids)
        {
            var projects = await _dbSet.Where(p => ids.Contains(p.Id)).ToListAsync();
            if (!projects.Any()) return false;

            DeleteRange(projects);
            return true;
        }

        public async Task BulkUpdateAsync(List<ProjectSec5> projects)
        {
            _dbSet.UpdateRange(projects);
            await Task.CompletedTask;
        }
    }
}
