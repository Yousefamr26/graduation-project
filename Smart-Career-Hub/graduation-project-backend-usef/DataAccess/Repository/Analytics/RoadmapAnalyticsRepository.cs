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

    // =====================
    // Existing methods
    // =====================
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

    // =====================
    // ✅ New methods for Dashboard
    // =====================

    // تجيب كل Roadmaps مع المسجلين وProgress لكل مسجل
    public async Task<List<RoadmapAnalyticsDto>> GetAllRoadmapsWithEnrollmentsAsync()
    {
        return await _context.RoadmapsSec1
            .Include(r => r.Enrollments) // افتراض أن Roadmap فيه ICollection<Enrollment>
            .Select(r => new RoadmapAnalyticsDto
            {
                Id = r.Id,
                Title = r.Title,
                IsPublished = r.IsPublished,
                Enrollments = r.Enrollments.Select(e => new EnrollmentInfo
                {
                    UserId = e.UserId,
                    Progress = e.Progress
                }).ToList()
            })
            .ToListAsync();
    }

    // مجموع المسجلين لكل Roadmaps
    public async Task<int> GetTotalEnrollmentsAsync()
    {
        return await _context.RoadmapsSec1
            .SelectMany(r => r.Enrollments)
            .CountAsync();
    }

    // عدد Roadmaps المنشورة فقط
    public async Task<int> GetActiveRoadmapsAsync()
    {
        return await _context.RoadmapsSec1
            .CountAsync(r => r.IsPublished);
    }

    // متوسط نسبة الإنجاز لكل المسجلين في كل Roadmaps
    public async Task<double> GetAvgCompletionAsync()
    {
        var enrollments = await _context.RoadmapsSec1
            .SelectMany(r => r.Enrollments)
            .ToListAsync();

        if (!enrollments.Any())
            return 0;

        return enrollments.Average(e => e.Progress);
    }
    public async Task<int> GetTotalEnrolledAsync()
    {
        return await _context.userRoadmaps.CountAsync();
    }

    public async Task<double> GetCompletionRateAsync()
    {
        var total = await _context.userRoadmaps.CountAsync();
        if (total == 0) return 0;
        var completed = await _context.userRoadmaps
            .CountAsync(ur => ur.Status == "Completed");
        return Math.Round((double)completed / total * 100, 1);
    }

    public async Task<double> GetAvgProgressAsync()
    {
        var enrollments = await _context.userRoadmaps.ToListAsync();
        if (!enrollments.Any()) return 0;
        return Math.Round(enrollments.Average(ur => ur.ProgressPercent), 1);
    }
}