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
    public async Task<int> GetTotalApplicationsAsync()
    {
        return await _context.jobApplications.CountAsync();
    }

    public async Task<double> GetInterviewRateAsync()
    {
        var total = await _context.jobApplications.CountAsync();
        if (total == 0) return 0;
        var interviews = await _context.jobApplications
            .CountAsync(a => a.Status == ApplicationStatus.InterviewScheduled);
        return Math.Round((double)interviews / total * 100, 1);
    }

    public async Task<double> GetHiringSuccessRateAsync()
    {
        var total = await _context.jobApplications.CountAsync();
        if (total == 0) return 0;
        var hired = await _context.jobApplications
            .CountAsync(a => a.Status == ApplicationStatus.OfferReceived);
        return Math.Round((double)hired / total * 100, 1);
    }
}
