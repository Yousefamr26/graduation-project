using DataAccess.Contexts;
using DataAccess.Entities.Workshop;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

public class WorkshopEnrollmentRepository : IWorkshopEnrollmentRepository
{
    private readonly ApplicationDbContext _context;

    public WorkshopEnrollmentRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<bool> IsUserEnrolledAsync(int workshopId, string userId)
    {
        return await _context.WorkshopEnrollments
            .AnyAsync(e => e.WorkshopId == workshopId && e.UserId == userId);
    }

    public async Task<WorkshopEnrollment> AddAsync(WorkshopEnrollment enrollment)
    {
        await _context.WorkshopEnrollments.AddAsync(enrollment);
        await _context.SaveChangesAsync();
        return enrollment;
    }

    public async Task<IEnumerable<WorkshopEnrollment>> GetEnrollmentsByUserAsync(string userId)
    {
        return await _context.WorkshopEnrollments
            .Where(e => e.UserId == userId)
            .Include(e => e.Workshop)
            .ToListAsync();
    }

    public async Task<IEnumerable<WorkshopEnrollment>> GetEnrollmentsByWorkshopAsync(int workshopId)
    {
        return await _context.WorkshopEnrollments
            .Where(e => e.WorkshopId == workshopId)
            .Include(e => e.Workshop)
            .ToListAsync();
    }
    public async Task<WorkshopEnrollment?> GetEnrollmentAsync(int workshopId, string userId)
    {
        return await _context.WorkshopEnrollments
            .FirstOrDefaultAsync(e =>
                e.WorkshopId == workshopId &&
                e.UserId == userId);
    }
    public async Task<bool> DeleteEnrollmentAsync(int workshopId, string userId)
    {
        var enrollment = await _context.WorkshopEnrollments
            .FirstOrDefaultAsync(e =>
                e.WorkshopId == workshopId &&
                e.UserId == userId);

        if (enrollment == null)
            return false;

        _context.WorkshopEnrollments.Remove(enrollment);
        await _context.SaveChangesAsync();

        return true;
    }
}
