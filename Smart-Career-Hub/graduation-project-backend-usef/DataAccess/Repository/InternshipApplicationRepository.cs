using DataAccess.Contexts;
using DataAccess.Entities.Job;
using Microsoft.EntityFrameworkCore;
using System.Threading;
using System.Threading.Tasks;

public class InternshipApplicationRepository : IInternshipApplicationRepository
{
    private readonly ApplicationDbContext _db;

    public InternshipApplicationRepository(ApplicationDbContext db)
    {
        _db = db;
    }

    public async Task<InternshipApplication> GetByIdAsync(string id, CancellationToken cancellationToken = default)
    {
        return await _db.internshipApplications
            .Include(a => a.User)
            .Include(a => a.Internship)
            .FirstOrDefaultAsync(a => a.Id == id, cancellationToken);
    }

    public async Task AddAsync(InternshipApplication application, CancellationToken cancellationToken = default)
    {
        await _db.internshipApplications.AddAsync(application, cancellationToken);
    }

    public async Task<bool> HasUserAppliedAsync(int internshipId, string userId, CancellationToken cancellationToken = default)
    {
        return await _db.internshipApplications
            .AnyAsync(a => a.InternshipId == internshipId && a.UserId == userId, cancellationToken);
    }
    public async Task<List<InternshipApplication>> GetByUserIdAsync(string userId)
    {
        return await _db.internshipApplications
            .Include(a => a.Internship)
            .Where(a => a.UserId == userId)
            .ToListAsync();
    }
    public async Task<IEnumerable<InternshipApplication>> GetByInternshipIdAsync(int internshipId, CancellationToken cancellationToken = default)
    {
        return await _db.internshipApplications
            .Include(a => a.User)
            .Include(a => a.Internship)
            .Where(a => a.InternshipId == internshipId)
            .ToListAsync(cancellationToken);
    }
    public void Delete(InternshipApplication application)
    {
        _db.internshipApplications.Remove(application);
    }


}
