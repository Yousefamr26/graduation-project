using Business_Logic.Errors;
using DataAccess.Abstractions;
using DataAccess.Contexts;
using DataAccess.Entities.Users;
using DataAccess.IRepository;
using Microsoft.AspNetCore.Identity;

namespace DataAccess.Repository
{
    public class CompanyAuthRepository : ICompanyAuthRepository
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly ApplicationDbContext _context;

        public CompanyAuthRepository(UserManager<ApplicationUser> userManager, ApplicationDbContext context)
        {
            _userManager = userManager;
            _context = context;
        }

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

        public async Task<Result<CompanyUser>> CreateCompanyProfileAsync(CompanyUser company)
        {
            try
            {
                await _context.CompanyUser.AddAsync(company);
                return Result.Success(company);
            }
            catch
            {
                return Result.Failure<CompanyUser>(AuthErrors.CompanyCreationFailed);
            }
        }
    }
}
