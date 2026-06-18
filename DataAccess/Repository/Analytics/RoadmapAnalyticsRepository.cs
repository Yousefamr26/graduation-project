using DataAccess.Contexts;
using DataAccess.Entities.RoadMap;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

public class RoadmapAnalyticsRepository : IRoadmapAnalyticsRepository
{
    private readonly ApplicationDbContext _context;
    public RoadmapAnalyticsRepository(ApplicationDbContext context) => _context = context;

    public async Task<int> GetTotalRoadmapsAsync()
    {
        return await _context.RoadmapsSec1.CountAsync();
    }

    public async Task<Dictionary<string, int>> GetDistributionByTargetRoleAsync()
    {
        return await _context.RoadmapsSec1
            .GroupBy(r => r.TargetRole)
            .Select(g => new { Role = g.Key, Count = g.Count() })
            .ToDictionaryAsync(x => x.Role, x => x.Count);
    }
}
