using DataAccess.Entities.Job;
using DataAccess.IRepository;
using Business_Logic.IService;

public class InternshipService : IInternshipService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IRealTimeNotificationService _realTimeNotificationService;

    public InternshipService(IUnitOfWork unitOfWork, IRealTimeNotificationService realTimeNotificationService)
    {
        _unitOfWork = unitOfWork;
        _realTimeNotificationService = realTimeNotificationService;
    }

    // ================== Create ==================
    public async Task<Internship> CreateInternshipAsync(Internship internship, string userId, CancellationToken cancellationToken = default)
    {
        if (internship == null) throw new ArgumentNullException(nameof(internship));
        if (string.IsNullOrEmpty(userId)) throw new ArgumentNullException(nameof(userId));

        var companyUser = await _unitOfWork.companyAuthRepository.GetCompanyProfileByUserIdAsync(userId);
        if (companyUser == null) throw new InvalidOperationException("Company profile not found");

        internship.CompanyId = companyUser.Id;
        internship.Status = internship.Status == 0 ? InternshipStatus.Open : internship.Status;
        internship.CreatedAt = DateTime.UtcNow;

        await _unitOfWork.internshipRepository.AddAsync(internship, cancellationToken);
        await _unitOfWork.SaveChangesAsync();

        if (internship.Status == InternshipStatus.Open)
        {
            await _realTimeNotificationService.BroadcastAsync(
                "New Internship Posted 🎯",
                $"A new internship '{internship.Title}' is now available for application."
            );
        }

        return internship;
    }

    // ================== Update ==================
    public async Task<Internship> UpdateInternshipAsync(Internship internship, CancellationToken cancellationToken = default)
    {
        if (internship == null) throw new ArgumentNullException(nameof(internship));

        var existing = await _unitOfWork.internshipRepository.GetByIdAsync(internship.Id, cancellationToken);
        if (existing == null) throw new KeyNotFoundException("Internship not found.");

        existing.Title = internship.Title;
        existing.Description = internship.Description;
        existing.Type = internship.Type;
        existing.Status = internship.Status;
        existing.IsPaid = internship.IsPaid;
        existing.MaxTrainees = internship.MaxTrainees;
        existing.DurationInMonths = internship.DurationInMonths;
        existing.Location = internship.Location;
        existing.ApplicationDeadline = internship.ApplicationDeadline;

        _unitOfWork.internshipRepository.Update(existing);
        await _unitOfWork.SaveChangesAsync();

        await _realTimeNotificationService.BroadcastAsync(
            "Internship Updated 🔔",
            $"Internship '{existing.Title}' has been updated."
        );

        return existing;
    }

    // ================== Delete ==================
    public async Task DeleteInternshipAsync(int id, CancellationToken cancellationToken = default)
    {
        var internship = await _unitOfWork.internshipRepository.GetByIdAsync(id, cancellationToken);
        if (internship == null) throw new KeyNotFoundException("Internship not found.");

        _unitOfWork.internshipRepository.Delete(internship);
        await _unitOfWork.SaveChangesAsync();

        await _realTimeNotificationService.BroadcastAsync(
            "Internship Cancelled ❌",
            $"Internship '{internship.Title}' has been removed."
        );
    }

    // ================== Apply ==================
    public async Task ApplyAsync(int internshipId, string userId, CancellationToken cancellationToken = default)
    {
        var internship = await _unitOfWork.internshipRepository.GetByIdAsync(internshipId, cancellationToken);
        if (internship == null) throw new KeyNotFoundException("Internship not found.");
        if (internship.Status != InternshipStatus.Open) throw new InvalidOperationException("Cannot apply to a closed or draft internship.");
        if (DateTime.UtcNow > internship.ApplicationDeadline) throw new InvalidOperationException("Application deadline has passed.");

        bool applied = await _unitOfWork.internshipApplicationRepository.HasUserAppliedAsync(internshipId, userId, cancellationToken);
        if (applied) throw new InvalidOperationException("User has already applied to this internship.");

        var application = new InternshipApplication
        {
            Id = Guid.NewGuid().ToString(), // ← هنا
            InternshipId = internshipId,
            UserId = userId,
            AppliedAt = DateTime.UtcNow,
            Status = ApplicationStatu.Applied
        };

        await _unitOfWork.internshipApplicationRepository.AddAsync(application, cancellationToken);
        await _unitOfWork.SaveChangesAsync();

        if (internship.Company?.UserId != null)
        {
            await _realTimeNotificationService.SendToUserAsync(
                internship.Company.UserId,
                "New Internship Application 📄",
                $"A new applicant has applied for your internship '{internship.Title}'."
            );
        }
    }

    // ================== Check if user applied ==================
    public async Task<bool> HasUserAppliedAsync(int internshipId, string userId, CancellationToken cancellationToken = default)
    {
        return await _unitOfWork.internshipApplicationRepository.HasUserAppliedAsync(internshipId, userId, cancellationToken);
    }

    // ================== Get All Internships ==================
    public async Task<PagedResponse<InternshipCardResponse>> GetAllInternshipsAsync(
        QueryParameters query,
        CancellationToken cancellationToken = default)
    {
        var internships = await _unitOfWork.internshipRepository.GetAllAsync(cancellationToken);

        // Filtering
        if (!string.IsNullOrWhiteSpace(query.Search))
            internships = internships.Where(i =>
                i.Title.Contains(query.Search, StringComparison.OrdinalIgnoreCase) ||
                i.Company?.OrganizationName.Contains(query.Search, StringComparison.OrdinalIgnoreCase) == true);

        // Sorting
        internships = query.SortBy?.ToLower() switch
        {
            "title" => query.SortDirection == "asc"
                ? internships.OrderBy(i => i.Title)
                : internships.OrderByDescending(i => i.Title),
            "deadline" => query.SortDirection == "asc"
                ? internships.OrderBy(i => i.ApplicationDeadline)
                : internships.OrderByDescending(i => i.ApplicationDeadline),
            _ => internships.OrderByDescending(i => i.CreatedAt)
        };

        var mapped = internships.Select(i => new InternshipCardResponse(
            Id: i.Id,
            Title: i.Title,
            CompanyName: i.Company?.OrganizationName ?? "N/A",
            Location: i.Location,
            Type: i.Type,
            IsPaid: i.IsPaid,
            DurationInMonths: i.DurationInMonths,
            Status: i.Status,
            IsApplied: false
        ));

        return PagedResponse<InternshipCardResponse>.Create(mapped, query.Page, query.PageSize);
    }

    // ================== Get Internship Details ==================
    public async Task<InternshipDetailsResponse> GetInternshipByIdAsync(int id, string userId = null, CancellationToken cancellationToken = default)
    {
        var internship = await _unitOfWork.internshipRepository.GetByIdAsync(id, cancellationToken);
        if (internship == null) throw new KeyNotFoundException("Internship not found.");

        bool canApply = internship.Status == InternshipStatus.Open &&
                        (DateTime.UtcNow <= internship.ApplicationDeadline) &&
                        (userId == null || !await _unitOfWork.internshipApplicationRepository.HasUserAppliedAsync(id, userId, cancellationToken));

        return new InternshipDetailsResponse(
            Id: internship.Id,
            Title: internship.Title,
            Description: internship.Description,
            RequiredSkills: internship.RequiredSkills?.Select(s => s.Skill).ToList() ?? new List<string>(),
            Requirements: internship.Requirements?.Select(r => r.Requirement).ToList() ?? new List<string>(),
            Company: new CompanyMiniResponse(
                Name: internship.Company?.OrganizationName ?? "N/A",
                Logo: internship.Company?.OrganizationLogo
            ),
            DurationInMonths: internship.DurationInMonths,
            Location: internship.Location,
            IsPaid: internship.IsPaid,
            ApplicationDeadline: internship.ApplicationDeadline,
            CanApply: canApply
        );
    }

    // ================== Search ==================
    public async Task<PagedResponse<InternshipCardResponse>> SearchAsync(
        string? keyword,
        string? type,
        string? status,
        QueryParameters query,
        CancellationToken cancellationToken = default)
    {
        var internships = await _unitOfWork.internshipRepository.GetAllAsync(cancellationToken);

        if (!string.IsNullOrWhiteSpace(keyword))
            internships = internships.Where(i =>
                i.Title.Contains(keyword, StringComparison.OrdinalIgnoreCase) ||
                i.Company?.OrganizationName.Contains(keyword, StringComparison.OrdinalIgnoreCase) == true ||
                i.RequiredSkills.Any(s => s.Skill.Contains(keyword, StringComparison.OrdinalIgnoreCase)));

        if (!string.IsNullOrWhiteSpace(type) && Enum.TryParse<InternshipType>(type, true, out var typeEnum))
            internships = internships.Where(i => i.Type == typeEnum);

        if (!string.IsNullOrWhiteSpace(status) && Enum.TryParse<InternshipStatus>(status, true, out var statusEnum))
            internships = internships.Where(i => i.Status == statusEnum);

        // Sorting
        internships = query.SortBy?.ToLower() switch
        {
            "title" => query.SortDirection == "asc"
                ? internships.OrderBy(i => i.Title)
                : internships.OrderByDescending(i => i.Title),
            "deadline" => query.SortDirection == "asc"
                ? internships.OrderBy(i => i.ApplicationDeadline)
                : internships.OrderByDescending(i => i.ApplicationDeadline),
            _ => internships.OrderByDescending(i => i.CreatedAt)
        };

        var mapped = internships.Select(i => new InternshipCardResponse(
            Id: i.Id,
            Title: i.Title,
            CompanyName: i.Company?.OrganizationName ?? "N/A",
            Location: i.Location,
            Type: i.Type,
            IsPaid: i.IsPaid,
            DurationInMonths: i.DurationInMonths,
            Status: i.Status,
            IsApplied: false
        ));

        return PagedResponse<InternshipCardResponse>.Create(mapped, query.Page, query.PageSize);
    }

    // ================== Get Applicants ==================
    public async Task<PagedResponse<InternshipApplicantResponse>> GetApplicantsByInternshipIdAsync(
        int internshipId,
        QueryParameters query,
        CancellationToken cancellationToken = default)
    {
        var applications = await _unitOfWork.internshipApplicationRepository
            .GetByInternshipIdAsync(internshipId, cancellationToken);

        // Filtering
        if (!string.IsNullOrWhiteSpace(query.Search))
            applications = applications.Where(a =>
                a.User?.FirstName.Contains(query.Search, StringComparison.OrdinalIgnoreCase) == true ||
                a.User?.Email.Contains(query.Search, StringComparison.OrdinalIgnoreCase) == true);

        // Sorting
        applications = query.SortBy?.ToLower() switch
        {
            "name" => query.SortDirection == "asc"
                ? applications.OrderBy(a => a.User?.FirstName)
                : applications.OrderByDescending(a => a.User?.FirstName),
            _ => applications.OrderByDescending(a => a.AppliedAt)
        };

        var mapped = applications.Select(a => new InternshipApplicantResponse(
            ApplicationId: a.Id.ToString(),
            ApplicantName: $"{a.User?.FirstName} {a.User?.LastName}",
            Email: a.User?.Email ?? "N/A",
            InternshipPosition: a.Internship?.Title ?? "N/A",
            AppliedDate: a.AppliedAt,
            Status: a.Status.ToString(),
            UserId: a.UserId
        ));

        return PagedResponse<InternshipApplicantResponse>.Create(mapped, query.Page, query.PageSize);
    }

    // ================== Update Applicant Status ==================
    public async Task<bool> UpdateApplicantStatusAsync(string applicationId, ApplicationStatu status, CancellationToken cancellationToken = default)
    {
        var application = await _unitOfWork.internshipApplicationRepository
            .GetByIdAsync(applicationId, cancellationToken);

        if (application == null) return false;

        application.Status = status;
        await _unitOfWork.SaveChangesAsync();

        await _realTimeNotificationService.SendToUserAsync(
            application.UserId,
            "Internship Application Updated 🔔",
            $"Your application status is now '{status}'."
        );

        return true;
    }

    // ================== My Applications ==================
    public async Task<PagedResponse<InternshipApplicationResponse>> GetMyApplicationsAsync(
       string userId,
       QueryParameters query,
       CancellationToken cancellationToken = default)
    {
        var applications = (await _unitOfWork.internshipApplicationRepository.GetByUserIdAsync(userId))
            .AsEnumerable(); // ✅ حل المشكلة

        // Filtering
        if (!string.IsNullOrWhiteSpace(query.Search))
            applications = applications.Where(a =>
                a.Internship?.Title.Contains(query.Search, StringComparison.OrdinalIgnoreCase) == true ||
                a.Internship?.Company?.OrganizationName.Contains(query.Search, StringComparison.OrdinalIgnoreCase) == true);

        // Sorting
        applications = query.SortBy?.ToLower() switch
        {
            "title" => query.SortDirection == "asc"
                ? applications.OrderBy(a => a.Internship?.Title)
                : applications.OrderByDescending(a => a.Internship?.Title),
            "status" => query.SortDirection == "asc"
                ? applications.OrderBy(a => a.Status)
                : applications.OrderByDescending(a => a.Status),
            _ => applications.OrderByDescending(a => a.AppliedAt)
        };

        var mapped = applications.Select(a => new InternshipApplicationResponse(
            ApplicationId: a.Id.ToString(),
            InternshipTitle: a.Internship?.Title ?? "N/A",
            CompanyName: a.Internship?.Company?.OrganizationName ?? "N/A",
            Status: a.Status,
            AppliedAt: a.AppliedAt
        ));

        return PagedResponse<InternshipApplicationResponse>.Create(mapped, query.Page, query.PageSize);
    }

    // ================== Withdraw ==================
    public async Task<bool> WithdrawAsync(string userId, int applicationId, CancellationToken cancellationToken = default)
    {
        var application = await _unitOfWork.internshipApplicationRepository
            .GetByIdAsync(applicationId.ToString(), cancellationToken);

        if (application == null || application.UserId != userId)
            return false;

        if (application.Status != ApplicationStatu.Applied)
            return false;

        _unitOfWork.internshipApplicationRepository.Delete(application);
        await _unitOfWork.SaveChangesAsync();

        await _realTimeNotificationService.SendToUserAsync(
            userId,
            "Application Withdrawn ❌",
            $"You withdrew your application for '{application.Internship?.Title}'."
        );

        return true;
    }
}