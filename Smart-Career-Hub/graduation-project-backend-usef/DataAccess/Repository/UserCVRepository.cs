using DataAccess.Contexts;
using Microsoft.EntityFrameworkCore;

public class UserCVRepository : IUserCVRepository
{
    private readonly ApplicationDbContext _context;

    public UserCVRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<UserCV?> GetByIdAsync(int id)
    {
        return await _context.UserCVs
            .Include(cv => cv.CVTemplate) // ✅ جيب التمبليت المرتبط لو موجود
            .FirstOrDefaultAsync(cv => cv.Id == id);
    }

    public async Task AddAsync(UserCV cv)
    {
        await _context.UserCVs.AddAsync(cv);
    }

    // ✅ كل CVs بتاعت يوزر معين
    public async Task<IEnumerable<UserCV>> GetByUserIdAsync(string userId)
    {
        return await _context.UserCVs
            .Include(cv => cv.CVTemplate)
            .Where(cv => cv.UserId == userId)
            .OrderByDescending(cv => cv.UploadedAt)
            .ToListAsync();
    }

    // ✅ امسح CV
    public async Task DeleteAsync(UserCV cv)
    {
        _context.UserCVs.Remove(cv);
    }
}