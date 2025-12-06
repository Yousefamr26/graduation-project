using DataAccess.Contexts;
using DataAccess.Entities.Events;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

public class EventAnalyticsRepository : IEventAnalyticsRepository
{
    private readonly ApplicationDbContext _context;
    public EventAnalyticsRepository(ApplicationDbContext context) => _context = context;

    public async Task<int> GetTotalParticipantsAsync()
    {
        return await _context.events.SumAsync(e => e.CurrentRegistrations);
    }

    public async Task<Dictionary<string, int>> GetByModeAsync()
    {
        return await _context.events
            .GroupBy(e => e.Mode)
            .Select(g => new { Mode = g.Key, Count = g.Count() })
            .ToDictionaryAsync(x => x.Mode, x => x.Count);
    }
}
