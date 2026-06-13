using DataAccess.Abstractions;
using DataAccess.Entities.Workshop;
using DataAccess.IRepository;

public interface IWorkshopMaterialRepository : IGenericRepository<WorkshopMaterial>
{
    Task<Result<IEnumerable<WorkshopMaterial>>> GetByWorkshopIdAsync(int workshopId);
    Task<Result<WorkshopMaterial>> AddAsync(WorkshopMaterial material);
    Task<Result> UpdateAsync(WorkshopMaterial material);
    Task<Result> DeleteAsync(int id);
}
