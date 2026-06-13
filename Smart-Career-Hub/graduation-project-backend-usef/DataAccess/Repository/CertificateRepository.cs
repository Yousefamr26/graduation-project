using DataAccess.Contexts;
using DataAccess.Entities.RoadMap;
using Microsoft.EntityFrameworkCore;

public class CertificateRepository : ICertificateRepository
{
    private readonly ApplicationDbContext _context;

    public CertificateRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task AddAsync(Certificate certificate)
    {
        await _context.Certificates.AddAsync(certificate);
    }

    public async Task<Certificate?> GetByIdAsync(Guid id)
    {
        return await _context.Certificates
            .Include(x => x.User)
            .Include(x => x.Roadmap)
            .Include(x => x.IssuedBy)
            .FirstOrDefaultAsync(x => x.Id == id);
    }

    public async Task<Certificate?> GetByUserAndRoadmapAsync(string userId, int roadmapId)
    {
        return await _context.Certificates
            .FirstOrDefaultAsync(x => x.UserId == userId && x.RoadmapId == roadmapId);
    }

    public async Task<bool> ExistsAsync(string userId, int roadmapId)
    {
        return await _context.Certificates
            .AnyAsync(x => x.UserId == userId && x.RoadmapId == roadmapId);
    }
}