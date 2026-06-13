using DataAccess.Contexts;
using DataAccess.Entities.Job;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

public class JobAnalyticsRepository : IJobAnalyticsRepository
{
    private readonly ApplicationDbContext _context;
    public JobAnalyticsRepository(ApplicationDbContext context) => _context = context;

    public async Task<Dictionary<string, int>> GetByTypeAndLevelAsync()
    {
        return await _context.jobs
            .GroupBy(j => j.JobType + "|" + j.ExperienceLevel)
            .Select(g => new { Key = g.Key, Count = g.Count() })
            .ToDictionaryAsync(x => x.Key, x => x.Count);
    }
}
