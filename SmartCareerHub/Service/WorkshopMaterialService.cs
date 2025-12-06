using Business_Logic.Errors;
using DataAccess.Abstractions;
using DataAccess.Entities.Workshop;
using DataAccess.IRepository;
using System.Collections.Generic;
using System.Threading.Tasks;

public class WorkshopMaterialService : IWorkshopMaterialService
{
    private readonly IUnitOfWork _unitOfWork;

    public WorkshopMaterialService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<Result<WorkshopMaterial>> AddMaterialAsync(WorkshopMaterial material)
    {
        return await _unitOfWork.WorkshopMaterials.AddAsync(material);
    }

    public async Task<Result> UpdateMaterialAsync(WorkshopMaterial material)
    {
        try
        {
            _unitOfWork.WorkshopMaterials.Update(material);
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

    public async Task<Result> DeleteMaterialAsync(int id)
    {
        var deleted = await _unitOfWork.WorkshopMaterials.DeleteByIdAsync(id);

        return deleted
            ? Result.Success()
            : Result.Failure(WorkshopErrors.WorkshopDeleteFailed);
    }

    public async Task<Result<IEnumerable<WorkshopMaterial>>> GetMaterialsByWorkshopIdAsync(int workshopId)
    {
        return await _unitOfWork.WorkshopMaterials.GetByWorkshopIdAsync(workshopId);
    }
}
