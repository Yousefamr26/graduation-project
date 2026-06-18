using DataAccess.Contexts;
using DataAccess.Entities.RoadMap;
using DataAccess.IRepository;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DataAccess.Repository
{
    public class UserRoadmapItemProgressRepository : IUserRoadmapItemProgressRepository
    {
        private readonly ApplicationDbContext _context;

        public UserRoadmapItemProgressRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<UserRoadmapItemProgress?> GetAsync(string userId, int roadmapId, int itemId, string itemType)
        {
            return await _context.studentRoadmapItemProgresses
                .FirstOrDefaultAsync(x => x.UserId == userId
                                       && x.RoadmapId == roadmapId
                                       && x.ItemId == itemId
                                       && x.ItemType == itemType);
        }

        public async Task AddAsync(UserRoadmapItemProgress entity)
        {
            _context.studentRoadmapItemProgresses.Add(entity);
            await _context.SaveChangesAsync();
        }

        public async Task<int> CountCompletedAsync(string userId, int roadmapId)
        {
            return await _context.studentRoadmapItemProgresses
                .CountAsync(x => x.UserId == userId
                              && x.RoadmapId == roadmapId
                              && x.IsCompleted);
        }

        public async Task<IEnumerable<UserRoadmapItemProgress>> GetAllByStudentAndRoadmapAsync(string userId, int roadmapId)
        {
            return await _context.studentRoadmapItemProgresses
                .Where(x => x.UserId == userId && x.RoadmapId == roadmapId)
                .ToListAsync();
        }
    }
}
