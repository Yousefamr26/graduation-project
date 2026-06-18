using DataAccess.Contexts;
using DataAccess.Entities.Workshop;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

public class WorkshopAnalyticsRepository : IWorkshopAnalyticsRepository
{
    private readonly ApplicationDbContext _context;
    public WorkshopAnalyticsRepository(ApplicationDbContext context) => _context = context;

    public async Task<int> GetTotalParticipantsAsync()
    {
        return await _context.workshopSec1s.SumAsync(w => w.TotalActivities);
    }

    public async Task<Dictionary<string, int>> GetByTypeAsync()
    {
        return await _context.workshopSec1s
            .GroupBy(w => w.WorkshopType)
            .Select(g => new { Type = g.Key, Count = g.Count() })
            .ToDictionaryAsync(x => x.Type, x => x.Count);
    }
}
