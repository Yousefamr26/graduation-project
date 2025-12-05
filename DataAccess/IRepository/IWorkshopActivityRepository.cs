using DataAccess.Abstractions;
using DataAccess.Entities.Workshop;
using DataAccess.IRepository;

public interface IWorkshopActivityRepository : IGenericRepository<WorkshopActivity>
{
    Task<Result<IEnumerable<WorkshopActivity>>> GetByWorkshopIdAsync(int workshopId);
    Task<Result<WorkshopActivity>> AddAsync(WorkshopActivity activity);
    Task<Result> UpdateAsync(WorkshopActivity activity);
    Task<Result> DeleteAsync(int id);
}
