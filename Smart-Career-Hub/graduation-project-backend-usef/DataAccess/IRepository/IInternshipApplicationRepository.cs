using DataAccess.Entities.Job;
using System.Threading;
using System.Threading.Tasks;

public interface IInternshipApplicationRepository
{
    Task<InternshipApplication> GetByIdAsync(string id, CancellationToken cancellationToken = default);
    Task AddAsync(InternshipApplication application, CancellationToken cancellationToken = default);
    Task<bool> HasUserAppliedAsync(int internshipId, string userId, CancellationToken cancellationToken = default);
    Task<List<InternshipApplication>> GetByUserIdAsync(string userId);
    Task<IEnumerable<InternshipApplication>> GetByInternshipIdAsync(int internshipId, CancellationToken cancellationToken = default);
    void Delete(InternshipApplication application);




}
