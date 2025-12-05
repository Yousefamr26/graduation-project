using DataAccess.Entities.RoadMap;
using System.Collections.Generic;
using System.Threading.Tasks;

public interface IRoadmapAnalyticsRepository
{
    Task<int> GetTotalRoadmapsAsync();
    Task<Dictionary<string, int>> GetDistributionByTargetRoleAsync();
}
