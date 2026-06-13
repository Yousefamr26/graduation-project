using DataAccess.Entities.Workshop;
using DataAccess.Abstractions;
using System.Collections.Generic;
using System.Threading.Tasks;

public interface IWorkshopMaterialService
{
    Task<Result<WorkshopMaterial>> AddMaterialAsync(WorkshopMaterial material);
    Task<Result> UpdateMaterialAsync(WorkshopMaterial material);
    Task<Result> DeleteMaterialAsync(int id);
    Task<Result<IEnumerable<WorkshopMaterial>>> GetMaterialsByWorkshopIdAsync(int workshopId);
}
