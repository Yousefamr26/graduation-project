using DataAccess.Contexts;
using Microsoft.EntityFrameworkCore;

public class UniversityAnalyticsRepository : IUniversityAnalyticsRepository
{
    private readonly ApplicationDbContext _context;
    public UniversityAnalyticsRepository(ApplicationDbContext context) => _context = context;

    public async Task<int> GetTotalActivePartnersAsync()
    {
        return await _context.Users
            .CountAsync(u => u.UserType == "University" && u.IsActive);
    }

    public async Task<string> GetMostActiveCampusAsync()
    {
        var mostActive = await _context.Users
            .Where(u => u.UserType == "University" && u.UniversityProfile != null)
            .GroupBy(u => u.UniversityProfile.Name)
            .Select(g => new { Name = g.Key, Count = g.Count() })
            .OrderByDescending(x => x.Count)
            .FirstOrDefaultAsync();

        return mostActive?.Name ?? "N/A";
    }

    public async Task<int> GetNewPartnershipsAsync(int year, int quarter)
    {
        var startMonth = (quarter - 1) * 3 + 1;
        var endMonth = startMonth + 2;

        return await _context.Users
            .CountAsync(u => u.UserType == "University"
                && u.CreatedAt.Year == year
                && u.CreatedAt.Month >= startMonth
                && u.CreatedAt.Month <= endMonth);
    }
}