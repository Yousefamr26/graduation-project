using DataAccess.Entities.Workshop;
using DataAccess.Abstractions;
using System.Collections.Generic;
using System.Threading.Tasks;

public interface IWorkshopService
{
    Task<Result<WorkshopSec1>> CreateWorkshopAsync(WorkshopSec1 workshop);
    Task<Result> UpdateWorkshopAsync(WorkshopSec1 workshop);
    Task<Result> DeleteWorkshopAsync(int id);
    Task<Result<WorkshopSec1>> GetWorkshopByIdAsync(int id);
    Task<Result<IEnumerable<WorkshopSec1>>> GetAllWorkshopsAsync();
    Task<Result<IEnumerable<WorkshopSec1>>> SearchWorkshopsAsync(string searchTerm);
}
