using Business_Logic.IService;
using DataAccess.Entities.Events;
using DataAccess.IRepository;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using SmartCareerHub.Contracts.Company.Event;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Business_Logic.Services
{
    public class EventService : IEventService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IRealTimeNotificationService _realTimeNotificationService;
        private readonly string _eventsPath;

        public EventService(IUnitOfWork unitOfWork, IRealTimeNotificationService realTimeNotificationService, IWebHostEnvironment env)
        {
            _unitOfWork = unitOfWork;
            _realTimeNotificationService = realTimeNotificationService;

            _eventsPath = Path.Combine(env.WebRootPath ?? "wwwroot", "uploads", "events");
            if (!Directory.Exists(_eventsPath))
                Directory.CreateDirectory(_eventsPath);
        }

        private async Task<string> SaveFileAsync(IFormFile file, CancellationToken cancellationToken = default)
        {
            var fileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
            var path = Path.Combine(_eventsPath, fileName);

            using var stream = new FileStream(path, FileMode.Create);
            await file.CopyToAsync(stream, cancellationToken);

            return path;
        }

        private string? GetImageBase64(string? filePath)
        {
            if (string.IsNullOrEmpty(filePath) || !File.Exists(filePath))
                return null;

            return Convert.ToBase64String(File.ReadAllBytes(filePath));
        }

        // ================== GET ==================
        public async Task<EventResponse?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Events.GetByIdWithDetailsAsync(id);
            if (result.IsFailure) return null;
            return MapToResponse(result.Value);
        }

        public async Task<PagedResponse<EventResponse>> GetAllAsync(
     QueryParameters query,
     CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Events.GetAllWithDetailsAsync(cancellationToken);
            if (result.IsFailure)
                return PagedResponse<EventResponse>.Create(
                    Enumerable.Empty<EventResponse>(), query.Page, query.PageSize);

            var events = result.Value.AsQueryable();

            // Filtering
            if (!string.IsNullOrWhiteSpace(query.Search))
                events = events.Where(e =>
                    e.Title.Contains(query.Search, StringComparison.OrdinalIgnoreCase) ||
                    e.EventType.Contains(query.Search, StringComparison.OrdinalIgnoreCase) ||
                    e.Description.Contains(query.Search, StringComparison.OrdinalIgnoreCase));

            // Sorting
            events = query.SortBy?.ToLower() switch
            {
                "title" => query.SortDirection == "asc"
                    ? events.OrderBy(e => e.Title)
                    : events.OrderByDescending(e => e.Title),
                "date" => query.SortDirection == "asc"
                    ? events.OrderBy(e => e.StartDate)
                    : events.OrderByDescending(e => e.StartDate),
                _ => events.OrderByDescending(e => e.CreatedAt)
            };

            var mapped = events.Select(MapToResponse);
            return PagedResponse<EventResponse>.Create(mapped, query.Page, query.PageSize);
        }

        // ================== CREATE ==================
        public async Task<EventResponse> AddAsync(EventRequest request, string creatorId, CancellationToken cancellationToken = default)
        {
            await _unitOfWork.BeginTransactionAsync();
            try
            {
                var evt = new Event
                {
                    Title = request.Title,
                    Description = request.Description,
                    EventType = request.EventType,
                    Mode = request.Mode,
                    StartDate = request.StartDate,
                    EndDate = request.EndDate,
                    StartTime = request.StartTime,
                    EndTime = request.EndTime,
                    MinimumRequiredPoints = request.MinimumRequiredPoints,
                    CompletedRoadmap = request.CompletedRoadmap,
                    Completed50PercentCourses = request.Completed50PercentCourses,
                    HighCommunicationSkills = request.HighCommunicationSkills,
                    HighTechnicalSkills = request.HighTechnicalSkills,
                    Top30PercentProgress = request.Top30PercentProgress,
                    InviteOnlyEligibleStudents = request.InviteOnlyEligibleStudents,
                    MaxCapacity = request.MaxCapacity,
                    AllowWaitingList = request.AllowWaitingList,
                    SendAutoEmailToEligibleStudents = request.SendAutoEmailToEligibleStudents,
                    PointsForAttendance = request.PointsForAttendance,
                    PointsForFullParticipation = request.PointsForFullParticipation,
                    IsPublished = request.IsPublished,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };

                if (request.Banner != null)
                    evt.BannerUrl = await SaveFileAsync(request.Banner, cancellationToken);

                var addResult = await _unitOfWork.Events.AddEventAsync(evt);
                if (addResult.IsFailure) throw new InvalidOperationException(addResult.Error.Description);

                await _unitOfWork.SaveChangesAsync();
                await _unitOfWork.CommitTransactionAsync();

                // إشعار للمتدرب/المستخدمين لو الحدث منشور مباشرة
                if (evt.IsPublished)
                {
                    await _realTimeNotificationService.BroadcastAsync(
                        "New Event Published 🎉",
                        $"A new event '{evt.Title}' is now available for enrollment."
                    );
                }

                return MapToResponse(evt);
            }
            catch
            {
                await _unitOfWork.RollbackTransactionAsync();
                throw;
            }
        }

        // ================== UPDATE ==================
        public async Task<bool> UpdateAsync(int id, EventRequest request, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Events.GetByIdWithDetailsAsync(id);
            if (result.IsFailure) return false;

            var evt = result.Value;
            evt.Title = request.Title;
            evt.Description = request.Description;
            evt.EventType = request.EventType;
            evt.Mode = request.Mode;
            evt.StartDate = request.StartDate;
            evt.EndDate = request.EndDate;
            evt.StartTime = request.StartTime;
            evt.EndTime = request.EndTime;
            evt.MinimumRequiredPoints = request.MinimumRequiredPoints;
            evt.CompletedRoadmap = request.CompletedRoadmap;
            evt.Completed50PercentCourses = request.Completed50PercentCourses;
            evt.HighCommunicationSkills = request.HighCommunicationSkills;
            evt.HighTechnicalSkills = request.HighTechnicalSkills;
            evt.Top30PercentProgress = request.Top30PercentProgress;
            evt.InviteOnlyEligibleStudents = request.InviteOnlyEligibleStudents;
            evt.MaxCapacity = request.MaxCapacity;
            evt.AllowWaitingList = request.AllowWaitingList;
            evt.SendAutoEmailToEligibleStudents = request.SendAutoEmailToEligibleStudents;
            evt.PointsForAttendance = request.PointsForAttendance;
            evt.PointsForFullParticipation = request.PointsForFullParticipation;
            evt.IsPublished = request.IsPublished;
            evt.UpdatedAt = DateTime.UtcNow;

            if (request.Banner != null)
                evt.BannerUrl = await SaveFileAsync(request.Banner, cancellationToken);

            _unitOfWork.Events.Update(evt);
            await _unitOfWork.SaveChangesAsync();

            // إشعار للمنظم/المستخدمين إذا تم نشر الحدث بعد التعديل
            if (evt.IsPublished)
            {
                await _realTimeNotificationService.BroadcastAsync(
                    "Event Updated 🔔",
                    $"Event '{evt.Title}' has been updated and is now open for enrollment."
                );
            }

            return true;
        }

        // ================== DELETE ==================
        public async Task<bool> DeleteAsync(int id, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Events.GetByIdWithDetailsAsync(id);
            if (result.IsFailure) return false;

            _unitOfWork.Events.Delete(result.Value);
            await _unitOfWork.SaveChangesAsync();

            await _realTimeNotificationService.BroadcastAsync(
                "Event Cancelled ❌",
                $"Event '{result.Value.Title}' has been cancelled."
            );

            return true;
        }

        // ================== TOGGLE / BULK ==================
        public async Task<bool> ToggleStatusAsync(int id, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Events.GetByIdWithDetailsAsync(id);
            if (result.IsFailure) return false;

            var evt = result.Value;
            evt.IsPublished = !evt.IsPublished;
            evt.UpdatedAt = DateTime.UtcNow;

            _unitOfWork.Events.Update(evt);
            await _unitOfWork.SaveChangesAsync();

            await _realTimeNotificationService.BroadcastAsync(
                evt.IsPublished ? "Event Published 🎉" : "Event Unpublished ⚠️",
                $"Event '{evt.Title}' is now {(evt.IsPublished ? "published" : "unpublished")}."
            );

            return true;
        }

        public async Task<bool> BulkUpdateStatusAsync(List<int> ids, bool isPublished, CancellationToken cancellationToken = default)
        {
            foreach (var id in ids)
            {
                var evtResult = await _unitOfWork.Events.GetByIdWithDetailsAsync(id);
                if (!evtResult.IsFailure)
                {
                    var evt = evtResult.Value;
                    evt.IsPublished = isPublished;
                    evt.UpdatedAt = DateTime.UtcNow;
                    _unitOfWork.Events.Update(evt);
                }
            }
            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task<bool> BulkDeleteAsync(List<int> ids, CancellationToken cancellationToken = default)
        {
            foreach (var id in ids)
                await DeleteAsync(id, cancellationToken);
            return true;
        }

        // ================== HELPERS ==================
        private EventResponse MapToResponse(Event evt)
        {
            string? createdByName = null;
            if (!string.IsNullOrEmpty(evt.CreatedById))
            {
                var company = _unitOfWork.companyAuthRepository
                    .GetCompanyProfileByUserIdAsync(evt.CreatedById).Result;
                if (company != null)
                    createdByName = company.OrganizationName;
                else
                {
                    var university = _unitOfWork.universityAuthRepository
                        .GetUniversityProfileByUserIdAsync(evt.CreatedById).Result;
                    if (university != null)
                        createdByName = university.Name;
                }
            }

            return new EventResponse(
                evt.Id, evt.Title, evt.Description, GetImageBase64(evt.BannerUrl),
                evt.EventType, evt.Mode, evt.StartDate, evt.EndDate, evt.StartTime, evt.EndTime,
                evt.MinimumRequiredPoints, evt.CompletedRoadmap, evt.Completed50PercentCourses,
                evt.HighCommunicationSkills, evt.HighTechnicalSkills, evt.Top30PercentProgress,
                evt.InviteOnlyEligibleStudents, evt.EligibleStudentsCount, evt.ExpectedAttendees,
                evt.CurrentRegistrations, evt.MaxCapacity, evt.AllowWaitingList, evt.SendAutoEmailToEligibleStudents,
                evt.PointsForAttendance, evt.PointsForFullParticipation, evt.IsPublished,
                createdByName, // ← اسم الشركة أو الجامعة
                evt.CreatedAt, evt.UpdatedAt
            );
        }

        public async Task<bool> IsTitleExistsAsync(string title, int? excludeId = null, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Events.GetAllWithDetailsAsync(cancellationToken);
            if (result.IsFailure)
                return false;

            return result.Value.Any(e =>
                e.Title.Trim().ToLower() == title.Trim().ToLower() &&
                (!excludeId.HasValue || e.Id != excludeId.Value)
            );
        }
    }
}