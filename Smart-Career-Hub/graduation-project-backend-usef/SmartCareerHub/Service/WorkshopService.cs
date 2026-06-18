using DataAccess.Entities.Workshop;
using DataAccess.Abstractions;
using DataAccess.IRepository;
using Business_Logic.Errors;
using Mapster;
using SmartCareerHub.Contracts.Company.WorkShops;

public class WorkshopService : IWorkshopService
{
    private readonly IUnitOfWork _unitOfWork;

    public WorkshopService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    // =========================
    // Create
    // =========================
    public async Task<Result<WorkshopSec1>> CreateWorkshopAsync(
        WorkshopRequest request,
        string? companyId)
    {
        if (await _unitOfWork.Workshops.IsTitleExistsAsync(request.Title))
            return Result.Failure<WorkshopSec1>(WorkshopErrors.WorkshopTitleExists);

        var workshop = request.Adapt<WorkshopSec1>();
        workshop.Duration = "0";
        workshop.HostType = companyId != null ? "Company" : "University";
        workshop.CompanyId = companyId;
        workshop.UniversityId = request.UniversityId;
        workshop.CreatedAt = DateTime.UtcNow;
        workshop.UpdatedAt = DateTime.UtcNow;

        workshop.Materials = new List<WorkshopMaterial>();
        workshop.Activities = new List<WorkshopActivity>();

        var result = await _unitOfWork.Workshops.AddWorkshopAsync(workshop);
        if (result.IsFailure) return result;

        if (request.Materials != null)
            workshop.Materials = request.Materials.Adapt<List<WorkshopMaterial>>();

        if (request.Activities != null)
            workshop.Activities = request.Activities.Adapt<List<WorkshopActivity>>();

        return Result.Success(workshop);
    }

    // =========================
    // Update
    // =========================
    public async Task<Result> UpdateWorkshopAsync(int id, WorkshopRequest request)
    {
        var existingResult = await _unitOfWork.Workshops.GetByIdWithDetailsAsync(id);
        if (existingResult.IsFailure)
            return Result.Failure(existingResult.Error);

        var workshop = existingResult.Value;
        workshop.Title = request.Title;
        workshop.Description = request.Description;
        workshop.Location = request.Location;
        workshop.MaxCapacity = request.MaxCapacity;
        workshop.WorkshopType = request.WorkshopType;
        workshop.RequireCV = request.RequireCV;
        workshop.RequireRoadmapCompletion = request.RequireRoadmapCompletion;
        workshop.IsPublished = request.IsPublished;
        workshop.UpdatedAt = DateTime.UtcNow;

        return await _unitOfWork.Workshops.UpdateAsync(workshop);
    }

    // =========================
    // Delete
    // =========================
    public async Task<Result> DeleteWorkshopAsync(int id)
        => await _unitOfWork.Workshops.DeleteAsync(id);

    // =========================
    // Get By Id
    // =========================
    public async Task<Result<WorkshopSec1>> GetWorkshopByIdAsync(int id)
        => await _unitOfWork.Workshops.GetByIdWithDetailsAsync(id);

    // =========================
    // Get All
    // =========================
    public async Task<Result<PagedResponse<WorkshopSec1>>> GetAllWorkshopsAsync(
        QueryParameters query)
    {
        var result = await _unitOfWork.Workshops.GetAllWithDetailsAsync();
        if (result.IsFailure)
            return Result.Failure<PagedResponse<WorkshopSec1>>(result.Error);

        var workshops = result.Value.AsEnumerable();

        // Filtering
        if (!string.IsNullOrWhiteSpace(query.Search))
            workshops = workshops.Where(w =>
                w.Title.Contains(query.Search, StringComparison.OrdinalIgnoreCase) ||
                w.Description.Contains(query.Search, StringComparison.OrdinalIgnoreCase) ||
                w.Location.Contains(query.Search, StringComparison.OrdinalIgnoreCase));

        // Sorting
        workshops = query.SortBy?.ToLower() switch
        {
            "title" => query.SortDirection == "asc"
                ? workshops.OrderBy(w => w.Title)
                : workshops.OrderByDescending(w => w.Title),
            "points" => query.SortDirection == "asc"
                ? workshops.OrderBy(w => w.TotalPoints)
                : workshops.OrderByDescending(w => w.TotalPoints),
            _ => workshops.OrderByDescending(w => w.CreatedAt)
        };

        return Result.Success(
            PagedResponse<WorkshopSec1>.Create(workshops, query.Page, query.PageSize));
    }

    // =========================
    // Search
    // =========================
    public async Task<Result<PagedResponse<WorkshopSec1>>> SearchWorkshopsAsync(
        string searchTerm,
        QueryParameters query)
    {
        var result = await _unitOfWork.Workshops.SearchWorkshopsAsync(searchTerm);
        if (result.IsFailure)
            return Result.Failure<PagedResponse<WorkshopSec1>>(result.Error);

        var workshops = result.Value.AsEnumerable();

        // Sorting
        workshops = query.SortBy?.ToLower() switch
        {
            "title" => query.SortDirection == "asc"
                ? workshops.OrderBy(w => w.Title)
                : workshops.OrderByDescending(w => w.Title),
            "points" => query.SortDirection == "asc"
                ? workshops.OrderBy(w => w.TotalPoints)
                : workshops.OrderByDescending(w => w.TotalPoints),
            _ => workshops.OrderByDescending(w => w.CreatedAt)
        };

        return Result.Success(
            PagedResponse<WorkshopSec1>.Create(workshops, query.Page, query.PageSize));
    }
}