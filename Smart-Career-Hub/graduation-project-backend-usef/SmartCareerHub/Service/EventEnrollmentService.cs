using Business_Logic.IService;
using DataAccess.Entities.Events;
using DataAccess.IRepository;
using SmartCareerHub.Contracts.Events;
using SmartCareerHub.Contracts.Events.Enrollment;

namespace Business_Logic.Services
{
    public class EventEnrollmentService : IEventEnrollmentService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IRealTimeNotificationService _realTimeNotificationService;

        public EventEnrollmentService(IUnitOfWork unitOfWork, IRealTimeNotificationService realTimeNotificationService)
        {
            _unitOfWork = unitOfWork;
            _realTimeNotificationService = realTimeNotificationService;
        }

        public async Task<EventEnrollmentSimpleResponse> EnrollAsync(
    string userId,
    EventEnrollmentRequest request,
    CancellationToken cancellationToken = default)
        {
            var eventEntity = await _unitOfWork.Events.GetByIdAsync(request.EventId);

            if (eventEntity == null)
                throw new Exception("Event not found");

            if (!eventEntity.IsPublished)
                throw new Exception("Event is not published");

            if (eventEntity.CurrentRegistrations >= eventEntity.MaxCapacity)
                throw new Exception("Event is full");

            var alreadyEnrolled =
                await _unitOfWork.EventEnrollments
                    .IsUserAlreadyEnrolledAsync(request.EventId, userId, cancellationToken);

            if (alreadyEnrolled)
                throw new Exception("User already enrolled");

            var enrollment = new EventEnrollment
            {
                EventId = request.EventId,
                UserId = userId,
                Email = request.Email,
                PhoneNumber = request.PhoneNumber,
                Motivation = request.Motivation
            };

            await _unitOfWork.EventEnrollments.AddAsync(enrollment, cancellationToken);

            eventEntity.CurrentRegistrations++;

            await _unitOfWork.SaveChangesAsync();

            // ← جيب اسم الشركة أو الجامعة
            string? hostName = null;
            if (!string.IsNullOrEmpty(eventEntity.CreatedById))
            {
                var company = await _unitOfWork.companyAuthRepository
                    .GetCompanyProfileByUserIdAsync(eventEntity.CreatedById);
                if (company != null)
                    hostName = company.OrganizationName;
                else
                {
                    var university = await _unitOfWork.universityAuthRepository
                        .GetUniversityProfileByUserIdAsync(eventEntity.CreatedById);
                    if (university != null)
                        hostName = university.Name;
                }
            }

            // إشعار للمتدرب
            await _realTimeNotificationService.SendToUserAsync(
                userId,
                "Event Enrollment ✅",
                $"You have successfully enrolled in the event '{eventEntity.Title}'."
            );

            // إشعار للمنظم / الشركة
            if (eventEntity.CreatedById != null)
            {
                await _realTimeNotificationService.SendToUserAsync(
                    eventEntity.CreatedById,
                    "New Event Enrollment 📄",
                    $"User '{request.Email}' has enrolled in your event '{eventEntity.Title}'."
                );
            }

            return new EventEnrollmentSimpleResponse(
                enrollment.Id,
                enrollment.EnrolledAt,
                "Successfully enrolled in event",
                hostName // ← ضيف ده
            );
        }

        public async Task<bool> CancelEnrollmentAsync(
            string userId,
            int eventId,
            CancellationToken cancellationToken = default)
        {
            var enrollment =
                await _unitOfWork.EventEnrollments
                    .GetByEventAndUserAsync(eventId, userId, cancellationToken);

            if (enrollment == null)
                return false;

            var eventEntity = await _unitOfWork.Events.GetByIdAsync(eventId);

            _unitOfWork.EventEnrollments.Remove(enrollment);

            if (eventEntity != null && eventEntity.CurrentRegistrations > 0)
                eventEntity.CurrentRegistrations--;

            await _unitOfWork.SaveChangesAsync();

            // إشعار للمتدرب
            await _realTimeNotificationService.SendToUserAsync(
                userId,
                "Event Enrollment Cancelled ❌",
                $"You have successfully cancelled your enrollment in '{eventEntity?.Title ?? "the event"}'."
            );

            // إشعار للمنظم / الشركة
            if (eventEntity?.CreatedById != null)
            {
                await _realTimeNotificationService.SendToUserAsync(
                    eventEntity.CreatedById,
                    "Enrollment Cancelled ⚠️",
                    $"User '{enrollment.Email}' has cancelled enrollment in your event '{eventEntity.Title}'."
                );
            }

            return true;
        }

        public async Task<PagedResponse<MyEventResponse>> GetMyEventsAsync(
      string userId,
      QueryParameters query,
      CancellationToken cancellationToken = default)
        {
            var enrollments = await _unitOfWork.EventEnrollments.GetUserEnrollmentsAsync(userId);

            var mapped = enrollments.Select(e => new MyEventResponse(
                e.Event.Id,
                e.Event.Title,
                e.Event.Description,
                e.Event.Mode,
                e.Event.StartDate,
                e.EnrolledAt
            ));

            // Filtering
            if (!string.IsNullOrWhiteSpace(query.Search))
                mapped = mapped.Where(e =>
                    e.Title.Contains(query.Search, StringComparison.OrdinalIgnoreCase));

            // Sorting
            mapped = query.SortBy?.ToLower() switch
            {
                "title" => query.SortDirection == "asc"
                    ? mapped.OrderBy(e => e.Title)
                    : mapped.OrderByDescending(e => e.Title),
                "date" => query.SortDirection == "asc"
                    ? mapped.OrderBy(e => e.EnrolledAt)
                    : mapped.OrderByDescending(e => e.EnrolledAt),
                _ => mapped.OrderByDescending(e => e.EnrolledAt)
            };

            return PagedResponse<MyEventResponse>.Create(mapped, query.Page, query.PageSize);
        }

        public async Task<PagedResponse<EventParticipantResponse>> GetParticipantsAsync(
            int eventId,
            QueryParameters query,
            CancellationToken cancellationToken = default)
        {
            var enrollments = await _unitOfWork.EventEnrollments.GetEventEnrollmentsAsync(eventId);

            var mapped = enrollments.Select(e => new EventParticipantResponse(
                e.UserId,
                e.Email,
                e.PhoneNumber,
                e.Motivation,
                e.EnrolledAt
            ));

            // Filtering
            if (!string.IsNullOrWhiteSpace(query.Search))
                mapped = mapped.Where(e =>
                    e.Email.Contains(query.Search, StringComparison.OrdinalIgnoreCase));

            // Sorting
            mapped = query.SortBy?.ToLower() switch
            {
                "email" => query.SortDirection == "asc"
                    ? mapped.OrderBy(e => e.Email)
                    : mapped.OrderByDescending(e => e.Email),
                _ => mapped.OrderByDescending(e => e.EnrolledAt)
            };

            return PagedResponse<EventParticipantResponse>.Create(mapped, query.Page, query.PageSize);
        }
    }
}