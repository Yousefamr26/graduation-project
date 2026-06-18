using DataAccess.Entities.Events;
using System.Collections.Generic;
using System.Threading.Tasks;

public interface IEventAnalyticsRepository
{
    Task<int> GetTotalParticipantsAsync();
    Task<Dictionary<string, int>> GetByModeAsync();
    Task<int> GetTotalEventsAsync();
    Task<int> GetTotalRegistrationsAsync();
    Task<double> GetAttendanceRateAsync();
}
