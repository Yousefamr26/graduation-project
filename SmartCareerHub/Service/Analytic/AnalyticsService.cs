using Business_Logic.IService;
using DataAccess.IRepository;
using SmartCareerHub.Contracts.Company.WorkShops;
using System.Threading;
using System.Threading.Tasks;

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
                TotalRoadmaps = await _unitOfWork.RoadmapAnalytics.GetTotalRoadmapsAsync(),
                TotalWorkshopParticipants = await _unitOfWork.WorkshopAnalytics.GetTotalParticipantsAsync(),
                TotalEventParticipants = await _unitOfWork.EventAnalytics.GetTotalParticipantsAsync(),
                TotalInterviewsCompleted = await _unitOfWork.InterviewAnalytics.GetCompletedCountAsync()
            };
        }

        public async Task<object> GetInterviewAnalyticsAsync(CancellationToken cancellationToken = default)
        {
            var completed = await _unitOfWork.InterviewAnalytics.GetCompletedCountAsync();
            var scheduled = await _unitOfWork.InterviewAnalytics.GetScheduledCountAsync();
            var byTime = await _unitOfWork.InterviewAnalytics.GetCompletionRateOverTimeAsync("monthly", System.DateTime.Now.Year);

            return new InterviewAnalyticsResponse(
                CompletedCount: completed,
                ScheduledCount: scheduled,
                CompletionRateOverTime: byTime
            );
        }

        public async Task<object> GetInterviewCompletionRateOverTimeAsync(string period, int year, CancellationToken cancellationToken = default)
        {
            var data = await _unitOfWork.InterviewAnalytics.GetCompletionRateOverTimeAsync(period, year);
            return data;
        }

        public async Task<object> GetRoadmapAnalyticsAsync(CancellationToken cancellationToken = default)
        {
            var total = await _unitOfWork.RoadmapAnalytics.GetTotalRoadmapsAsync();
            var distribution = await _unitOfWork.RoadmapAnalytics.GetDistributionByTargetRoleAsync();

            return new RoadmapAnalyticsResponse(
                TotalRoadmaps: total,
                DistributionByTargetRole: distribution
            );
        }

        public async Task<object> GetWorkshopAnalyticsAsync(CancellationToken cancellationToken = default)
        {
            var total = await _unitOfWork.WorkshopAnalytics.GetTotalParticipantsAsync();
            var byType = await _unitOfWork.WorkshopAnalytics.GetByTypeAsync();

            return new WorkshopAnalyticsResponse(
                TotalParticipants: total,
                ByType: byType
            );
        }

        public async Task<object> GetEventAnalyticsAsync(CancellationToken cancellationToken = default)
        {
            var total = await _unitOfWork.EventAnalytics.GetTotalParticipantsAsync();
            var byMode = await _unitOfWork.EventAnalytics.GetByModeAsync();

            return new EventAnalyticsResponse(
                TotalParticipants: total,
                ByMode: byMode
            );
        }

        public async Task<object> GetJobAnalyticsAsync(CancellationToken cancellationToken = default)
        {
            var byTypeAndLevel = await _unitOfWork.JobAnalytics.GetByTypeAndLevelAsync();
            return new JobAnalyticsResponse(
                ByTypeAndLevel: byTypeAndLevel
            );
        }
    }
}
