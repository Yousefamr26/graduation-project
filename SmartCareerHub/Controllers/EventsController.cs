using Business_Logic.Errors;
using DataAccess.Abstractions;
using DataAccess.Entities.Events;
using DataAccess.Errors;
using DataAccess.IRepository;
using Mapster;
using Microsoft.AspNetCore.Mvc;
using SmartCareerHub.Extensions;

namespace SmartCareerHub.Controllers;

[ApiController]
[Route("api/[controller]")]
public class EventsController : ControllerBase
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly string _rootPath;

    public EventsController(IUnitOfWork unitOfWork, IWebHostEnvironment env)
    {
        _unitOfWork = unitOfWork;
        _rootPath = Path.Combine(env.WebRootPath ?? "wwwroot", "uploads", "events");

        var coverFolder = Path.Combine(_rootPath, "covers");
        if (!Directory.Exists(coverFolder))
            Directory.CreateDirectory(coverFolder);
    }

   
    private Event PrepareForJson(Event e)
    {
        return e;
    }

    
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var result = await _unitOfWork.Events.GetByIdWithDetailsAsync(id);
        if (result.IsFailure)
            return result.ToActionResult();

        return Ok(PrepareForJson(result.Value));
    }


    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] bool includeDisabled = false)
    {
        var result = includeDisabled
            ? await _unitOfWork.Events.GetAllWithDetailsAsync()
            : await _unitOfWork.Events.GetPublishedEventsAsync();

        if (result.IsFailure)
            return result.ToActionResult();

        var safeEvents = result.Value.Select(e => PrepareForJson(e));
        return Ok(safeEvents);
    }

    
    [HttpGet("published")]
    public async Task<IActionResult> GetPublished()
    {
        var result = await _unitOfWork.Events.GetPublishedEventsAsync();
        if (result.IsFailure)
            return result.ToActionResult();

        return Ok(result.Value.Select(e => PrepareForJson(e)));
    }

    
    [HttpGet("search")]
    public async Task<IActionResult> Search([FromQuery] string keyword)
    {
        if (string.IsNullOrWhiteSpace(keyword))
            return BadRequest("Search keyword is required");

        var result = await _unitOfWork.Events.SearchEventsAsync(keyword);
        if (result.IsFailure)
            return result.ToActionResult();

        return Ok(result.Value.Select(e => PrepareForJson(e)));
    }

   
    [HttpGet("latest")]
    public async Task<IActionResult> GetLatest([FromQuery] int count = 10)
    {
        if (count <= 0 || count > 100)
            return BadRequest("Count must be between 1 and 100");

        var result = await _unitOfWork.Events.GetLatestEventsAsync(count);
        if (result.IsFailure)
            return result.ToActionResult();

        return Ok(result.Value.Select(e => PrepareForJson(e)));
    }

    
    [HttpPost]
    public async Task<IActionResult> Create([FromForm] Event request)
    {
        if (string.IsNullOrWhiteSpace(request.Title))
            return Result.Failure<Event>(EventErrors.EventInvalidRequest).ToActionResult();

        await _unitOfWork.BeginTransactionAsync();

        try
        {
            request.CreatedAt = DateTime.UtcNow;
            var addedResult = await _unitOfWork.Events.AddEventAsync(request);
            if (addedResult.IsFailure)
            {
                await _unitOfWork.RollbackTransactionAsync();
                return addedResult.ToActionResult();
            }

            await _unitOfWork.CommitTransactionAsync();

            var fullResult = await _unitOfWork.Events.GetByIdWithDetailsAsync(addedResult.Value.Id);
            if (fullResult.IsFailure)
                return StatusCode(500, "Event created but failed to retrieve details");

            return CreatedAtAction(nameof(GetById), new { id = fullResult.Value.Id }, PrepareForJson(fullResult.Value));
        }
        catch (Exception ex)
        {
            await _unitOfWork.RollbackTransactionAsync();
            return Result.Failure<Event>(
                new Error("Event.CreateFailed", $"Failed to create event: {ex.Message}")
            ).ToActionResult();
        }
    }

   
    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromForm] Event request)
    {
        var existingResult = await _unitOfWork.Events.GetByIdWithDetailsAsync(id);
        if (existingResult.IsFailure)
            return existingResult.ToActionResult();

        await _unitOfWork.BeginTransactionAsync();

        try
        {
            var e = existingResult.Value;

            e.Title = request.Title;
            e.Description = request.Description;
            e.StartDate = request.StartDate;
            e.EndDate = request.EndDate;
            e.IsPublished = request.IsPublished;
            e.UpdatedAt = DateTime.UtcNow;

            var updateResult = await _unitOfWork.Events.UpdateAsync(e);
            if (updateResult.IsFailure)
            {
                await _unitOfWork.RollbackTransactionAsync();
                return updateResult.ToActionResult();
            }

            await _unitOfWork.CommitTransactionAsync();

            var refreshedResult = await _unitOfWork.Events.GetByIdWithDetailsAsync(id);
            if (refreshedResult.IsFailure)
                return StatusCode(500, "Event updated but failed to retrieve details");

            return Ok(PrepareForJson(refreshedResult.Value));
        }
        catch (Exception ex)
        {
            await _unitOfWork.RollbackTransactionAsync();
            return Result.Failure<Event>(
                new Error("Event.UpdateFailed", $"Failed to update event: {ex.Message}")
            ).ToActionResult();
        }
    }

   
    [HttpPatch("toggle/{id:int}")]
    public async Task<IActionResult> ToggleStatus(int id)
    {
        var result = await _unitOfWork.Events.ToggleStatusAsync(id);
        return result.ToActionResult();
    }

    [HttpPatch("bulkstatus")]
    public async Task<IActionResult> BulkStatus([FromQuery] bool isPublished, [FromBody] List<int> ids)
    {
        if (ids == null || !ids.Any())
            return BadRequest("No event IDs provided");

        var result = await _unitOfWork.Events.BulkUpdateStatusAsync(ids, isPublished);
        return result.ToActionResult();
    }

   
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _unitOfWork.Events.DeleteAsync(id);
        return result.ToActionResult();
    }

    [HttpDelete("bulkdelete")]
    public async Task<IActionResult> BulkDelete([FromBody] List<int> ids)
    {
        if (ids == null || !ids.Any())
            return BadRequest("No event IDs provided");

        var result = await _unitOfWork.Events.BulkDeleteAsync(ids);
        return result.ToActionResult();
    }

   
    private async Task<string> SaveFileAsync(IFormFile file)
    {
        var folder = Path.Combine(_rootPath, "covers");
        if (!Directory.Exists(folder))
            Directory.CreateDirectory(folder);

        var name = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
        var path = Path.Combine(folder, name);

        using var stream = new FileStream(path, FileMode.Create);
        await file.CopyToAsync(stream);

        return $"/uploads/events/covers/{name}";
    }
}
