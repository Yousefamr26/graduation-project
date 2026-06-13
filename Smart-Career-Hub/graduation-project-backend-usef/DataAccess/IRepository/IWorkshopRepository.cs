using DataAccess.Abstractions;
using DataAccess.Entities.Workshop;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DataAccess.IRepository
{
    public interface IWorkshopRepository : IGenericRepository<WorkshopSec1>
    {
       
        Task<Result<WorkshopSec1>> GetByIdWithDetailsAsync(int id);
        Task<Result<IEnumerable<WorkshopSec1>>> GetAllWithDetailsAsync();
        Task<Result<IEnumerable<WorkshopSec1>>> GetByUniversityAsync(int universityId);
        Task<Result<IEnumerable<WorkshopSec1>>> SearchWorkshopsAsync(string searchTerm);
        Task<Result<IEnumerable<WorkshopSec1>>> GetPublishedWorkshopsAsync();

       
        Task<Result<WorkshopSec1>> AddWorkshopAsync(WorkshopSec1 workshop);
        Task<Result> UpdateAsync(WorkshopSec1 workshop);
        Task<Result> DeleteAsync(int id);
        Task<Result> BulkDeleteAsync(List<int> ids);

        Task<Result> ToggleStatusAsync(int id);
        Task<Result> BulkUpdateStatusAsync(List<int> ids, bool isPublished);

        Task<bool> IsTitleExistsAsync(string title, int? excludeId = null);
        Task<Result<List<WorkshopSec1>>> GetLatestWorkshopsAsync(int count);
        Task<Result<List<WorkshopSec1>>> GetTopWorkshopsByPointsAsync(int count);
    }
}
