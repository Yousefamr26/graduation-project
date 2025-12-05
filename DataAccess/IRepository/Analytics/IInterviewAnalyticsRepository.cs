using DataAccess.Entities.Interview;
using System.Collections.Generic;
using System.Threading.Tasks;

public interface IInterviewAnalyticsRepository
{
    Task<int> GetCompletedCountAsync();
    Task<int> GetScheduledCountAsync();
    Task<Dictionary<string, int>> GetCompletionRateOverTimeAsync(string period, int year);
}
