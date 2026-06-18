using DataAccess.Abstractions;
using DataAccess.Entities.User;
using DataAccess.Entities.Users;

namespace DataAccess.IRepository
{
    public interface ITrainingCenterAuthRepository
    {
        // Register
        Task<bool> UserExistsByEmailAsync(string email);
        Task<Result<ApplicationUser>> CreateUserAsync(ApplicationUser user, string password);
        Task<Result> AssignRoleAsync(ApplicationUser user, string role);
        Task<Result<TrainingCenter>> CreateTrainingCenterProfileAsync(TrainingCenter trainingCenter);

        // Login
        Task<ApplicationUser?> GetUserByEmailAsync(string email);
        Task<bool> CheckPasswordAsync(ApplicationUser user, string password);
        Task<TrainingCenter?> GetTrainingCenterProfileByUserIdAsync(string userId);
    }
}