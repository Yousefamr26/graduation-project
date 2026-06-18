using DataAccess.Entities.Workshop;
using DataAccess.Abstractions;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DataAccess.IRepository
{
    public interface IMaterialRepository : IGenericRepository<WorkshopMaterial>
    {
        Task<Result<WorkshopMaterial>> GetByIdAsync(int id);
        Task<Result<IEnumerable<WorkshopMaterial>>> GetByWorkshopIdAsync(int workshopId);

        Task<Result<WorkshopMaterial>> AddMaterialAsync(WorkshopMaterial material);
        Task<Result> UpdateAsync(WorkshopMaterial material);
        Task<Result> DeleteAsync(int id);
        Task<Result> BulkDeleteAsync(List<int> ids);
    }
}
