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
    public async Task<int> GetTotalEventsAsync()
    {
        return await _context.events.CountAsync();
    }

    public async Task<int> GetTotalRegistrationsAsync()
    {
        return await _context.events.SumAsync(e => e.CurrentRegistrations);
    }

    public async Task<double> GetAttendanceRateAsync()
    {
        var events = await _context.events.ToListAsync();
        if (!events.Any()) return 0;
        var total = events.Sum(e => e.MaxCapacity);
        var attended = events.Sum(e => e.CurrentRegistrations);
        if (total == 0) return 0;
        return Math.Round((double)attended / total * 100, 1);
    }
}
