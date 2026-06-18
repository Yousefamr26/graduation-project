public interface IUserCVRepository
{
    Task<UserCV?> GetByIdAsync(int id);
    Task AddAsync(UserCV cv);
    // ✅ جيب كل CVs بتاعت يوزر
    Task<IEnumerable<UserCV>> GetByUserIdAsync(string userId);
    // ✅ امسح CV
    Task DeleteAsync(UserCV cv);
}