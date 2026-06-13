using DataAccess.Entities.RoadMap;
using System.Collections.Generic;
using System.Threading.Tasks;

public interface IRoadmapAnalyticsRepository
{
    // موجودة حالياً
    Task<int> GetTotalRoadmapsAsync();
    Task<Dictionary<string, int>> GetDistributionByTargetRoleAsync();

    // =========================
    // ✅ Methods جديدة للـ Dashboard الديناميكي
    // =========================

    // تجيب كل Roadmaps مع المسجلين وProgress لكل مسجل
    Task<List<RoadmapAnalyticsDto>> GetAllRoadmapsWithEnrollmentsAsync();

    // مجموع المسجلين لكل Roadmaps
    Task<int> GetTotalEnrollmentsAsync();

    // عدد Roadmaps المنشورة فقط
    Task<int> GetActiveRoadmapsAsync();

    // متوسط نسبة الإنجاز لكل المسجلين في كل Roadmaps
    Task<double> GetAvgCompletionAsync();
    Task<int> GetTotalEnrolledAsync();
    Task<double> GetCompletionRateAsync();
    Task<double> GetAvgProgressAsync();
}

// =========================
// DTOs المتوقعة
// =========================
public class EnrollmentInfo
{
    public string UserId { get; set; }
    public double Progress { get; set; } // 0 - 100
}

public class RoadmapAnalyticsDto
{
    public int Id { get; set; }
    public string Title { get; set; }
    public bool IsPublished { get; set; }
    public List<EnrollmentInfo> Enrollments { get; set; } = new List<EnrollmentInfo>();
}