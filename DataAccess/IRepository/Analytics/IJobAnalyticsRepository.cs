using DataAccess.Entities.Job;
using System.Collections.Generic;
using System.Threading.Tasks;

public interface IJobAnalyticsRepository
{
    Task<Dictionary<string, int>> GetByTypeAndLevelAsync();
}
