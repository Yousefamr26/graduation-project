using DataAccess.Entities.Workshop;
using System.Collections.Generic;
using System.Threading.Tasks;

public interface IWorkshopAnalyticsRepository
{
    Task<int> GetTotalParticipantsAsync();
    Task<Dictionary<string, int>> GetByTypeAsync();
}
