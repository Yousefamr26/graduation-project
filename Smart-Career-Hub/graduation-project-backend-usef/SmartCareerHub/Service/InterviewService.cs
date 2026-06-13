using Business_Logic.IService;
using DataAccess.Abstractions;
using DataAccess.Entities.Interview;
using DataAccess.IRepository;

namespace Business_Logic.Service
{
    public class InterviewService : IInterviewService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IRealTimeNotificationService _realTimeNotificationService;

        public InterviewService(IUnitOfWork unitOfWork, IRealTimeNotificationService realTimeNotificationService)
        {
            _unitOfWork = unitOfWork;
            _realTimeNotificationService = realTimeNotificationService;
        }

        // ================== GET ==================
        public async Task<PagedResponse<InterviewResponse>> GetAllAsync(
            QueryParameters query,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.GetAllWithDetailsAsync();
            if (result.IsFailure)
                return PagedResponse<InterviewResponse>.Create(
                    Enumerable.Empty<InterviewResponse>(), query.Page, query.PageSize);

            var interviews = result.Value.AsEnumerable();

            // Filtering
            if (!string.IsNullOrWhiteSpace(query.Search))
                interviews = interviews.Where(i =>
                    i.StudentName.Contains(query.Search, StringComparison.OrdinalIgnoreCase) ||
                    i.InterviewerName.Contains(query.Search, StringComparison.OrdinalIgnoreCase) ||
                    i.Roadmap?.Title.Contains(query.Search, StringComparison.OrdinalIgnoreCase) == true);

            // Sorting
            interviews = query.SortBy?.ToLower() switch
            {
                "name" => query.SortDirection == "asc"
                    ? interviews.OrderBy(i => i.StudentName)
                    : interviews.OrderByDescending(i => i.StudentName),
                "date" => query.SortDirection == "asc"
                    ? interviews.OrderBy(i => i.ScheduledAt)
                    : interviews.OrderByDescending(i => i.ScheduledAt),
                _ => interviews.OrderByDescending(i => i.CreatedAt)
            };

            return PagedResponse<InterviewResponse>.Create(
                interviews.Select(MapToResponse), query.Page, query.PageSize);
        }

        public async Task<InterviewResponse?> GetByIdAsync(
            int id,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.GetByIdWithDetailsAsync(id);
            if (result.IsFailure) return null;
            return MapToResponse(result.Value);
        }

        public async Task<PagedResponse<InterviewResponse>> GetByRoadmapAsync(
            int roadmapId,
            QueryParameters query,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.GetByRoadmapAsync(roadmapId);
            if (result.IsFailure)
                return PagedResponse<InterviewResponse>.Create(
                    Enumerable.Empty<InterviewResponse>(), query.Page, query.PageSize);

            var interviews = result.Value.AsEnumerable();

            // Sorting
            interviews = query.SortBy?.ToLower() switch
            {
                "date" => query.SortDirection == "asc"
                    ? interviews.OrderBy(i => i.ScheduledAt)
                    : interviews.OrderByDescending(i => i.ScheduledAt),
                _ => interviews.OrderByDescending(i => i.CreatedAt)
            };

            return PagedResponse<InterviewResponse>.Create(
                interviews.Select(MapToResponse), query.Page, query.PageSize);
        }

        public async Task<PagedResponse<InterviewResponse>> GetByStatusAsync(
            InterviewStatus status,
            QueryParameters query,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.GetByStatusAsync(status);
            if (result.IsFailure)
                return PagedResponse<InterviewResponse>.Create(
                    Enumerable.Empty<InterviewResponse>(), query.Page, query.PageSize);

            return PagedResponse<InterviewResponse>.Create(
                result.Value.Select(MapToResponse), query.Page, query.PageSize);
        }

        public async Task<PagedResponse<InterviewResponse>> GetAIRecommendedAsync(
            QueryParameters query,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.GetAIRecommendedAsync();
            if (result.IsFailure)
                return PagedResponse<InterviewResponse>.Create(
                    Enumerable.Empty<InterviewResponse>(), query.Page, query.PageSize);

            return PagedResponse<InterviewResponse>.Create(
                result.Value.Select(MapToResponse), query.Page, query.PageSize);
        }

        public async Task<PagedResponse<InterviewResponse>> GetTodayInterviewsAsync(
            QueryParameters query,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.GetTodayInterviewsAsync();
            if (result.IsFailure)
                return PagedResponse<InterviewResponse>.Create(
                    Enumerable.Empty<InterviewResponse>(), query.Page, query.PageSize);

            return PagedResponse<InterviewResponse>.Create(
                result.Value.Select(MapToResponse), query.Page, query.PageSize);
        }

        public async Task<PagedResponse<InterviewResponse>> SearchInterviewsAsync(
            string searchTerm,
            QueryParameters query,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.SearchInterviewsAsync(searchTerm);
            if (result.IsFailure)
                return PagedResponse<InterviewResponse>.Create(
                    Enumerable.Empty<InterviewResponse>(), query.Page, query.PageSize);

            var interviews = result.Value.AsEnumerable();

            // Sorting
            interviews = query.SortBy?.ToLower() switch
            {
                "name" => query.SortDirection == "asc"
                    ? interviews.OrderBy(i => i.StudentName)
                    : interviews.OrderByDescending(i => i.StudentName),
                "date" => query.SortDirection == "asc"
                    ? interviews.OrderBy(i => i.ScheduledAt)
                    : interviews.OrderByDescending(i => i.ScheduledAt),
                _ => interviews.OrderByDescending(i => i.CreatedAt)
            };

            return PagedResponse<InterviewResponse>.Create(
                interviews.Select(MapToResponse), query.Page, query.PageSize);
        }

        public async Task<PagedResponse<InterviewResponse>> GetLatestInterviewsAsync(
            int count,
            QueryParameters query,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.GetLatestInterviewsAsync(count);
            if (result.IsFailure)
                return PagedResponse<InterviewResponse>.Create(
                    Enumerable.Empty<InterviewResponse>(), query.Page, query.PageSize);

            return PagedResponse<InterviewResponse>.Create(
                result.Value.Select(MapToResponse), query.Page, query.PageSize);
        }

        public async Task<Result<PagedResponse<InterviewResponse>>> GetUpcomingInterviewsAsync(
            string userId,
            QueryParameters query,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.GetUpcomingInterviewsAsync(userId);
            if (result.IsFailure)
                return Result.Failure<PagedResponse<InterviewResponse>>(result.Error);

            var interviews = result.Value.AsEnumerable();

            // Sorting
            interviews = query.SortBy?.ToLower() switch
            {
                "date" => query.SortDirection == "asc"
                    ? interviews.OrderBy(i => i.ScheduledAt)
                    : interviews.OrderByDescending(i => i.ScheduledAt),
                _ => interviews.OrderBy(i => i.ScheduledAt)
            };

            return Result.Success(PagedResponse<InterviewResponse>.Create(
                interviews.Select(MapToResponse), query.Page, query.PageSize));
        }

        public async Task<Result<PagedResponse<InterviewResponse>>> GetPastInterviewsAsync(
            string userId,
            QueryParameters query,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.GetPastInterviewsAsync(userId);
            if (result.IsFailure)
                return Result.Failure<PagedResponse<InterviewResponse>>(result.Error);

            var interviews = result.Value.AsEnumerable();

            // Sorting
            interviews = query.SortBy?.ToLower() switch
            {
                "date" => query.SortDirection == "asc"
                    ? interviews.OrderBy(i => i.ScheduledAt)
                    : interviews.OrderByDescending(i => i.ScheduledAt),
                _ => interviews.OrderByDescending(i => i.ScheduledAt)
            };

            return Result.Success(PagedResponse<InterviewResponse>.Create(
                interviews.Select(MapToResponse), query.Page, query.PageSize));
        }

        public async Task<Result<InterviewResponse?>> GetInterviewByIdForUserAsync(
            int id,
            string userId,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.GetByIdForUserAsync(id, userId);
            if (result.IsFailure) return Result.Success<InterviewResponse?>(null);
            return Result.Success(MapToResponse(result.Value));
        }

        // ================== ADD ==================
        public async Task<InterviewResponse> AddAsync(
    InterviewRequest request,
    string userId,
    CancellationToken cancellationToken = default)
        {
            await _unitOfWork.BeginTransactionAsync();
            try
            {
                // ← جيب اسم الشركة
                var companyProfile = await _unitOfWork.companyAuthRepository
                    .GetCompanyProfileByUserIdAsync(userId);

                // ← جيب اسم الطالب أو الخريج من الـ DB
                string studentName = request.StudentName ?? "Unknown";

                var student = await _unitOfWork.studentAuthRepository
                    .GetStudentProfileByUserIdAsync(request.StudentUserId);

                if (student != null)
                {
                    studentName = $"{student.User?.FirstName} {student.User?.LastName}";
                }
                else
                {
                    var graduate = await _unitOfWork.graduateAuthRepository
                        .GetGraduateProfileByUserIdAsync(request.StudentUserId);

                    if (graduate != null)
                        studentName = $"{graduate.User?.FirstName} {graduate.User?.LastName}";
                }

                var interview = new InterviewSchedule
                {
                    UserId = request.StudentUserId,
                    StudentName = studentName,
                    CompanyName = companyProfile?.OrganizationName ?? "", // ← ضيف ده
                    RoadmapId = request.RoadmapId ?? 0,
                    ScheduledAt = request.ScheduledDate,
                    InterviewType = request.InterviewType,
                    InterviewerName = request.InterviewerName,
                    AdditionalNotes = request.AdditionalNotes,
                    CreatedAt = DateTime.UtcNow,
                    Status = InterviewStatus.Pending
                };

                var addResult = await _unitOfWork.Interviews.AddInterviewAsync(interview);
                if (addResult.IsFailure)
                    throw new InvalidOperationException(addResult.Error.Description);

                await _unitOfWork.SaveChangesAsync();
                await _unitOfWork.CommitTransactionAsync();

                await _realTimeNotificationService.SendToUserAsync(
                    request.StudentUserId,
                    "Interview Scheduled 📅",
                    $"An interview has been scheduled for you on {interview.ScheduledAt}."
                );

                await _realTimeNotificationService.SendToUserAsync(
                    userId,
                    "Interview Created ✅",
                    $"Interview with '{studentName}' has been scheduled on {interview.ScheduledAt}."
                );

                var fullResult = await _unitOfWork.Interviews.GetByIdWithDetailsAsync(addResult.Value.Id);
                return MapToResponse(fullResult.Value);
            }
            catch
            {
                await _unitOfWork.RollbackTransactionAsync();
                throw;
            }
        }

        // ================== UPDATE ==================
        public async Task<bool> UpdateAsync(
            int id,
            InterviewRequest request,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.GetByIdWithDetailsAsync(id);
            if (result.IsFailure) return false;

            var interview = result.Value;
            interview.StudentName = request.StudentName;
            interview.RoadmapId = request.RoadmapId ?? 0;
            interview.ScheduledAt = request.ScheduledDate;
            interview.InterviewType = request.InterviewType;
            interview.InterviewerName = request.InterviewerName;
            interview.AdditionalNotes = request.AdditionalNotes;

            var updateResult = await _unitOfWork.Interviews.UpdateAsync(interview);
            if (updateResult.IsFailure) return false;

            await _unitOfWork.SaveChangesAsync();

            await _realTimeNotificationService.SendToUserAsync(
                interview.UserId,
                "Interview Updated ✏️",
                $"Your interview scheduled on {interview.ScheduledAt} has been updated."
            );

            return true;
        }

        public async Task<bool> UpdateStatusAsync(
            int id,
            InterviewStatus status,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.UpdateStatusAsync(id, status);
            if (result.IsFailure) return false;
            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        // ================== ACCEPT / DECLINE ==================
        public async Task<Result<bool>> AcceptInterviewAsync(
            int id,
            string userId,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.AcceptInterviewAsync(id, userId);
            if (result.IsFailure) return Result.Failure<bool>(result.Error);

            await _unitOfWork.SaveChangesAsync();

            var interview = await _unitOfWork.Interviews.GetByIdWithDetailsAsync(id);
            if (!interview.IsFailure)
            {
                await _realTimeNotificationService.SendToUserAsync(
                    interview.Value.UserId,
                    "Interview Accepted ✅",
                    $"Your interview on {interview.Value.ScheduledAt} has been accepted."
                );
            }

            return Result.Success(true);
        }

        public async Task<Result<bool>> DeclineInterviewAsync(
            int id,
            string userId,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.DeclineInterviewAsync(id, userId);
            if (result.IsFailure) return Result.Failure<bool>(result.Error);

            await _unitOfWork.SaveChangesAsync();

            var interview = await _unitOfWork.Interviews.GetByIdWithDetailsAsync(id);
            if (!interview.IsFailure)
            {
                await _realTimeNotificationService.SendToUserAsync(
                    interview.Value.UserId,
                    "Interview Declined ❌",
                    $"Your interview on {interview.Value.ScheduledAt} has been declined."
                );
            }

            return Result.Success(true);
        }

        // ================== DELETE ==================
        public async Task<bool> DeleteAsync(
            int id,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.DeleteAsync(id);
            if (result.IsFailure) return false;
            await _unitOfWork.SaveChangesAsync();

            await _realTimeNotificationService.BroadcastAsync(
                "Interview Deleted 🗑️",
                $"An interview with ID {id} has been removed."
            );

            return true;
        }

        // ================== BULK ==================
        public async Task<bool> BulkUpdateStatusAsync(
            List<int> ids,
            InterviewStatus status,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.BulkUpdateStatusAsync(ids, status);
            if (result.IsFailure) return false;
            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task<bool> BulkDeleteAsync(
            List<int> ids,
            CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.BulkDeleteAsync(ids);
            if (result.IsFailure) return false;
            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        // ================== COUNT ==================
        public async Task<int> GetTotalCountAsync(CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.GetTotalCountAsync();
            return result.IsFailure ? 0 : result.Value;
        }

        public async Task<int> GetTodayCountAsync(CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.GetTodayCountAsync();
            return result.IsFailure ? 0 : result.Value;
        }

        // ================== HELPERS ==================
        private InterviewResponse MapToResponse(InterviewSchedule i)
        {
            return new InterviewResponse(
                Id: i.Id,
                StudentName: i.StudentName,
                RoadmapId: i.RoadmapId,
                RoadmapName: i.Roadmap?.Title ?? "",
                Date: i.ScheduledAt,
                InterviewType: i.InterviewType,
                MeetingLink: i.MeetingLink,
                Location: i.Location,
                InterviewerName: i.InterviewerName,
                AdditionalNotes: i.AdditionalNotes,
                Status: i.Status,
                Result: i.Result,
                Feedback: i.Feedback,
                IsAIPick: i.IsAIPick,
                CompanyName: i.CompanyName ?? i.Roadmap?.Company?.OrganizationName ?? "", // ← عدل ده
                CreatedAt: i.CreatedAt
            );
        }
    }
}