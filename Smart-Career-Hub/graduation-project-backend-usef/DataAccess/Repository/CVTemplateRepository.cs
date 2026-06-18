using DataAccess.Contexts;
using Microsoft.EntityFrameworkCore;

public class CVTemplateRepository : ICVTemplateRepository
{
    private readonly ApplicationDbContext _context;

    public CVTemplateRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<CVTemplate?> GetByIdAsync(int id)
    {
        return await _context.CVTemplates
            .Include(t => t.Company)
            .FirstOrDefaultAsync(t => t.Id == id);
    }

    public async Task AddAsync(CVTemplate template)
    {
        await _context.CVTemplates.AddAsync(template);
    }

    public async Task<IEnumerable<CVTemplate>> GetAllAsync()
    {
        return await _context.CVTemplates
            .Include(t => t.Company)
            .OrderByDescending(t => t.UploadedAt)
            .ToListAsync();
    }

    // ✅ تمبليتس شركة معينة
    public async Task<IEnumerable<CVTemplate>> GetByCompanyIdAsync(string companyId)
    {
        return await _context.CVTemplates
            .Where(t => t.CompanyId == companyId)
            .OrderByDescending(t => t.UploadedAt)
            .ToListAsync();
    }

    public async Task DeleteAsync(CVTemplate template)
    {
        _context.CVTemplates.Remove(template);
    }
}