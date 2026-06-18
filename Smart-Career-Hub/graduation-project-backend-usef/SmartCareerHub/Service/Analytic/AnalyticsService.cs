using Business_Logic.IService;
using DataAccess.IRepository;

namespace Business_Logic.Service
{
    public class AnalyticsService : IAnalyticsService
    {
        private readonly IUnitOfWork _unitOfWork;

        public AnalyticsService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<object> GetDashboardOverviewAsync(CancellationToken cancellationToken = default)
        {
            return new
            {
                Roadmap = new
                {
                    TotalRoadmaps = await _unitOfWork.RoadmapAnalytics.GetTotalRoadmapsAsync(),
                    ActiveRoadmaps = await _unitOfWork.RoadmapAnalytics.GetActiveRoadmapsAsync(),
                    TotalEnrolled = await _unitOfWork.RoadmapAnalytics.GetTotalEnrolledAsync(),
                    CompletionRate = await _unitOfWork.RoadmapAnalytics.GetCompletionRateAsync(),
                    AvgProgress = await _unitOfWork.RoadmapAnalytics.GetAvgProgressAsync()
                },
                Jobs = new
                {
                    TotalJobPostings = await _unitOfWork.Jobs.GetTotalJobsCountAsync(),
                    TotalApplications = await _unitOfWork.JobAnalytics.GetTotalApplicationsAsync(),
                    InterviewRate = await _unitOfWork.JobAnalytics.GetInterviewRateAsync(),
                    HiringSuccessRate = await _unitOfWork.JobAnalytics.GetHiringSuccessRateAsync()
                },
                Internships = new
                {
                    ActivePrograms = await _unitOfWork.InternshipAnalytics.GetActiveProgramsAsync(),
                    TotalApplicants = await _unitOfWork.InternshipAnalytics.GetTotalApplicantsAsync(),
                    AcceptanceRate = await _unitOfWork.InternshipAnalytics.GetAcceptanceRateAsync()
                },
                Workshops = new
                {
                    TotalWorkshops = await _unitOfWork.WorkshopAnalytics.GetTotalWorkshopsAsync(),
                    TotalParticipants = await _unitOfWork.WorkshopAnalytics.GetTotalParticipantsAsync(),
                    AttendanceRate = await _unitOfWork.WorkshopAnalytics.GetAttendanceRateAsync()
                },
                Events = new
                {
                    TotalEvents = await _unitOfWork.EventAnalytics.GetTotalEventsAsync(),
                    TotalRegistrations = await _unitOfWork.EventAnalytics.GetTotalRegistrationsAsync(),
                    AttendanceRate = await _unitOfWork.EventAnalytics.GetAttendanceRateAsync()
                },
                Interviews = new
                {
                    TotalInterviews = await _unitOfWork.InterviewAnalytics.GetTotalInterviewsAsync(),
                    AttendanceRate = await _unitOfWork.InterviewAnalytics.GetAttendanceRateAsync(),
                    HiringRate = await _unitOfWork.InterviewAnalytics.GetHiringRateAsync(),
                    CompletedCount = await _unitOfWork.InterviewAnalytics.GetCompletedCountAsync()
                },
                Universities = new
                {
                    TotalActivePartners = await _unitOfWork.UniversityAnalytics.GetTotalActivePartnersAsync(),
                    MostActiveCampus = await _unitOfWork.UniversityAnalytics.GetMostActiveCampusAsync(),
                    NewPartnerships = await _unitOfWork.UniversityAnalytics.GetNewPartnershipsAsync(DateTime.Now.Year, (DateTime.Now.Month - 1) / 3 + 1)
                }
            };
        }

        public async Task<object> GetRoadmapDashboardAsync(CancellationToken cancellationToken = default)
        {
            var roadmaps = await _unitOfWork.RoadmapAnalytics.GetAllRoadmapsWithEnrollmentsAsync();
            var totalEnrollments = roadmaps.Sum(r => r.Enrollments.Count);
            var activeRoadmaps = roadmaps.Count(r => r.IsPublished);

            double avgCompletion = 0;
            if (totalEnrollments > 0)
                avgCompletion = roadmaps.Sum(r => r.Enrollments.Sum(e => e.Progress)) / totalEnrollments;

            return new
            {
                TotalRoadmaps = roadmaps.Count(),
                TotalEnrollments = totalEnrollments,
                ActiveRoadmaps = activeRoadmaps,
                AvgCompletion = Math.Round(avgCompletion)
            };
        }

        public async Task<object> GetRoadmapAnalyticsAsync(CancellationToken cancellationToken = default)
        {
            return new
            {
                TotalRoadmaps = await _unitOfWork.RoadmapAnalytics.GetTotalRoadmapsAsync(),
                ActiveRoadmaps = await _unitOfWork.RoadmapAnalytics.GetActiveRoadmapsAsync(),
                TotalEnrolled = await _unitOfWork.RoadmapAnalytics.GetTotalEnrolledAsync(),
                CompletionRate = await _unitOfWork.RoadmapAnalytics.GetCompletionRateAsync(),
                AvgProgress = await _unitOfWork.RoadmapAnalytics.GetAvgProgressAsync(),
                DistributionByTargetRole = await _unitOfWork.RoadmapAnalytics.GetDistributionByTargetRoleAsync()
            };
        }

        public async Task<object> GetJobAnalyticsAsync(CancellationToken cancellationToken = default)
        {
            return new
            {
                TotalJobPostings = await _unitOfWork.Jobs.GetTotalJobsCountAsync(),
                TotalApplications = await _unitOfWork.JobAnalytics.GetTotalApplicationsAsync(),
                InterviewRate = await _unitOfWork.JobAnalytics.GetInterviewRateAsync(),
                HiringSuccessRate = await _unitOfWork.JobAnalytics.GetHiringSuccessRateAsync(),
                ByTypeAndLevel = await _unitOfWork.JobAnalytics.GetByTypeAndLevelAsync()
            };
        }

        public async Task<object> GetInternshipAnalyticsAsync(CancellationToken cancellationToken = default)
        {
            return new
            {
                ActivePrograms = await _unitOfWork.InternshipAnalytics.GetActiveProgramsAsync(),
                TotalApplicants = await _unitOfWork.InternshipAnalytics.GetTotalApplicantsAsync(),
                AcceptanceRate = await _unitOfWork.InternshipAnalytics.GetAcceptanceRateAsync(),
                ByDepartment = await _unitOfWork.InternshipAnalytics.GetByDepartmentAsync()
            };
        }

        public async Task<object> GetWorkshopAnalyticsAsync(CancellationToken cancellationToken = default)
        {
            return new
            {
                TotalWorkshops = await _unitOfWork.WorkshopAnalytics.GetTotalWorkshopsAsync(),
                TotalParticipants = await _unitOfWork.WorkshopAnalytics.GetTotalParticipantsAsync(),
                AttendanceRate = await _unitOfWork.WorkshopAnalytics.GetAttendanceRateAsync(),
                ByType = await _unitOfWork.WorkshopAnalytics.GetByTypeAsync()
            };
        }

        public async Task<object> GetEventAnalyticsAsync(CancellationToken cancellationToken = default)
        {
            return new
            {
                TotalEvents = await _unitOfWork.EventAnalytics.GetTotalEventsAsync(),
                TotalRegistrations = await _unitOfWork.EventAnalytics.GetTotalRegistrationsAsync(),
                AttendanceRate = await _unitOfWork.EventAnalytics.GetAttendanceRateAsync(),
                ByMode = await _unitOfWork.EventAnalytics.GetByModeAsync()
            };
        }

        public async Task<object> GetInterviewAnalyticsAsync(CancellationToken cancellationToken = default)
        {
            return new
            {
                TotalInterviews = await _unitOfWork.InterviewAnalytics.GetTotalInterviewsAsync(),
                AttendanceRate = await _unitOfWork.InterviewAnalytics.GetAttendanceRateAsync(),
                HiringRate = await _unitOfWork.InterviewAnalytics.GetHiringRateAsync(),
                CompletedCount = await _unitOfWork.InterviewAnalytics.GetCompletedCountAsync(),
                ScheduledCount = await _unitOfWork.InterviewAnalytics.GetScheduledCountAsync(),
                CompletionRateOverTime = await _unitOfWork.InterviewAnalytics.GetCompletionRateOverTimeAsync("monthly", DateTime.Now.Year)
            };
        }

        public async Task<object> GetInterviewCompletionRateOverTimeAsync(string period, int year, CancellationToken cancellationToken = default)
        {
            return await _unitOfWork.InterviewAnalytics.GetCompletionRateOverTimeAsync(period, year);
        }

        public async Task<object> GetUniversityAnalyticsAsync(CancellationToken cancellationToken = default)
        {
            return new
            {
                TotalActivePartners = await _unitOfWork.UniversityAnalytics.GetTotalActivePartnersAsync(),
                MostActiveCampus = await _unitOfWork.UniversityAnalytics.GetMostActiveCampusAsync(),
                NewPartnerships = await _unitOfWork.UniversityAnalytics.GetNewPartnershipsAsync(
                    DateTime.Now.Year,
                    (DateTime.Now.Month - 1) / 3 + 1)
            };
        }
    }
}