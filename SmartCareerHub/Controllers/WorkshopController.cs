using Business_Logic.Errors;
using DataAccess.Abstractions;
using DataAccess.Entities.Workshop;
using DataAccess.IRepository;
using Mapster;
using Microsoft.AspNetCore.Mvc;
using SmartCareerHub.Contracts.Company.WorkShops;
using SmartCareerHub.Extensions;

namespace SmartCareerHub.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class WorkshopsController : ControllerBase
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly string _rootPath;

        public WorkshopsController(IUnitOfWork unitOfWork, IWebHostEnvironment env)
        {
            _unitOfWork = unitOfWork;
            _rootPath = Path.Combine(env.WebRootPath ?? "wwwroot", "uploads", "workshops");

            foreach (var folder in new[] { "", "covers", "materials", "activities" })
            {
                var path = Path.Combine(_rootPath, folder);
                if (!Directory.Exists(path))
                    Directory.CreateDirectory(path);
            }
        }

        private WorkshopSec1 PrepareForJson(WorkshopSec1 w)
        {
            if (w.Activities != null) foreach (var a in w.Activities) a.Workshop = null;
            if (w.Materials != null) foreach (var m in w.Materials) m.Workshop = null;
            if (w.University != null) w.University.Workshops = null;
            return w;
        }

        private async Task<string> SaveFileAsync(IFormFile file, string subFolder)
        {
            var folder = Path.Combine(_rootPath, subFolder);
            if (!Directory.Exists(folder))
                Directory.CreateDirectory(folder);

            var name = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
            var path = Path.Combine(folder, name);

            using var stream = new FileStream(path, FileMode.Create);
            await file.CopyToAsync(stream);

            return $"/uploads/workshops/{subFolder}/{name}";
        }

        private async Task RecalculateTotalsAsync(int workshopId)
        {
            var result = await _unitOfWork.Workshops.GetByIdWithDetailsAsync(workshopId);
            if (result.IsFailure) return;

            var w = result.Value;

            w.TotalPoints =
                (w.Activities?.Sum(a => a.Points) ?? 0) +
                (w.Materials?.Sum(m => m.Points) ?? 0);

            w.TotalMaterials = w.Materials?.Count ?? 0;
            w.TotalActivities = w.Activities?.Count ?? 0;

            await _unitOfWork.Workshops.UpdateAsync(w);
            await _unitOfWork.SaveChangesAsync();
        }

        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _unitOfWork.Workshops.GetByIdWithDetailsAsync(id);
            if (result.IsFailure)
                return Result.Failure<WorkshopSec1>(WorkshopErrors.WorkshopNotFound).ToActionResult();

            return Result.Success(PrepareForJson(result.Value)).ToActionResult();
        }

        [HttpGet]
        public async Task<IActionResult> GetAll([FromQuery] bool includeDisabled = false)
        {
            var result = includeDisabled
                ? await _unitOfWork.Workshops.GetAllWithDetailsAsync()
                : await _unitOfWork.Workshops.GetPublishedWorkshopsAsync();

            if (result.IsFailure)
                return result.ToActionResult();

            var prepared = result.Value.Select(PrepareForJson);
            return Result.Success(prepared).ToActionResult();
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromForm] WorkshopRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Title))
                return Result.Failure<WorkshopSec1>(WorkshopErrors.WorkshopInvalidRequest).ToActionResult();

            await _unitOfWork.BeginTransactionAsync();
            try
            {
                var workshop = request.Adapt<WorkshopSec1>();
                workshop.CreatedAt = DateTime.UtcNow;
                workshop.UpdatedAt = DateTime.UtcNow;

                workshop.BannerUrl = request.Banner != null
                    ? await SaveFileAsync(request.Banner, "covers")
                    : "/uploads/workshops/default.jpg";

                await _unitOfWork.Workshops.AddAsync(workshop);
                await _unitOfWork.SaveChangesAsync();

                // Activities
                if (request.Activities?.Any() == true)
                {
                    foreach (var act in request.Activities)
                    {
                        var activity = act.Adapt<WorkshopActivity>();
                        activity.WorkshopId = workshop.Id;
                        activity.CreatedAt = DateTime.UtcNow;
                        await _unitOfWork.WorkshopActivities.AddAsync(activity);
                    }
                    await _unitOfWork.SaveChangesAsync();
                }

                // Materials
                if (request.Materials?.Any() == true)
                {
                    foreach (var m in request.Materials)
                    {
                        var mat = m.Adapt<WorkshopMaterial>();
                        mat.WorkshopId = workshop.Id;
                        mat.CreatedAt = DateTime.UtcNow;

                        if (m.FilePath != null)
                            mat.FileUrl = await SaveFileAsync(m.FilePath, "materials");

                        if (string.IsNullOrWhiteSpace(mat.Title))
                            mat.Title = m.Type switch
                            {
                                "Video" => "Untitled Video",
                                "PDF" => "Untitled PDF",
                                "Assignment" => "Untitled Assignment",
                                _ => "Untitled Material"
                            };

                        await _unitOfWork.WorkshopMaterials.AddAsync(mat);
                    }
                    await _unitOfWork.SaveChangesAsync();
                }

                await RecalculateTotalsAsync(workshop.Id);
                await _unitOfWork.CommitTransactionAsync();

                var fullResult = await _unitOfWork.Workshops.GetByIdWithDetailsAsync(workshop.Id);
                if (fullResult.IsFailure) return fullResult.ToActionResult();

                return Result.Success(PrepareForJson(fullResult.Value))
                             .ToCreatedResult(nameof(GetById), new { id = workshop.Id });
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync();
                return Result.Failure<WorkshopSec1>(new Error("Workshop.CreateFailed", ex.Message))
                             .ToActionResult();
            }
        }

        [HttpPut("{id:int}")]
        public async Task<IActionResult> Update(int id, [FromForm] WorkshopRequest request)
        {
            var existing = await _unitOfWork.Workshops.GetByIdWithDetailsAsync(id);
            if (existing.IsFailure)
                return Result.Failure<WorkshopSec1>(WorkshopErrors.WorkshopNotFound).ToActionResult();

            await _unitOfWork.BeginTransactionAsync();
            try
            {
                var workshop = existing.Value;

                workshop.Title = request.Title;
                workshop.Description = request.Description;
                workshop.UniversityId = request.UniversityId;
                workshop.Location = request.Location;
                workshop.MaxCapacity = request.MaxCapacity;
                workshop.WorkshopType = request.WorkshopType;
                workshop.RequireCV = request.RequireCV;
                workshop.RequireRoadmapCompletion = request.RequireRoadmapCompletion;
                workshop.IsPublished = request.IsPublished;
                workshop.UpdatedAt = DateTime.UtcNow;

                if (request.Banner != null)
                    workshop.BannerUrl = await SaveFileAsync(request.Banner, "covers");

                var updateResult = await _unitOfWork.Workshops.UpdateAsync(workshop);
                if (updateResult.IsFailure)
                {
                    await _unitOfWork.RollbackTransactionAsync();
                    return updateResult.ToActionResult();
                }

                await _unitOfWork.SaveChangesAsync();
                await RecalculateTotalsAsync(workshop.Id);
                await _unitOfWork.CommitTransactionAsync();

                var refreshed = await _unitOfWork.Workshops.GetByIdWithDetailsAsync(id);
                if (refreshed.IsFailure) return refreshed.ToActionResult();

                return Result.Success(PrepareForJson(refreshed.Value)).ToActionResult();
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync();
                return Result.Failure<WorkshopSec1>(new Error("Workshop.UpdateFailed", ex.Message))
                             .ToActionResult();
            }
        }

        [HttpPatch("toggle/{id:int}")]
        public async Task<IActionResult> ToggleStatus(int id)
        {
            var result = await _unitOfWork.Workshops.ToggleStatusAsync(id);
            return result.ToActionResult();
        }

        [HttpPatch("bulkstatus")]
        public async Task<IActionResult> BulkStatus([FromQuery] bool isPublished, [FromBody] List<int> ids)
        {
            if (ids == null || !ids.Any())
                return Result.Failure<IEnumerable<WorkshopSec1>>(WorkshopErrors.WorkshopNoIdsProvided).ToActionResult();

            var result = await _unitOfWork.Workshops.BulkUpdateStatusAsync(ids, isPublished);
            return Result.Success(new { updatedCount = ids.Count, success = result }).ToActionResult();
        }

        [HttpDelete("{id:int}")]
        public async Task<IActionResult> Delete(int id)
        {
            var result = await _unitOfWork.Workshops.DeleteAsync(id);
            return result.ToActionResult();
        }

        [HttpDelete("bulkdelete")]
        public async Task<IActionResult> BulkDelete([FromBody] List<int> ids)
        {
            if (ids == null || !ids.Any())
                return Result.Failure<IEnumerable<WorkshopSec1>>(WorkshopErrors.WorkshopNoIdsProvided).ToActionResult();

            var result = await _unitOfWork.Workshops.BulkDeleteAsync(ids);
            return Result.Success(new { deletedCount = ids.Count, success = result }).ToActionResult();
        }
    }
}
