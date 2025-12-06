using DataAccess.Entities.Workshop;
using DataAccess.Abstractions;
using DataAccess.IRepository;
using System.Collections.Generic;
using System.Threading.Tasks;
using Business_Logic.Errors;

public class WorkshopService : IWorkshopService
{
    private readonly IUnitOfWork _unitOfWork;

    public WorkshopService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<Result<WorkshopSec1>> CreateWorkshopAsync(WorkshopSec1 workshop)
    {
        if (await _unitOfWork.Workshops.IsTitleExistsAsync(workshop.Title))
            return Result.Failure<WorkshopSec1>(WorkshopErrors.WorkshopTitleExists);

        return await _unitOfWork.Workshops.AddWorkshopAsync(workshop);
    }

    public async Task<Result> UpdateWorkshopAsync(WorkshopSec1 workshop)
        => await _unitOfWork.Workshops.UpdateAsync(workshop);

    public async Task<Result> DeleteWorkshopAsync(int id)
        => await _unitOfWork.Workshops.DeleteAsync(id);

    public async Task<Result<WorkshopSec1>> GetWorkshopByIdAsync(int id)
        => await _unitOfWork.Workshops.GetByIdWithDetailsAsync(id);

    public async Task<Result<IEnumerable<WorkshopSec1>>> GetAllWorkshopsAsync()
        => await _unitOfWork.Workshops.GetAllWithDetailsAsync();

    public async Task<Result<IEnumerable<WorkshopSec1>>> SearchWorkshopsAsync(string searchTerm)
        => await _unitOfWork.Workshops.SearchWorkshopsAsync(searchTerm);
}
