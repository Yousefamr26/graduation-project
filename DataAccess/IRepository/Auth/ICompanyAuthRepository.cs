using DataAccess.Abstractions;
using DataAccess.Entities.Users;
using System.Threading.Tasks;

namespace DataAccess.IRepository
{
    public interface ICompanyAuthRepository
    {
        Task<bool> UserExistsByEmailAsync(string email);
        Task<Result<ApplicationUser>> CreateUserAsync(ApplicationUser user, string password);
        Task<Result> AssignRoleAsync(ApplicationUser user, string role);
        Task<Result<CompanyUser>> CreateCompanyProfileAsync(CompanyUser company);
    }
}
