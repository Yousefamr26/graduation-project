using DataAccess.Abstractions;
using DataAccess.Entities.Workshop;
using SmartCareerHub.Contracts.Company.WorkShops;

public interface IWorkshopService
{
    Task<Result<WorkshopSec1>> CreateWorkshopAsync(
        WorkshopRequest request,
        string? companyId);

    Task<Result> UpdateWorkshopAsync(
        int id,
        WorkshopRequest request);

    Task<Result> DeleteWorkshopAsync(int id);

    Task<Result<WorkshopSec1>> GetWorkshopByIdAsync(int id);

    Task<Result<PagedResponse<WorkshopSec1>>> GetAllWorkshopsAsync(
        QueryParameters query);

    Task<Result<PagedResponse<WorkshopSec1>>> SearchWorkshopsAsync(
        string searchTerm,
        QueryParameters query);
}