using DataAccess.Abstractions;

public interface IPartnershipService
{
    Task<Result<PartnershipResponse>> CreateAsync(CreatePartnershipRequest request);
    Task<Result<IEnumerable<PartnershipResponse>>> GetAllAsync();
    Task<Result<PartnershipResponse>> GetByIdAsync(int id);
    Task<Result<bool>> UpdateAsync(UpdatePartnershipRequest request);
    Task<Result<bool>> DeleteAsync(int id);
    Task<Result<bool>> ApproveAsync(int id); // ← ضيف ده

}