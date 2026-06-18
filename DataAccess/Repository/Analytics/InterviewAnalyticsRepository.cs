using DataAccess.Contexts;
using DataAccess.Entities.Interview;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

public class InterviewAnalyticsRepository : IInterviewAnalyticsRepository
{
    private readonly ApplicationDbContext _context;
    public InterviewAnalyticsRepository(ApplicationDbContext context) => _context = context;

    public async Task<int> GetCompletedCountAsync() =>
        await _context.interviews.CountAsync(i => i.Status == "Completed");

    public async Task<int> GetScheduledCountAsync() =>
        await _context.interviews.CountAsync(i => i.Status == "Scheduled");

    public async Task<Dictionary<string, int>> GetCompletionRateOverTimeAsync(string period, int year)
    {
        var query = _context.interviews
            .Where(i => i.Date.Year == year && i.Status == "Completed");

        if (period.ToLower() == "monthly")
        {
            return await query
                .GroupBy(i => i.Date.Month)
                .Select(g => new { Month = g.Key, Count = g.Count() })
                .ToDictionaryAsync(x => x.Month.ToString(), x => x.Count);
        }
        else if (period.ToLower() == "weekly")
        {
            var startOfYear = new DateTime(year, 1, 1);

            return await query
                .GroupBy(i => EF.Functions.DateDiffWeek(startOfYear, i.Date))
                .Select(g => new { Week = g.Key, Count = g.Count() })
                .ToDictionaryAsync(x => x.Week.ToString(), x => x.Count);
        }


        return new Dictionary<string, int>();
    }
}
