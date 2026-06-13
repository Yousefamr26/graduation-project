using DataAccess.Entities.Workshop;
using DataAccess.Abstractions;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DataAccess.IRepository
{
    public interface IActivityRepository : IGenericRepository<WorkshopActivity>
    {
        Task<Result<WorkshopActivity>> GetByIdAsync(int id);
        Task<Result<IEnumerable<WorkshopActivity>>> GetByWorkshopIdAsync(int workshopId);

        Task<Result<WorkshopActivity>> AddActivityAsync(WorkshopActivity activity);
        Task<Result> UpdateAsync(WorkshopActivity activity);
        Task<Result> DeleteAsync(int id);
        Task<Result> BulkDeleteAsync(List<int> ids);
    }
}
