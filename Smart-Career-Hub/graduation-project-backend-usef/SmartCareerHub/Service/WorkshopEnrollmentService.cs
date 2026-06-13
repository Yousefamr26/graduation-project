using Business_Logic.Errors;
using DataAccess.Abstractions;
using DataAccess.Entities.Workshop;
using DataAccess.IRepository;
using SmartCareerHub.Contracts.Workshops.Enrollment;

public class WorkshopEnrollmentService : IWorkshopEnrollmentService
{
    private readonly IUnitOfWork _unitOfWork;

    public WorkshopEnrollmentService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<Result<EnrollWorkshopResponse>> EnrollAsync(
        string userId,
        EnrollWorkshopRequest request)
    {
        var workshopResult = await _unitOfWork.Workshops.GetByIdWithDetailsAsync(request.WorkshopId);
        if (workshopResult.IsFailure)
            return Result.Failure<EnrollWorkshopResponse>(WorkshopErrors.WorkshopNotFound);

        var workshop = workshopResult.Value;

        if (!workshop.IsPublished)
            return Result.Failure<EnrollWorkshopResponse>(WorkshopErrors.WorkshopNotPublished);

        if (await _unitOfWork.workshopEnrollments.IsUserEnrolledAsync(request.WorkshopId, userId))
            return Result.Failure<EnrollWorkshopResponse>(WorkshopErrors.UserAlreadyEnrolled);

        if (workshop.RequireCV && !request.CvUploaded)
            return Result.Failure<EnrollWorkshopResponse>(WorkshopErrors.CvRequired);

        if (workshop.RequireRoadmapCompletion && !request.RoadmapCompleted)
            return Result.Failure<EnrollWorkshopResponse>(WorkshopErrors.RoadmapRequired);

        if (workshop.Enrollments.Count >= workshop.MaxCapacity)
            return Result.Failure<EnrollWorkshopResponse>(WorkshopErrors.WorkshopFull);

        var enrollment = new WorkshopEnrollment
        {
            Id = Guid.NewGuid().ToString(), // ← ضيف ده
            WorkshopId = workshop.Id,
            UserId = userId,
            CvUploaded = request.CvUploaded,
            RoadmapCompleted = request.RoadmapCompleted,
            RegisteredAt = DateTime.UtcNow
        };

        var added = await _unitOfWork.workshopEnrollments.AddAsync(enrollment);

        return Result.Success(new EnrollWorkshopResponse(
     EnrollmentId: added.Id,
     WorkshopId: workshop.Id,
     UserId: userId,
     RegisteredAt: added.RegisteredAt,
     CvUploaded: added.CvUploaded,
     RoadmapCompleted: added.RoadmapCompleted,
     HostName: workshop.Company?.OrganizationName
            ?? workshop.University?.Name
            ?? ""  // ← ضيف ده
 ));
    }

    public async Task<Result<PagedResponse<EnrollWorkshopResponse>>> GetMyEnrollmentsAsync(
        string userId,
        QueryParameters query)
    {
        var enrollments = await _unitOfWork.workshopEnrollments.GetEnrollmentsByUserAsync(userId);

        var data = enrollments.AsEnumerable();

        // Sorting
        data = query.SortBy?.ToLower() switch
        {
            "date" => query.SortDirection == "asc"
                ? data.OrderBy(e => e.RegisteredAt)
                : data.OrderByDescending(e => e.RegisteredAt),
            _ => data.OrderByDescending(e => e.RegisteredAt)
        };

        var mapped = data.Select(e => new EnrollWorkshopResponse(
     e.Id,
     e.WorkshopId,
     e.UserId,
     e.RegisteredAt,
     e.CvUploaded,
     e.RoadmapCompleted,
     e.Workshop?.Company?.OrganizationName ?? e.Workshop?.University?.Name ?? ""
 ));

        return Result.Success(
            PagedResponse<EnrollWorkshopResponse>.Create(mapped, query.Page, query.PageSize));
    }

    public async Task<Result<PagedResponse<WorkshopParticipantResponse>>> GetWorkshopParticipantsAsync(
        int workshopId,
        QueryParameters query)
    {
        var enrollments = await _unitOfWork.workshopEnrollments.GetEnrollmentsByWorkshopAsync(workshopId);

        var data = enrollments.AsEnumerable();

        // Filtering
        if (!string.IsNullOrWhiteSpace(query.Search))
            data = data.Where(e =>
                e.UserId.Contains(query.Search, StringComparison.OrdinalIgnoreCase));

        // Sorting
        data = query.SortBy?.ToLower() switch
        {
            "date" => query.SortDirection == "asc"
                ? data.OrderBy(e => e.RegisteredAt)
                : data.OrderByDescending(e => e.RegisteredAt),
            _ => data.OrderByDescending(e => e.RegisteredAt)
        };

        var mapped = data.Select(e => new WorkshopParticipantResponse(
            e.UserId,
            "Unknown",
            e.CvUploaded,
            e.RoadmapCompleted,
            e.RegisteredAt
        ));

        return Result.Success(
            PagedResponse<WorkshopParticipantResponse>.Create(mapped, query.Page, query.PageSize));
    }

    public async Task<Result> CancelEnrollmentAsync(int workshopId, string userId)
    {
        var exists = await _unitOfWork.workshopEnrollments.GetEnrollmentAsync(workshopId, userId);
        if (exists == null)
            return Result.Failure(WorkshopErrors.EnrollmentNotFound);

        var deleted = await _unitOfWork.workshopEnrollments.DeleteEnrollmentAsync(workshopId, userId);

        return deleted
            ? Result.Success()
            : Result.Failure(WorkshopErrors.WorkshopDeleteFailed);
    }

    public async Task<Result<PagedResponse<WorkshopAvailableItem>>> GetAvailableWorkshopsAsync(
        string userId,
        QueryParameters query)
    {
        try
        {
            var workshops = await _unitOfWork.Workshops.GetAllAsync();

            var data = workshops.AsEnumerable();

            // Filtering
            if (!string.IsNullOrWhiteSpace(query.Search))
                data = data.Where(w =>
                    w.Title.Contains(query.Search, StringComparison.OrdinalIgnoreCase) ||
                    w.Description.Contains(query.Search, StringComparison.OrdinalIgnoreCase) ||
                    w.Location.Contains(query.Search, StringComparison.OrdinalIgnoreCase));

            // Sorting
            data = query.SortBy?.ToLower() switch
            {
                "title" => query.SortDirection == "asc"
                    ? data.OrderBy(w => w.Title)
                    : data.OrderByDescending(w => w.Title),
                "points" => query.SortDirection == "asc"
                    ? data.OrderBy(w => w.TotalPoints)
                    : data.OrderByDescending(w => w.TotalPoints),
                _ => data.OrderByDescending(w => w.CreatedAt)
            };

            var mapped = data.Select(w => new WorkshopAvailableItem(
                WorkshopId: w.Id,
                Title: w.Title,
                Description: w.Description,
                BannerUrl: w.BannerUrl,
                Location: w.Location,
                WorkshopType: w.WorkshopType,
                MaxCapacity: w.MaxCapacity,
                CurrentEnrollments: w.Enrollments.Count,
                RequireCV: w.RequireCV,
                RequireRoadmapCompletion: w.RequireRoadmapCompletion,
                TotalPoints: w.TotalPoints
            ));

            return Result.Success(
                PagedResponse<WorkshopAvailableItem>.Create(mapped, query.Page, query.PageSize));
        }
        catch (Exception ex)
        {
            return Result.Failure<PagedResponse<WorkshopAvailableItem>>(
                new Error("WorkshopLoadFailed", "Failed to load workshops: " + ex.Message));
        }
    }

    public async Task<Result<WorkshopDetailsResponse>> GetWorkshopDetailsAsync(
        int workshopId,
        string userId)
    {
        var workshopResult = await _unitOfWork.Workshops.GetByIdWithDetailsAsync(workshopId);
        if (workshopResult.IsFailure)
            return Result.Failure<WorkshopDetailsResponse>(WorkshopErrors.WorkshopNotFound);

        var workshop = workshopResult.Value;
        var enrollment = await _unitOfWork.workshopEnrollments.GetEnrollmentAsync(workshopId, userId);

        return Result.Success(new WorkshopDetailsResponse(
            WorkshopId: workshop.Id,
            Title: workshop.Title,
            Description: workshop.Description,
            BannerUrl: workshop.BannerUrl,
            Location: workshop.Location,
            WorkshopType: workshop.WorkshopType,
            MaxCapacity: workshop.MaxCapacity,
            CurrentEnrollments: workshop.Enrollments.Count,
            RequireCV: workshop.RequireCV,
            RequireRoadmapCompletion: workshop.RequireRoadmapCompletion,
            IsPublished: workshop.IsPublished,
            TotalPoints: workshop.TotalPoints,
            IsUserEnrolled: enrollment != null,
            CvUploaded: enrollment?.CvUploaded ?? false,
            RoadmapCompleted: enrollment?.RoadmapCompleted ?? false
        ));
    }
}