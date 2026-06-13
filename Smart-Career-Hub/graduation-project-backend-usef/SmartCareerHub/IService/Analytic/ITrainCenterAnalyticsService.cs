using SmartCareerHub.Contracts.Analytics;

namespace Business_Logic.IService;

public interface ITrainCenterAnalyticsService
{
    Task<TrainCenterAnalyticsFullResponse> GetFullAnalyticsAsync(int trainingCenterId);
    Task<TrainCenterSummaryResponse> GetSummaryAsync(int trainingCenterId);
    Task<IEnumerable<TrainCenterAttendanceResponse>> GetAttendanceOverTimeAsync(int trainingCenterId, int months = 6);
    Task<IEnumerable<TrainCenterCourseCompletionResponse>> GetCourseCompletionRatesAsync(int trainingCenterId);
    Task<TrainCenterPerformanceResponse> GetPerformanceDistributionAsync(int trainingCenterId);
    Task<IEnumerable<TrainCenterMonthlyEnrollmentResponse>> GetMonthlyEnrollmentVsCompletionAsync(int trainingCenterId, int months = 6);
}