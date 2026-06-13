using DataAccess.IRepository;
using Mapster;
using Microsoft.AspNetCore.Mvc;
using SmartCareerHub.Contracts.Company.WorkShops; 
using System.Threading;
using System.Threading.Tasks;

namespace SmartCareerHub.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AnalyticsController : ControllerBase
    {
        private readonly IUnitOfWork _unitOfWork;

        public AnalyticsController(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        [HttpGet("dashboard-overview")]
        public async Task<IActionResult> GetDashboardOverview(CancellationToken cancellationToken)
        {
            var roadmapData = new
            {
                TotalRoadmaps = await _unitOfWork.RoadmapAnalytics.GetTotalRoadmapsAsync(),
                DistributionByTargetRole = await _unitOfWork.RoadmapAnalytics.GetDistributionByTargetRoleAsync()
            }.Adapt<RoadmapAnalyticsResponse>();

            var workshopData = new
            {
                TotalParticipants = await _unitOfWork.WorkshopAnalytics.GetTotalParticipantsAsync(),
                ByType = await _unitOfWork.WorkshopAnalytics.GetByTypeAsync()
            }.Adapt<WorkshopAnalyticsResponse>();

            var eventData = new
            {
                TotalParticipants = await _unitOfWork.EventAnalytics.GetTotalParticipantsAsync(),
                ByMode = await _unitOfWork.EventAnalytics.GetByModeAsync()
            }.Adapt<EventAnalyticsResponse>();

            var jobData = new
            {
                ByTypeAndLevel = await _unitOfWork.JobAnalytics.GetByTypeAndLevelAsync()
            }.Adapt<JobAnalyticsResponse>();

            var interviewData = new
            {
                CompletedCount = await _unitOfWork.InterviewAnalytics.GetCompletedCountAsync(),
                ScheduledCount = await _unitOfWork.InterviewAnalytics.GetScheduledCountAsync(),
                CompletionRateOverTime = await _unitOfWork.InterviewAnalytics.GetCompletionRateOverTimeAsync("month", System.DateTime.Now.Year)
            }.Adapt<InterviewAnalyticsResponse>();

            var result = new
            {
                Roadmap = roadmapData,
                Workshop = workshopData,
                Event = eventData,
                Job = jobData,
                Interview = interviewData
            };

            return Ok(result);
        }

        [HttpGet("roadmaps")]
        public async Task<IActionResult> GetRoadmapAnalytics(CancellationToken cancellationToken)
        {
            var roadmapData = new
            {
                TotalRoadmaps = await _unitOfWork.RoadmapAnalytics.GetTotalRoadmapsAsync(),
                DistributionByTargetRole = await _unitOfWork.RoadmapAnalytics.GetDistributionByTargetRoleAsync()
            }.Adapt<RoadmapAnalyticsResponse>();

            return Ok(roadmapData);
        }

        [HttpGet("workshops")]
        public async Task<IActionResult> GetWorkshopAnalytics(CancellationToken cancellationToken)
        {
            var workshopData = new
            {
                TotalParticipants = await _unitOfWork.WorkshopAnalytics.GetTotalParticipantsAsync(),
                ByType = await _unitOfWork.WorkshopAnalytics.GetByTypeAsync()
            }.Adapt<WorkshopAnalyticsResponse>();

            return Ok(workshopData);
        }

        [HttpGet("events")]
        public async Task<IActionResult> GetEventAnalytics(CancellationToken cancellationToken)
        {
            var eventData = new
            {
                TotalParticipants = await _unitOfWork.EventAnalytics.GetTotalParticipantsAsync(),
                ByMode = await _unitOfWork.EventAnalytics.GetByModeAsync()
            }.Adapt<EventAnalyticsResponse>();

            return Ok(eventData);
        }

        [HttpGet("jobs")]
        public async Task<IActionResult> GetJobAnalytics(CancellationToken cancellationToken)
        {
            var jobData = new
            {
                ByTypeAndLevel = await _unitOfWork.JobAnalytics.GetByTypeAndLevelAsync()
            }.Adapt<JobAnalyticsResponse>();

            return Ok(jobData);
        }

        [HttpGet("interviews")]
        public async Task<IActionResult> GetInterviewAnalytics(CancellationToken cancellationToken)
        {
            var interviewData = new
            {
                CompletedCount = await _unitOfWork.InterviewAnalytics.GetCompletedCountAsync(),
                ScheduledCount = await _unitOfWork.InterviewAnalytics.GetScheduledCountAsync(),
                CompletionRateOverTime = await _unitOfWork.InterviewAnalytics.GetCompletionRateOverTimeAsync("month", System.DateTime.Now.Year)
            }.Adapt<InterviewAnalyticsResponse>();

            return Ok(interviewData);
        }
    }
}
