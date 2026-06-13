using Business_Logic.IService;
using DataAccess.Abstractions;
using DataAccess.Contexts;
using Microsoft.EntityFrameworkCore;
using SmartCareerHub.Contracts.Analytics;

namespace Business_Logic.Service;

public class TrainCenterAnalyticsService : ITrainCenterAnalyticsService
{
    private readonly ApplicationDbContext _context;

    public TrainCenterAnalyticsService(ApplicationDbContext context)
    {
        _context = context;
    }

    // ── Full Dashboard ────────────────────────────────────────────────────────

    public async Task<TrainCenterAnalyticsFullResponse> GetFullAnalyticsAsync(int trainingCenterId)
    {
        var summary = await GetSummaryAsync(trainingCenterId);
        var attendance = await GetAttendanceOverTimeAsync(trainingCenterId);
        var courseRates = await GetCourseCompletionRatesAsync(trainingCenterId);
        var perfDist = await GetPerformanceDistributionAsync(trainingCenterId);
        var monthlyEnroll = await GetMonthlyEnrollmentVsCompletionAsync(trainingCenterId);

        return new TrainCenterAnalyticsFullResponse(summary, attendance, courseRates, perfDist, monthlyEnroll);
    }

    // ── Summary Cards ─────────────────────────────────────────────────────────

    public async Task<TrainCenterSummaryResponse> GetSummaryAsync(int trainingCenterId)
    {
        var now = DateTime.UtcNow;
        var thisMonth = new DateTime(now.Year, now.Month, 1);

        var roadmapIds = await GetRoadmapIdsAsync(trainingCenterId);

        // Total Trainees = distinct users enrolled via userRoadmaps
        var totalTrainees = await _context.userRoadmaps
            .Where(ur => roadmapIds.Contains(ur.RoadmapId))
            .Select(ur => ur.UserId)
            .Distinct()
            .CountAsync();

        var traineesLastMonth = await _context.userRoadmaps
            .Where(ur => roadmapIds.Contains(ur.RoadmapId) && ur.JoinedAt < thisMonth)
            .Select(ur => ur.UserId)
            .Distinct()
            .CountAsync();

        var traineesChange = traineesLastMonth == 0 ? 0
            : (int)Math.Round((double)(totalTrainees - traineesLastMonth) / traineesLastMonth * 100);

        // Avg Attendance Rate
        var attendanceRate = await GetAvgAttendanceRateAsync(roadmapIds);
        var attendanceLastMonth = await GetAvgAttendanceRateAsync(roadmapIds, upTo: thisMonth);
        var attendanceChange = Math.Round(attendanceRate - attendanceLastMonth, 1);

        // Completion Rate
        var completionRate = await GetOverallCompletionRateAsync(roadmapIds);
        var completionLastMonth = await GetOverallCompletionRateAsync(roadmapIds, upTo: thisMonth);
        var completionChange = Math.Round(completionRate - completionLastMonth, 1);

        // Avg Quiz Score
        var scores = await _context.QuizAttempts
            .Where(qa => roadmapIds.Contains(qa.Quiz.RoadmapId) && qa.IsCompleted)
            .Select(qa => qa.Score)
            .ToListAsync();

        var avgScore = scores.Any() ? Math.Round(scores.Average(), 1) : 0;

        var scoresLastMonth = await _context.QuizAttempts
            .Where(qa => roadmapIds.Contains(qa.Quiz.RoadmapId)
                      && qa.IsCompleted
                      && qa.StartedAt < thisMonth)
            .Select(qa => qa.Score)
            .ToListAsync();

        var avgScoreLastMonth = scoresLastMonth.Any() ? Math.Round(scoresLastMonth.Average(), 1) : 0;
        var scoreChange = Math.Round(avgScore - avgScoreLastMonth, 1);

        return new TrainCenterSummaryResponse(
            TotalTrainees: totalTrainees,
            AvgAttendanceRate: attendanceRate,
            CompletionRate: completionRate,
            AvgScore: avgScore,
            AttendanceChangePercent: attendanceChange,
            CompletionChangePercent: completionChange,
            ScoreChangePercent: scoreChange,
            TraineesChangePercent: traineesChange
        );
    }

    // ── Attendance Over Time ──────────────────────────────────────────────────

    public async Task<IEnumerable<TrainCenterAttendanceResponse>> GetAttendanceOverTimeAsync(
        int trainingCenterId, int months = 6)
    {
        var roadmapIds = await GetRoadmapIdsAsync(trainingCenterId);
        var result = new List<TrainCenterAttendanceResponse>();
        var now = DateTime.UtcNow;

        for (int i = months - 1; i >= 0; i--)
        {
            var monthStart = new DateTime(now.Year, now.Month, 1).AddMonths(-i);
            var monthEnd = monthStart.AddMonths(1);

            var userRoadmapIds = await _context.userRoadmaps
                .Where(ur => roadmapIds.Contains(ur.RoadmapId))
                .Select(ur => ur.Id)
                .ToListAsync();

            var completed = await _context.studentRoadmapItemProgresses
                .Where(p => userRoadmapIds.Contains(p.RoadmapId)
                         && p.IsCompleted
                         && p.CompletedAt >= monthStart
                         && p.CompletedAt < monthEnd)
                .CountAsync();

            var enrolled = await _context.userRoadmaps
                .Where(ur => roadmapIds.Contains(ur.RoadmapId) && ur.JoinedAt < monthEnd)
                .CountAsync();

            var rate = enrolled == 0 ? 0 : Math.Min(Math.Round((double)completed / enrolled * 100, 1), 100);

            result.Add(new TrainCenterAttendanceResponse(monthStart.ToString("MMM"), rate));
        }

        return result;
    }

    // ── Course Completion Rates ───────────────────────────────────────────────

    public async Task<IEnumerable<TrainCenterCourseCompletionResponse>> GetCourseCompletionRatesAsync(
        int trainingCenterId)
    {
        var roadmaps = await _context.RoadmapsSec1
            .Where(r => r.TrainingCenterId == trainingCenterId && r.IsPublished)
            .Select(r => new { r.Id, r.Title })
            .ToListAsync();

        var result = new List<TrainCenterCourseCompletionResponse>();

        foreach (var roadmap in roadmaps)
        {
            var totalEnrolled = await _context.userRoadmaps
                .Where(ur => ur.RoadmapId == roadmap.Id)
                .CountAsync();

            if (totalEnrolled == 0) continue;

            var totalItems = await _context.studentRoadmapItemProgresses
                .Where(p => p.RoadmapId == roadmap.Id)
                .CountAsync();

            var completedItems = await _context.studentRoadmapItemProgresses
                .Where(p => p.RoadmapId == roadmap.Id && p.IsCompleted)
                .CountAsync();

            var completionRate = totalItems == 0 ? 0
                : Math.Round((double)completedItems / totalItems * 100, 1);

            var fullyCompleted = await _context.userRoadmaps
                .Where(ur => ur.RoadmapId == roadmap.Id && ur.Status == "Completed")
                .CountAsync();

            result.Add(new TrainCenterCourseCompletionResponse(
                RoadmapId: roadmap.Id,
                RoadmapTitle: roadmap.Title,
                CompletionRate: completionRate,
                TotalEnrolled: totalEnrolled,
                TotalCompleted: fullyCompleted
            ));
        }

        return result.OrderByDescending(r => r.CompletionRate);
    }

    // ── Performance Distribution ──────────────────────────────────────────────

    public async Task<TrainCenterPerformanceResponse> GetPerformanceDistributionAsync(int trainingCenterId)
    {
        var roadmapIds = await GetRoadmapIdsAsync(trainingCenterId);

        var scores = await _context.QuizAttempts
            .Where(qa => roadmapIds.Contains(qa.Quiz.RoadmapId) && qa.IsCompleted)
            .GroupBy(qa => new { qa.UserId, qa.QuizId })
            .Select(g => g.OrderByDescending(qa => qa.StartedAt).First().Score)
            .ToListAsync();

        return new TrainCenterPerformanceResponse(
            Excellent: scores.Count(s => s >= 90),
            Good: scores.Count(s => s >= 75 && s < 90),
            Average: scores.Count(s => s >= 60 && s < 75),
            BelowAverage: scores.Count(s => s < 60)
        );
    }

    // ── Monthly Enrollment vs Completion ──────────────────────────────────────

    public async Task<IEnumerable<TrainCenterMonthlyEnrollmentResponse>> GetMonthlyEnrollmentVsCompletionAsync(
        int trainingCenterId, int months = 6)
    {
        var roadmapIds = await GetRoadmapIdsAsync(trainingCenterId);
        var result = new List<TrainCenterMonthlyEnrollmentResponse>();
        var now = DateTime.UtcNow;

        for (int i = months - 1; i >= 0; i--)
        {
            var monthStart = new DateTime(now.Year, now.Month, 1).AddMonths(-i);
            var monthEnd = monthStart.AddMonths(1);

            var enrolled = await _context.userRoadmaps
                .Where(ur => roadmapIds.Contains(ur.RoadmapId)
                          && ur.JoinedAt >= monthStart
                          && ur.JoinedAt < monthEnd)
                .CountAsync();

            var completed = await _context.userRoadmaps
                .Where(ur => roadmapIds.Contains(ur.RoadmapId)
                          && ur.Status == "Completed"
                          && ur.CompletedAt >= monthStart
                          && ur.CompletedAt < monthEnd)
                .CountAsync();

            result.Add(new TrainCenterMonthlyEnrollmentResponse(monthStart.ToString("MMM"), enrolled, completed));
        }

        return result;
    }

    // ── Private Helpers ───────────────────────────────────────────────────────

    private async Task<List<int>> GetRoadmapIdsAsync(int trainingCenterId) =>
        await _context.RoadmapsSec1
            .Where(r => r.TrainingCenterId == trainingCenterId)
            .Select(r => r.Id)
            .ToListAsync();

    private async Task<double> GetAvgAttendanceRateAsync(List<int> roadmapIds, DateTime? upTo = null)
    {
        // نجيب الـ UserRoadmap IDs الخاصة بالـ roadmaps دي
        var userRoadmapIds = await _context.userRoadmaps
            .Where(ur => roadmapIds.Contains(ur.RoadmapId))
            .Select(ur => ur.Id)
            .ToListAsync();

        var query = _context.studentRoadmapItemProgresses
            .Where(p => userRoadmapIds.Contains(p.RoadmapId));

        if (upTo.HasValue)
            query = query.Where(p => p.CompletedAt < upTo.Value || !p.IsCompleted);

        var total = await query.CountAsync();
        var completed = await query.Where(p => p.IsCompleted).CountAsync();

        return total == 0 ? 0 : Math.Round((double)completed / total * 100, 1);
    }

    private async Task<double> GetOverallCompletionRateAsync(List<int> roadmapIds, DateTime? upTo = null)
    {
        var enrollQuery = _context.userRoadmaps.Where(ur => roadmapIds.Contains(ur.RoadmapId));
        if (upTo.HasValue) enrollQuery = enrollQuery.Where(ur => ur.JoinedAt < upTo.Value);

        var totalEnrolled = await enrollQuery.CountAsync();
        if (totalEnrolled == 0) return 0;

        var completedQuery = _context.userRoadmaps
            .Where(ur => roadmapIds.Contains(ur.RoadmapId) && ur.Status == "Completed");
        if (upTo.HasValue) completedQuery = completedQuery.Where(ur => ur.CompletedAt < upTo.Value);

        var totalCompleted = await completedQuery.CountAsync();
        return Math.Round((double)totalCompleted / totalEnrolled * 100, 1);
    }
}