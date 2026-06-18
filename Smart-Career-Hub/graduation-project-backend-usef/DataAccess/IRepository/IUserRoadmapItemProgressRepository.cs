using DataAccess.Entities.RoadMap;
using System;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace DataAccess.IRepository
{
    public interface IUserRoadmapItemProgressRepository
    {
        Task<UserRoadmapItemProgress?> GetAsync(string userId, int roadmapId, int itemId, string itemType);
        Task AddAsync(UserRoadmapItemProgress entity);
        Task<int> CountCompletedAsync(string userId, int roadmapId);
        Task<IEnumerable<UserRoadmapItemProgress>> GetAllByStudentAndRoadmapAsync(string userId, int roadmapId);
    }
}
