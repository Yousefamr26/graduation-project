using DataAccess.Entities.Job;
using DataAccess.Abstractions; // المفروض هنا Result<T>
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DataAccess.IRepository
{
    public interface IJobApplicationRepository : IGenericRepository<JobApplication>
    {
        // جلب تطبيق بعينه مع التفاصيل
        Task<Result<JobApplication>> GetByIdWithDetailsAsync(int id, CancellationToken cancellationToken = default);

        // جلب كل التطبيقات مع التفاصيل
        Task<Result<IEnumerable<JobApplication>>> GetAllWithDetailsAsync(CancellationToken cancellationToken = default);

        // جلب كل التطبيقات الخاصة بمستخدم معين
        Task<Result<IEnumerable<JobApplication>>> GetByUserIdAsync(string userId  , CancellationToken cancellationToken = default) ;

        // تحقق لو المستخدم قدم قبل كده على نفس الوظيفة
        Task<bool> ExistsAsync(string userId, int jobId);

        // إحصائيات التطبيقات حسب الحالة
        Task<int> CountAsync(string userId, ApplicationStatus? status = null , CancellationToken cancellationToken = default);

        // CRUD إضافي
        Task<Result<JobApplication>> AddApplicationAsync(JobApplication application , CancellationToken cancellationToken = default);
        Task<Result> UpdateApplicationAsync(JobApplication application , CancellationToken cancellationToken = default);
        Task<Result> DeleteApplicationAsync(int id);

        // تحديث حالة التطبيق
        Task<Result> UpdateStatusAsync(int id, ApplicationStatus status, CancellationToken cancellationToken = default);

        // Bulk Operations
        Task<Result> BulkUpdateStatusAsync(List<int> ids, ApplicationStatus status , CancellationToken cancellationToken = default);
        Task<Result> BulkDeleteAsync(List<int> ids , CancellationToken cancellationToken = default);
        Task<Result<IEnumerable<JobApplication>>> GetByJobIdAsync(int jobId, CancellationToken cancellationToken = default);
    }
}
