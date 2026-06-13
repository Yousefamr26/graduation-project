using Business_Logic.Errors;
using DataAccess.Abstractions;
using DataAccess.Entities.Workshop;
using DataAccess.IRepository;
using Mapster;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartCareerHub.Contracts.Company.WorkShops;
using SmartCareerHub.Extensions;
using System.Security.Claims;

namespace SmartCareerHub.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class WorkshopsController : ControllerBase
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IWorkshopService _workshopService;
        private readonly string _rootPath;

        public WorkshopsController(
            IUnitOfWork unitOfWork,
            IWorkshopService workshopService,
            IWebHostEnvironment env)
        {
            _unitOfWork = unitOfWork;
            _workshopService = workshopService;
            _rootPath = Path.Combine(env.WebRootPath ?? "wwwroot", "uploads", "workshops");

            foreach (var folder in new[] { "", "covers", "materials", "activities" })
            {
                var path = Path.Combine(_rootPath, folder);
                if (!Directory.Exists(path))
                    Directory.CreateDirectory(path);
            }
        }

        private WorkshopResponse PrepareForJson(WorkshopSec1 w)
        {
            var materials = w.Materials?.Select(m => new MaterialResponse(
                m.Id,
                m.Type,
                m.Title,
                m.FileUrl,
                m.Duration,
                m.PageCount,
                m.Points,
                m.CreatedAt
            )).ToList() ?? new List<MaterialResponse>();

            var activities = w.Activities?.Select(a => new ActivityResponse(
                a.Id.ToString(),
                a.Name,
                a.Description,
                a.Difficulty,
                a.Points,
                a.CreatedAt
            )).ToList() ?? new List<ActivityResponse>();

            return new WorkshopResponse(
                Id: w.Id,
                Title: w.Title,
                Description: w.Description,
                BannerUrl: w.BannerUrl,
                HostType: w.HostType,
                UniversityId: w.UniversityId,
                UniversityName: w.University?.Name,
                CompanyId: w.CompanyId,
                CompanyName: w.Company?.OrganizationName,
                Location: w.Location,
                MaxCapacity: w.MaxCapacity,
                WorkshopType: w.WorkshopType,
                TotalPoints: w.TotalPoints,
                RequireCV: w.RequireCV,
                RequireRoadmapCompletion: w.RequireRoadmapCompletion,
                IsPublished: w.IsPublished,
                CreatedAt: w.CreatedAt,
                UpdatedAt: w.UpdatedAt,
                Materials: materials,
                Activities: activities
            );
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

        private string? GetCompanyIdFromClaims()
        {
            if (User.IsInRole("Company"))
                return User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return null;
        }

        private int? GetUniversityIdFromClaims()
        {
            if (User.IsInRole("University"))
            {
                var universityIdClaim = User.FindFirst("UniversityId")?.Value;
                if (int.TryParse(universityIdClaim, out int universityId))
                    return universityId;
            }
            return null;
        }

        // ============================
        // Public Endpoints
        // ============================

        [HttpGet("{id:int}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _workshopService.GetWorkshopByIdAsync(id);
            if (result.IsFailure)
                return result.ToActionResult();

            return Result.Success(PrepareForJson(result.Value)).ToActionResult();
        }

        [HttpGet]
        [AllowAnonymous]
        public async Task<IActionResult> GetAll(
            [FromQuery] bool includeDisabled = false,
            [FromQuery] QueryParameters query = null)
        {
            query ??= new QueryParameters();

            if (includeDisabled)
            {
                var pagedResult = await _workshopService.GetAllWorkshopsAsync(query);
                if (pagedResult.IsFailure)
                    return pagedResult.ToActionResult();

                var prepared = pagedResult.Value.Data.Select(PrepareForJson);
                return Result.Success(new
                {
                    data = prepared,
                    pagedResult.Value.TotalCount,
                    pagedResult.Value.Page,
                    pagedResult.Value.PageSize,
                    pagedResult.Value.TotalPages
                }).ToActionResult();
            }

            var result = await _unitOfWork.Workshops.GetPublishedWorkshopsAsync();
            if (result.IsFailure)
                return result.ToActionResult();

            var preparedAll = result.Value.Select(PrepareForJson);
            return Result.Success(preparedAll).ToActionResult();
        }

        [HttpGet("search")]
        [AllowAnonymous]
        public async Task<IActionResult> Search(
            [FromQuery] string searchTerm,
            [FromQuery] QueryParameters query)
        {
            if (string.IsNullOrWhiteSpace(searchTerm))
                return Result.Failure<IEnumerable<WorkshopSec1>>(
                    new Error("Workshop.InvalidSearch", "Search term is required")).ToActionResult();

            var result = await _workshopService.SearchWorkshopsAsync(searchTerm, query);
            if (result.IsFailure)
                return result.ToActionResult();

            var prepared = result.Value.Data.Select(PrepareForJson);
            return Result.Success(new
            {
                data = prepared,
                result.Value.TotalCount,
                result.Value.Page,
                result.Value.PageSize,
                result.Value.TotalPages
            }).ToActionResult();
        }

        // ============================
        // Company/University Endpoints
        // ============================

        [HttpPost]
        [Authorize(Roles = "Company,University")]
        public async Task<IActionResult> Create([FromForm] WorkshopRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Title))
                return Result.Failure<WorkshopSec1>(WorkshopErrors.WorkshopInvalidRequest).ToActionResult();

            await _unitOfWork.BeginTransactionAsync();
            try
            {
                var companyId = GetCompanyIdFromClaims();
                var universityId = GetUniversityIdFromClaims();

                request = request with
                {
                    CompanyId = companyId,
                    UniversityId = universityId ?? request.UniversityId,
                    HostType = companyId != null ? "Company" : "University"
                };

                var workshopResult = await _workshopService.CreateWorkshopAsync(request, companyId);
                if (workshopResult.IsFailure)
                {
                    await _unitOfWork.RollbackTransactionAsync();
                    return workshopResult.ToActionResult();
                }

                var workshop = workshopResult.Value;

                workshop.BannerUrl = request.Banner != null
                    ? await SaveFileAsync(request.Banner, "covers")
                    : "/uploads/workshops/default.jpg";

                await _unitOfWork.Workshops.UpdateAsync(workshop);
                await _unitOfWork.SaveChangesAsync();

                if (request.Activities?.Any() == true)
                {
                    foreach (var act in request.Activities)
                    {
                        var activity = workshop.Activities?.FirstOrDefault(a => a.Name == act.Name);
                        if (activity != null)
                        {
                            activity.CreatedAt = DateTime.UtcNow;
                            await _unitOfWork.WorkshopActivities.UpdateAsync(activity);
                        }
                    }
                    await _unitOfWork.SaveChangesAsync();
                }

                if (request.Materials?.Any() == true)
                {
                    var materials = workshop.Materials?.ToList() ?? new List<WorkshopMaterial>();
                    for (int i = 0; i < request.Materials.Count && i < materials.Count; i++)
                    {
                        var m = request.Materials[i];
                        var mat = materials[i];

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

                        mat.CreatedAt = DateTime.UtcNow;
                        await _unitOfWork.WorkshopMaterials.UpdateAsync(mat);
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
                var messages = new List<string>();
                var current = ex;
                while (current != null)
                {
                    messages.Add(current.Message);
                    current = current.InnerException;
                }
                var fullMessage = string.Join(" | ", messages);
                return Result.Failure<WorkshopSec1>(new Error("Workshop.CreateFailed", fullMessage))
                             .ToActionResult();
            }
        }

        [HttpPut("{id:int}")]
        [Authorize(Roles = "Company,University")]
        public async Task<IActionResult> Update(int id, [FromForm] WorkshopRequest request)
        {
            var existing = await _unitOfWork.Workshops.GetByIdWithDetailsAsync(id);
            if (existing.IsFailure)
                return Result.Failure<WorkshopSec1>(WorkshopErrors.WorkshopNotFound).ToActionResult();

            var companyId = GetCompanyIdFromClaims();
            var universityId = GetUniversityIdFromClaims();

            if (companyId != null && existing.Value.CompanyId != companyId)
                return Result.Failure<WorkshopSec1>(
                    new Error("Workshop.Unauthorized", "You don't have permission to update this workshop"))
                    .ToActionResult();

            if (universityId.HasValue && existing.Value.UniversityId != universityId.Value)
                return Result.Failure<WorkshopSec1>(
                    new Error("Workshop.Unauthorized", "You don't have permission to update this workshop"))
                    .ToActionResult();

            // ← التعديل هنا برضو
            request = request with
            {
                CompanyId = companyId,
                UniversityId = universityId,
                HostType = companyId != null ? "Company" : "University"
            };

            await _unitOfWork.BeginTransactionAsync();
            try
            {
                var updateResult = await _workshopService.UpdateWorkshopAsync(id, request);
                if (updateResult.IsFailure)
                {
                    await _unitOfWork.RollbackTransactionAsync();
                    return updateResult.ToActionResult();
                }

                if (request.Banner != null)
                {
                    var workshop = existing.Value;
                    workshop.BannerUrl = await SaveFileAsync(request.Banner, "covers");
                    await _unitOfWork.Workshops.UpdateAsync(workshop);
                    await _unitOfWork.SaveChangesAsync();
                }

                await RecalculateTotalsAsync(id);
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
        [Authorize(Roles = "Company,University")]
        public async Task<IActionResult> ToggleStatus(int id)
        {
            var existing = await _unitOfWork.Workshops.GetByIdWithDetailsAsync(id);
            if (existing.IsFailure)
                return Result.Failure<WorkshopSec1>(WorkshopErrors.WorkshopNotFound).ToActionResult();

            var companyId = GetCompanyIdFromClaims();
            if (companyId != null && existing.Value.CompanyId != companyId)
                return Result.Failure<WorkshopSec1>(
                    new Error("Workshop.Unauthorized", "You don't have permission to toggle this workshop"))
                    .ToActionResult();

            var universityId = GetUniversityIdFromClaims();
            if (universityId.HasValue && existing.Value.UniversityId != universityId.Value)
                return Result.Failure<WorkshopSec1>(
                    new Error("Workshop.Unauthorized", "You don't have permission to toggle this workshop"))
                    .ToActionResult();

            var result = await _unitOfWork.Workshops.ToggleStatusAsync(id);
            return result.ToActionResult();
        }

        [HttpPatch("bulkstatus")]
        [Authorize(Roles = "Company,University")]
        public async Task<IActionResult> BulkStatus([FromQuery] bool isPublished, [FromBody] List<int> ids)
        {
            if (ids == null || !ids.Any())
                return Result.Failure<IEnumerable<WorkshopSec1>>(WorkshopErrors.WorkshopNoIdsProvided).ToActionResult();

            var result = await _unitOfWork.Workshops.BulkUpdateStatusAsync(ids, isPublished);
            return Result.Success(new { updatedCount = ids.Count, success = result }).ToActionResult();
        }

        [HttpDelete("{id:int}")]
        [Authorize(Roles = "Company,University")]
        public async Task<IActionResult> Delete(int id)
        {
            var existing = await _unitOfWork.Workshops.GetByIdWithDetailsAsync(id);
            if (existing.IsFailure)
                return Result.Failure<WorkshopSec1>(WorkshopErrors.WorkshopNotFound).ToActionResult();

            var companyId = GetCompanyIdFromClaims();
            if (companyId != null && existing.Value.CompanyId != companyId)
                return Result.Failure<WorkshopSec1>(
                    new Error("Workshop.Unauthorized", "You don't have permission to delete this workshop"))
                    .ToActionResult();

            var universityId = GetUniversityIdFromClaims();
            if (universityId.HasValue && existing.Value.UniversityId != universityId.Value)
                return Result.Failure<WorkshopSec1>(
                    new Error("Workshop.Unauthorized", "You don't have permission to delete this workshop"))
                    .ToActionResult();

            var result = await _workshopService.DeleteWorkshopAsync(id);
            return result.ToActionResult();
        }

        [HttpDelete("bulkdelete")]
        [Authorize(Roles = "Company,University")]
        public async Task<IActionResult> BulkDelete([FromBody] List<int> ids)
        {
            if (ids == null || !ids.Any())
                return Result.Failure<IEnumerable<WorkshopSec1>>(WorkshopErrors.WorkshopNoIdsProvided).ToActionResult();

            var result = await _unitOfWork.Workshops.BulkDeleteAsync(ids);
            return Result.Success(new { deletedCount = ids.Count, success = result }).ToActionResult();
        }

        [HttpGet("my-workshops")]
        [Authorize(Roles = "Company,University")]
        public async Task<IActionResult> GetMyWorkshops([FromQuery] QueryParameters query)
        {
            var companyId = GetCompanyIdFromClaims();
            var universityId = GetUniversityIdFromClaims();

            var allWorkshops = await _workshopService.GetAllWorkshopsAsync(query);
            if (allWorkshops.IsFailure)
                return allWorkshops.ToActionResult();

            var myWorkshops = companyId != null
                ? allWorkshops.Value.Data.Where(w => w.CompanyId == companyId)
                : allWorkshops.Value.Data.Where(w => w.UniversityId == universityId);

            var prepared = myWorkshops.Select(PrepareForJson);
            return Result.Success(prepared).ToActionResult();
        }
    }
}