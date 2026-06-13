using DataAccess.Abstractions;
using DataAccess.Entities.Partnership;
using DataAccess.IRepository;

public class PartnershipService : IPartnershipService
{
    private readonly IUnitOfWork _unitOfWork;

    public PartnershipService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    // ================= CREATE =================
    public async Task<Result<PartnershipResponse>> CreateAsync(CreatePartnershipRequest request)
    {
        var entity = new Partnership
        {
            CompanyId = request.CompanyId.ToString(),
            UniversityId = request.UniversityId,
            CompanyName = request.CompanyName,
            IndustryField = request.Industry,
            PartnershipType = request.PartnershipType,
            ContactPersonName = request.ContactPerson,
            ContactEmail = request.Email,
            Phone = request.Phone,
            Website = request.Website,
            Location = request.Location,
            PartnershipDetails = request.Details,
            CreatedAt = DateTime.UtcNow
        };

        var result = await _unitOfWork.partnershipRepository.CreateAsync(entity);

        if (!result.IsSuccess)
            return Result<PartnershipResponse>.Failure<PartnershipResponse>(result.Error);

        return Result<PartnershipResponse>.Success(MapToResponse(result.Value));
    }

    // ================= GET ALL =================
    public async Task<Result<IEnumerable<PartnershipResponse>>> GetAllAsync()
    {
        var result = await _unitOfWork.partnershipRepository.GetAllAsync();

        if (!result.IsSuccess)
            return Result<IEnumerable<PartnershipResponse>>.Failure<IEnumerable<PartnershipResponse>>(result.Error);


        var mapped = result.Value
            .Select(MapToResponse);

        return Result<IEnumerable<PartnershipResponse>>.Success(mapped);
    }
    public async Task<Result<bool>> ApproveAsync(int id)
    {
        var existing = await _unitOfWork.partnershipRepository.GetByIdAsync(id);
        if (!existing.IsSuccess)
            return Result.Failure<bool>(existing.Error);

        var entity = existing.Value;
        entity.Status = "Approved";
        entity.UpdatedAt = DateTime.UtcNow;

        var updateResult = await _unitOfWork.partnershipRepository.UpdateAsync(entity);
        if (!updateResult.IsSuccess)
            return Result.Failure<bool>(updateResult.Error);

        return Result.Success(true);
    }

    // ================= GET BY ID =================
    public async Task<Result<PartnershipResponse>> GetByIdAsync(int id)
    {
        var result = await _unitOfWork.partnershipRepository.GetByIdAsync(id);

        if (!result.IsSuccess)
            return Result<PartnershipResponse>.Failure<PartnershipResponse>(result.Error);

        return Result<PartnershipResponse>.Success(MapToResponse(result.Value));
    }

    // ================= UPDATE =================
    public async Task<Result<bool>> UpdateAsync(UpdatePartnershipRequest request)
    {
        var existing = await _unitOfWork.partnershipRepository.GetByIdAsync(request.Id);

        if (!existing.IsSuccess)
            return Result<bool>.Failure<bool>(existing.Error);

        var entity = existing.Value;

        entity.CompanyName = request.CompanyName;
        entity.IndustryField = request.Industry;
        entity.PartnershipType = request.PartnershipType;
        entity.ContactPersonName = request.ContactPerson;
        entity.ContactEmail = request.Email;
        entity.Phone = request.Phone;
        entity.Website = request.Website;
        entity.Location = request.Location;
        entity.PartnershipDetails = request.Details;

        var updateResult = await _unitOfWork.partnershipRepository.UpdateAsync(entity);

        if (!updateResult.IsSuccess)
            return Result<bool>.Failure<bool>(updateResult.Error);

        return Result<bool>.Success(true);
    }

    // ================= DELETE =================
    public async Task<Result<bool>> DeleteAsync(int id)
    {
        var result = await _unitOfWork.partnershipRepository.DeleteAsync(id);

        if (!result.IsSuccess)
            return Result<bool>.Failure<bool>(result.Error);

        return Result<bool>.Success(true);
    }

    // ================= MAPPING =================
    private static PartnershipResponse MapToResponse(Partnership entity)
    {
        return new PartnershipResponse(
            Id: entity.Id,
            CompanyName: entity.CompanyName,
            IndustryField: entity.IndustryField,
            PartnershipType: entity.PartnershipType,
            ContactPersonName: entity.ContactPersonName,
            ContactEmail: entity.ContactEmail,
            Phone: entity.Phone,
            Website: entity.Website,
            Location: entity.Location,
            PartnershipDetails: entity.PartnershipDetails,
            StartDate: entity.StartDate,
            Status: entity.Status,
            EventsHosted: entity.EventsHosted,
            StudentsReached: entity.StudentsReached,
            CreatedAt: entity.CreatedAt,
            UpdatedAt: entity.UpdatedAt,
            CompanyLogo: entity.Company?.OrganizationLogo
        );
    }
}