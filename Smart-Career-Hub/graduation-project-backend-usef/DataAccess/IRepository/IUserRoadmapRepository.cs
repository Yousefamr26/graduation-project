using DataAccess.Entities.Users;
using DataAccess.Entities.RoadMap;
using System.Collections.Generic;
using System.Threading.Tasks;
using DataAccess.Entities;
using DataAccess.Abstractions;
using System;

namespace DataAccess.IRepository
{
    public interface IUserRoadmapRepository : IGenericRepository<UserRoadmap>
    {
        Task<Result<UserRoadmap>> GetByIdWithProgressAsync(int id);

        // بدل Guid → string
        Task<Result<IEnumerable<UserRoadmap>>> GetAllByUserIdAsync(string userId);

        Task<Result<UserRoadmap>> JoinRoadmapAsync(string userId, int roadmapId);

        Task<Result> UpdateProgressAsync(UserProgress progress);

        Task<Result<IEnumerable<UserProgress>>> GetProgressByUserRoadmapIdAsync(int userRoadmapId);

        Task<Result<int>> GetTotalPointsAsync(string userId);

        Task<Result<double>> GetProgressPercentAsync(string userId, int roadmapId);

        Task<bool> IsJoinedAsync(string userId, int roadmapId);

        Task<List<UserRoadmap>> GetByUserIdAsync(string userId);

        Task<UserRoadmap?> GetByUserIdAndRoadmapAsync(string userId, int roadmapId);
        // ===== في IUserRoadmapRepository =====
        Task<Result> AddOrUpdateProgressAsync(UserProgress progress);
        Task<IEnumerable<UserRoadmap>> GetByRoadmapIdAsync(int roadmapId);

    }
}
