using DataAccess.Abstractions;
using DataAccess.Entities.Partnership;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DataAccess.IRepository
{
    public interface IPartnershipRepository : IGenericRepository<Partnership>
    {
        Task<Result<Partnership>> GetByIdAsync(int id);

        Task<Result<IEnumerable<Partnership>>> GetAllAsync();

        Task<Result<Partnership>> CreateAsync(Partnership partnership);

        Task<Result<Partnership>> UpdateAsync(Partnership partnership);

        Task<Result<bool>> DeleteAsync(int id);

        Task<Result<bool>> BulkDeleteAsync(List<int> ids);

        Task<Result<bool>> BulkUpdateAsync(List<Partnership> partnerships);

        Task<Result<IEnumerable<Partnership>>> SearchAsync(string? companyName, int? universityId, string? partnershipType);
    }
}