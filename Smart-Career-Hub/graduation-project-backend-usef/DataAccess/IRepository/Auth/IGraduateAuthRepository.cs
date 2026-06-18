using DataAccess.Abstractions;
using DataAccess.Entities.Users;
using System.Threading.Tasks;

namespace DataAccess.IRepository
{
    public interface IGraduateAuthRepository
    {
        // ---- Register Methods ----
        Task<bool> UserExistsByEmailAsync(string email);
        Task<Result<ApplicationUser>> CreateUserAsync(ApplicationUser user, string password);
        Task<Result> AssignRoleAsync(ApplicationUser user, string role);
        Task<Result<Graduates>> CreateGraduateProfileAsync(Graduates graduate);

        // ---- Login Methods ----
        Task<ApplicationUser?> GetUserByEmailAsync(string email);
        Task<bool> CheckPasswordAsync(ApplicationUser user, string password);
        Task<Result> SignInAsync(ApplicationUser user, bool rememberMe);
        Task<Graduates?> GetGraduateProfileByUserIdAsync(string userId);
    }
}
