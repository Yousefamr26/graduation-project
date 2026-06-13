using DataAccess.Contexts;
using Microsoft.EntityFrameworkCore;

public class InternshipAnalyticsRepository : IInternshipAnalyticsRepository
{
    private readonly ApplicationDbContext _context;
    public InternshipAnalyticsRepository(ApplicationDbContext context) => _context = context;

    public async Task<int> GetActiveProgramsAsync()
    {
        return await _context.internships
            .CountAsync(i => i.Status == InternshipStatus.Open);
    }

    public async Task<int> GetTotalApplicantsAsync()
    {
        return await _context.internshipApplications.CountAsync();
    }

    public async Task<double> GetAcceptanceRateAsync()
    {
        var total = await _context.internshipApplications.CountAsync();
        if (total == 0) return 0;
        var accepted = await _context.internshipApplications
            .CountAsync(a => a.Status == ApplicationStatu.Accepted);
        return Math.Round((double)accepted / total * 100, 1);
    }

    public async Task<Dictionary<string, int>> GetByDepartmentAsync()
    {
        return await _context.internships
            .GroupBy(i => i.Type.ToString())
            .Select(g => new { Type = g.Key, Count = g.Count() })
            .ToDictionaryAsync(x => x.Type, x => x.Count);
    }
}