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
        private readonly string _eventsPath;

        public EventService(IUnitOfWork unitOfWork, IWebHostEnvironment env)
        {
            _unitOfWork = unitOfWork;
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

            return path; // ارجع المسار الكامل
        }

        private string? GetImageBase64(string? filePath)
        {
            if (string.IsNullOrEmpty(filePath) || !File.Exists(filePath))
                return null;

            var bytes = File.ReadAllBytes(filePath);
            return Convert.ToBase64String(bytes);
        }

        public async Task<EventResponse?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Events.GetByIdWithDetailsAsync(id);
            if (result.IsFailure) return null;

            var evt = result.Value;
            return new EventResponse(
                evt.Id,
                evt.Title,
                evt.Description,
                GetImageBase64(evt.BannerUrl), // الصوره نفسها Base64
                evt.EventType,
                evt.Mode,
                evt.StartDate,
                evt.EndDate,
                evt.StartTime,
                evt.EndTime,
                evt.MinimumRequiredPoints,
                evt.CompletedRoadmap,
                evt.Completed50PercentCourses,
                evt.HighCommunicationSkills,
                evt.HighTechnicalSkills,
                evt.Top30PercentProgress,
                evt.InviteOnlyEligibleStudents,
                evt.EligibleStudentsCount,
                evt.ExpectedAttendees,
                evt.CurrentRegistrations,
                evt.MaxCapacity,
                evt.AllowWaitingList,
                evt.SendAutoEmailToEligibleStudents,
                evt.PointsForAttendance,
                evt.PointsForFullParticipation,
                evt.IsPublished,
                evt.CreatedAt,
                evt.UpdatedAt
            );
        }

        public async Task<IEnumerable<EventResponse>> GetAllAsync(CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Events.GetAllWithDetailsAsync();
            if (result.IsFailure) return Enumerable.Empty<EventResponse>();

            return result.Value.Select(evt => new EventResponse(
                evt.Id,
                evt.Title,
                evt.Description,
                GetImageBase64(evt.BannerUrl),
                evt.EventType,
                evt.Mode,
                evt.StartDate,
                evt.EndDate,
                evt.StartTime,
                evt.EndTime,
                evt.MinimumRequiredPoints,
                evt.CompletedRoadmap,
                evt.Completed50PercentCourses,
                evt.HighCommunicationSkills,
                evt.HighTechnicalSkills,
                evt.Top30PercentProgress,
                evt.InviteOnlyEligibleStudents,
                evt.EligibleStudentsCount,
                evt.ExpectedAttendees,
                evt.CurrentRegistrations,
                evt.MaxCapacity,
                evt.AllowWaitingList,
                evt.SendAutoEmailToEligibleStudents,
                evt.PointsForAttendance,
                evt.PointsForFullParticipation,
                evt.IsPublished,
                evt.CreatedAt,
                evt.UpdatedAt
            ));
        }

        public async Task<EventResponse> AddAsync(Event request, IFormFile? banner = null, CancellationToken cancellationToken = default)
        {
            await _unitOfWork.BeginTransactionAsync();
            try
            {
                if (banner != null)
                    request.BannerUrl = await SaveFileAsync(banner, cancellationToken);

                request.CreatedAt = DateTime.UtcNow;
                request.UpdatedAt = DateTime.UtcNow;

                var addResult = await _unitOfWork.Events.AddEventAsync(request);
                if (addResult.IsFailure) throw new InvalidOperationException(addResult.Error.Description);

                await _unitOfWork.SaveChangesAsync();
                await _unitOfWork.CommitTransactionAsync();

                return await GetByIdAsync(request.Id, cancellationToken) ?? throw new Exception("Failed to retrieve created event");
            }
            catch
            {
                await _unitOfWork.RollbackTransactionAsync();
                throw;
            }
        }

        public async Task<bool> UpdateAsync(int id, Event request, IFormFile? banner = null, CancellationToken cancellationToken = default)
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

            if (banner != null)
                evt.BannerUrl = await SaveFileAsync(banner, cancellationToken);

            _unitOfWork.Events.Update(evt);
            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task<bool> DeleteAsync(int id, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Events.GetByIdWithDetailsAsync(id);
            if (result.IsFailure) return false;

            _unitOfWork.Events.Delete(result.Value);
            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task<bool> ToggleStatusAsync(int id, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Events.GetByIdWithDetailsAsync(id);
            if (result.IsFailure) return false;

            var evt = result.Value;
            evt.IsPublished = !evt.IsPublished;
            evt.UpdatedAt = DateTime.UtcNow;

            _unitOfWork.Events.Update(evt);
            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task<bool> BulkUpdateStatusAsync(List<int> ids, bool isPublished, CancellationToken cancellationToken = default)
        {
            foreach (var id in ids)
            {
                var result = await _unitOfWork.Events.GetByIdWithDetailsAsync(id);
                if (!result.IsFailure)
                {
                    var evt = result.Value;
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
            {
                await DeleteAsync(id, cancellationToken);
            }
            return true;
        }

        public async Task<bool> IsTitleExistsAsync(string title, int? excludeId = null, CancellationToken cancellationToken = default)
        {
            return await _unitOfWork.Events.IsTitleExistsAsync(title, excludeId);
        }
    }
}
