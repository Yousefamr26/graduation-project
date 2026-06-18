using DataAccess.Entities.Workshop;
using DataAccess.Abstractions;
using System.Collections.Generic;
using System.Threading.Tasks;

public interface IWorkshopActivityService
{
    Task<Result<WorkshopActivity>> AddActivityAsync(WorkshopActivity activity);
    Task<Result> UpdateActivityAsync(WorkshopActivity activity);
    Task<Result> DeleteActivityAsync(int id);
    Task<Result<IEnumerable<WorkshopActivity>>> GetActivitiesByWorkshopIdAsync(int workshopId);
}
