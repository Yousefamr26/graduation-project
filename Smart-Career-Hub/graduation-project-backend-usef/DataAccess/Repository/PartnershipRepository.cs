using Business_Logic.Errors;
using DataAccess.Abstractions;
using DataAccess.Contexts;
using DataAccess.Entities.Partnership;
using DataAccess.IRepository;
using Microsoft.EntityFrameworkCore;

namespace DataAccess.Repository
{
    public class PartnershipRepository
        : GenericRepository<Partnership>, IPartnershipRepository
    {
        private readonly ApplicationDbContext _context;

        public PartnershipRepository(ApplicationDbContext context)
            : base(context)
        {
            _context = context;
        }

        // ================= GET =================

        public async Task<Result<Partnership>> GetByIdAsync(int id)
        {
            var partnership = await _dbSet
                .Include(p => p.University)
                .Include(p => p.Company)
                .Include(p => p.PartnershipEvents)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (partnership == null)
                return Result.Failure<Partnership>(
                    PartnershipErrors.PartnershipNotFound);

            return Result.Success(partnership);
        }

        public async Task<Result<IEnumerable<Partnership>>> GetAllAsync()
        {
            var partnerships = await _dbSet
                .Include(p => p.University)
                .Include(p => p.Company)
                .ToListAsync();

            if (!partnerships.Any())
                return Result.Failure<IEnumerable<Partnership>>(
                    PartnershipErrors.PartnershipNotFound);

            return Result.Success(partnerships.AsEnumerable());
        }

        // ================= CREATE =================

        public async Task<Result<Partnership>> CreateAsync(Partnership partnership)
        {
            if (partnership == null)
                return Result.Failure<Partnership>(
                    PartnershipErrors.PartnershipNull);

            partnership.CreatedAt = DateTime.UtcNow;
            partnership.UpdatedAt = DateTime.UtcNow;

            await _dbSet.AddAsync(partnership);
            await _context.SaveChangesAsync();

            return Result.Success(partnership);
        }

        // ================= UPDATE =================

        public async Task<Result<Partnership>> UpdateAsync(Partnership partnership)
        {
            if (partnership == null)
                return Result.Failure<Partnership>(
                    PartnershipErrors.PartnershipNull);

            var existing = await _dbSet
                .FirstOrDefaultAsync(p => p.Id == partnership.Id);

            if (existing == null)
                return Result.Failure<Partnership>(
                    PartnershipErrors.PartnershipNotFound);

            existing.CompanyName = partnership.CompanyName;
            existing.IndustryField = partnership.IndustryField;
            existing.ContactPersonName = partnership.ContactPersonName;
            existing.ContactEmail = partnership.ContactEmail;
            existing.Website = partnership.Website;
            existing.Location = partnership.Location;
            existing.PartnershipDetails = partnership.PartnershipDetails;
            existing.PartnershipType = partnership.PartnershipType;
            existing.Status = partnership.Status;
            existing.StartDate = partnership.StartDate;
            existing.UpdatedAt = DateTime.UtcNow;

            _dbSet.Update(existing);
            await _context.SaveChangesAsync();

            return Result.Success(existing);
        }

        // ================= DELETE =================

        public async Task<Result<bool>> DeleteAsync(int id)
        {
            var partnership = await _dbSet
                .FirstOrDefaultAsync(p => p.Id == id);

            if (partnership == null)
                return Result.Failure<bool>(
                    PartnershipErrors.PartnershipNotFound);

            _dbSet.Remove(partnership);
            await _context.SaveChangesAsync();

            return Result.Success(true);
        }

        // ================= BULK =================

        public async Task<Result<bool>> BulkDeleteAsync(List<int> ids)
        {
            var partnerships = await _dbSet
                .Where(p => ids.Contains(p.Id))
                .ToListAsync();

            if (!partnerships.Any())
                return Result.Failure<bool>(
                    PartnershipErrors.PartnershipBulkNotFound);

            _dbSet.RemoveRange(partnerships);
            await _context.SaveChangesAsync();

            return Result.Success(true);
        }

        public async Task<Result<bool>> BulkUpdateAsync(List<Partnership> partnerships)
        {
            if (partnerships == null || !partnerships.Any())
                return Result.Failure<bool>(
                    PartnershipErrors.PartnershipNull);

            foreach (var p in partnerships)
                p.UpdatedAt = DateTime.UtcNow;

            _dbSet.UpdateRange(partnerships);
            await _context.SaveChangesAsync();

            return Result.Success(true);
        }

        // ================= SEARCH =================

        public async Task<Result<IEnumerable<Partnership>>> SearchAsync(
            string? companyName,
            int? universityId,
            string? partnershipType)
        {
            var query = _dbSet.AsQueryable();

            if (!string.IsNullOrWhiteSpace(companyName))
                query = query.Where(p => p.CompanyName.Contains(companyName));

            if (universityId.HasValue)
                query = query.Where(p => p.UniversityId == universityId.Value);

            if (!string.IsNullOrWhiteSpace(partnershipType))
                query = query.Where(p => p.PartnershipType == partnershipType);

            var result = await query
                .Include(p => p.University)
                .Include(p => p.Company)
                .ToListAsync();

            if (!result.Any())
                return Result.Failure<IEnumerable<Partnership>>(
                    PartnershipErrors.PartnershipNotFound);

            return Result.Success(result.AsEnumerable());
        }
    }
}

