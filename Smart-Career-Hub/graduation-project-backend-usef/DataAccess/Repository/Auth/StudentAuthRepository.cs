using Business_Logic.Errors;
using DataAccess.Abstractions;
using DataAccess.Contexts;
using DataAccess.Entities.Users;
using DataAccess.IRepository;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;

namespace DataAccess.Repository
{
    public class StudentAuthRepository : IStudentAuthRepository
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly ApplicationDbContext _context;

        public StudentAuthRepository(
            UserManager<ApplicationUser> userManager,
            SignInManager<ApplicationUser> signInManager,
            ApplicationDbContext context)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _context = context;
        }

        #region Register Methods

        public async Task<bool> UserExistsByEmailAsync(string email)
        {
            return await _userManager.FindByEmailAsync(email) != null;
        }

        public async Task<Result<ApplicationUser>> CreateUserAsync(ApplicationUser user, string password)
        {
            var result = await _userManager.CreateAsync(user, password);
            if (!result.Succeeded)
                return Result.Failure<ApplicationUser>(AuthErrors.UserCreationFailed);

            return Result.Success(user);
        }

        public async Task<Result> AssignRoleAsync(ApplicationUser user, string role)
        {
            var result = await _userManager.AddToRoleAsync(user, role);
            if (!result.Succeeded)
                return Result.Failure(AuthErrors.UserRoleAssignmentFailed);

            return Result.Success();
        }

        public async Task<Result<Student>> CreateStudentProfileAsync(Student student)
        {
            try
            {
                await _context.StudentUsers.AddAsync(student);
                await _context.SaveChangesAsync();
                return Result.Success(student);
            }
            catch
            {
                return Result.Failure<Student>(AuthErrors.StudentCreationFailed);
            }
        }

        #endregion

        #region Login Methods

        public async Task<ApplicationUser?> GetUserByEmailAsync(string email)
        {
            return await _userManager.Users
                .Include(u => u.StudentProfile)
                .FirstOrDefaultAsync(u => u.Email == email);
        }

        public async Task<bool> CheckPasswordAsync(ApplicationUser user, string password)
        {
            return await _userManager.CheckPasswordAsync(user, password);
        }

        public async Task<Result> SignInAsync(ApplicationUser user, bool rememberMe)
        {
            var result = await _signInManager.CheckPasswordSignInAsync(user, user.PasswordHash, lockoutOnFailure: true);

            if (result.IsLockedOut)
                return Result.Failure(AuthErrors.AccountLockedOut);

            if (!result.Succeeded)
                return Result.Failure(AuthErrors.InvalidCredentials);

            return Result.Success();
        }

        public async Task<Student?> GetStudentProfileByUserIdAsync(string userId)
        {
            return await _context.StudentUsers
                .Include(s => s.User) // ← ضيف ده
                .FirstOrDefaultAsync(s => s.UserId == userId);
        }

        #endregion
    }
}
