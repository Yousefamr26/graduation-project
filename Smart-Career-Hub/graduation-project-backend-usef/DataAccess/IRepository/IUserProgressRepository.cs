using DataAccess.Abstractions;
using DataAccess.Entities.RoadMap;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataAccess.IRepository
{

    public interface IuserProgressRepository : IGenericRepository<UserProgress>
    {
        Task<Result<UserProgress>> GetByIdAsync(int id);
        Task<Result<IEnumerable<UserProgress>>> GetAllByStudentRoadmapIdAsync(int studentRoadmapId);
        Task<Result> MarkAsCompletedAsync(int studentProgressId);
        Task<Result> UpdatePointsAsync(int studentProgressId, int points);
    }
}
