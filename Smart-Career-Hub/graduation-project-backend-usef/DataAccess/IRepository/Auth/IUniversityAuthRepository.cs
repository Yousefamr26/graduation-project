using DataAccess.Abstractions;
using DataAccess.Entities.User;
using System.Threading.Tasks;

namespace DataAccess.IRepository
{
    public interface IUniversityAuthRepository
    {
        // ===== Register Methods =====

        /// <summary>
        /// تحقق لو المستخدم موجود بالإيميل
        /// </summary>
        Task<bool> UserExistsByEmailAsync(string email);

        /// <summary>
        /// إنشاء ApplicationUser جديد
        /// </summary>
        Task<Result<ApplicationUser>> CreateUserAsync(ApplicationUser user, string password);

        /// <summary>
        /// تعيين الدور للمستخدم (UniversityRole مثلاً)
        /// </summary>
        Task<Result> AssignRoleAsync(ApplicationUser user, string role);

        /// <summary>
        /// إنشاء ملف الجامعة بعد إنشاء الـ ApplicationUser
        /// </summary>
        Task<Result<University>> CreateUniversityProfileAsync(University university);

        // ===== Login Methods =====

        /// <summary>
        /// جلب المستخدم بالإيميل
        /// </summary>
        Task<ApplicationUser?> GetUserByEmailAsync(string email);

        /// <summary>
        /// التحقق من كلمة المرور
        /// </summary>
        Task<bool> CheckPasswordAsync(ApplicationUser user, string password);

        /// <summary>
        /// تسجيل دخول المستخدم
        /// </summary>
        Task<Result> SignInAsync(ApplicationUser user, bool rememberMe);

        /// <summary>
        /// جلب ملف الجامعة باستخدام UserId
        /// </summary>
        Task<University?> GetUniversityProfileByUserIdAsync(string userId);
    }
}