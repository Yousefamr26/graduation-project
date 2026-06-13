using DataAccess.Contexts;
using DataAccess.Entities.Job;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

public class InternshipRepository : IInternshipRepository
{
    private readonly ApplicationDbContext _db;

    public InternshipRepository(ApplicationDbContext db)
    {
        _db = db;
    }

    public async Task<Internship> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        return await _db.internships
            .Include(i => i.RequiredSkills)
            .Include(i => i.Requirements)
            .Include(i => i.Company)
            .FirstOrDefaultAsync(i => i.Id == id, cancellationToken);
    }

    public async Task<IEnumerable<Internship>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _db.internships
            .Include(i => i.Company)
            .ToListAsync(cancellationToken);
    }

    public async Task AddAsync(Internship internship, CancellationToken cancellationToken = default)
    {
        // ✅ Entity Framework هيحفظ الـ Internship والـ Skills والـ Requirements تلقائياً
        await _db.internships.AddAsync(internship, cancellationToken);
    }

    public void Update(Internship internship)
    {
        _db.internships.Update(internship);
    }

    public void Delete(Internship internship)
    {
        _db.internships.Remove(internship);
    }

    public async Task<bool> ExistsAsync(int id, CancellationToken cancellationToken = default)
    {
        return await _db.internships.AnyAsync(i => i.Id == id, cancellationToken);
    }

}