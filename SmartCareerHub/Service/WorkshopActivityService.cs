using Business_Logic.Errors;
using DataAccess.Abstractions;
using DataAccess.Entities.Workshop;
using DataAccess.IRepository;
using System.Collections.Generic;
using System.Threading.Tasks;

public class WorkshopActivityService : IWorkshopActivityService
{
    private readonly IUnitOfWork _unitOfWork;

    public WorkshopActivityService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<Result<WorkshopActivity>> AddActivityAsync(WorkshopActivity activity)
    {
        return await _unitOfWork.WorkshopActivities.AddAsync(activity);
    }

    public async Task<Result> UpdateActivityAsync(WorkshopActivity activity)
    {
        try
        {
            _unitOfWork.WorkshopActivities.Update(activity);

            var saved = await _unitOfWork.SaveChangesAsync();

            return saved > 0
                ? Result.Success()
                : Result.Failure(WorkshopErrors.WorkshopUpdateFailed);
        }
        catch
        {
            return Result.Failure(WorkshopErrors.WorkshopUpdateFailed);
        }
    }

    public async Task<Result> DeleteActivityAsync(int id)
    {
        var deleted = await _unitOfWork.WorkshopActivities.DeleteByIdAsync(id);

        return deleted
            ? Result.Success()
            : Result.Failure(WorkshopErrors.WorkshopDeleteFailed);
    }

    public async Task<Result<IEnumerable<WorkshopActivity>>> GetActivitiesByWorkshopIdAsync(int workshopId)
    {
        return await _unitOfWork.WorkshopActivities.GetByWorkshopIdAsync(workshopId);
    }
}
