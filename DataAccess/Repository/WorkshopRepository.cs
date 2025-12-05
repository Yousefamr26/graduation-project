using Business_Logic.Errors;
using DataAccess.Abstractions;
using DataAccess.Contexts;
using DataAccess.Entities.Workshop;
using DataAccess.IRepository;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;

namespace DataAccess.Repository
{
    public class WorkshopRepository : IWorkshopRepository
    {
        private readonly ApplicationDbContext _context;

        public WorkshopRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<Result<WorkshopSec1>> GetByIdWithDetailsAsync(int id)
        {
            var workshop = await _context.workshopSec1s
                .IncludeAll()
                .FirstOrDefaultAsync(w => w.Id == id);

            return workshop != null
                ? Result.Success(workshop)
                : Result.Failure<WorkshopSec1>(WorkshopErrors.WorkshopNotFound);
        }

        public async Task<Result<IEnumerable<WorkshopSec1>>> GetAllWithDetailsAsync()
        {
            var list = await _context.workshopSec1s.IncludeAll().ToListAsync();
            return Result.Success(list.AsEnumerable());
        }

        public async Task<Result<IEnumerable<WorkshopSec1>>> GetPublishedWorkshopsAsync()
        {
            var list = await _context.workshopSec1s
                .Where(w => w.IsPublished)
                .IncludeAll()
                .ToListAsync();

            return Result.Success(list.AsEnumerable());
        }

        public async Task<Result<IEnumerable<WorkshopSec1>>> GetByUniversityAsync(int universityId)
        {
            var list = await _context.workshopSec1s
                .Where(w => w.UniversityId == universityId)
                .IncludeAll()
                .ToListAsync();

            return Result.Success(list.AsEnumerable());
        }

        public async Task<Result<IEnumerable<WorkshopSec1>>> SearchWorkshopsAsync(string searchTerm)
        {
            var list = await _context.workshopSec1s
                .Where(w => w.Title.Contains(searchTerm))
                .IncludeAll()
                .ToListAsync();

            return Result.Success(list.AsEnumerable());
        }

        public async Task<Result<WorkshopSec1>> AddWorkshopAsync(WorkshopSec1 entity)
        {
            try
            {
                await _context.workshopSec1s.AddAsync(entity);
                await _context.SaveChangesAsync();
                return Result.Success(entity);  
            }
            catch (Exception ex)
            {
                return Result.Failure<WorkshopSec1>(new Error("Workshop.CreateFailed", ex.Message));
            }
        }

        public async Task<Result> UpdateAsync(WorkshopSec1 entity)
        {
            var existing = await _context.workshopSec1s.FindAsync(entity.Id);
            if (existing == null) return Result.Failure(WorkshopErrors.WorkshopNotFound);

            _context.Entry(existing).CurrentValues.SetValues(entity);
            await _context.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<Result> DeleteAsync(int id)
        {
            var entity = await _context.workshopSec1s.FindAsync(id);
            if (entity == null) return Result.Failure(WorkshopErrors.WorkshopNotFound);

            _context.workshopSec1s.Remove(entity);
            await _context.SaveChangesAsync();
            return Result.Success();
        }


        public async Task<Result> BulkDeleteAsync(List<int> ids)
        {
            var list = await _context.workshopSec1s.Where(w => ids.Contains(w.Id)).ToListAsync();
            if (!list.Any()) return Result.Failure(WorkshopErrors.WorkshopBulkNotFound);

            _context.workshopSec1s.RemoveRange(list);
            await _context.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<Result> ToggleStatusAsync(int id)
        {
            var workshop = await _context.workshopSec1s.FindAsync(id);
            if (workshop == null) return Result.Failure(WorkshopErrors.WorkshopNotFound);

            workshop.IsPublished = !workshop.IsPublished;
            await _context.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<Result> BulkUpdateStatusAsync(List<int> ids, bool isPublished)
        {
            var list = await _context.workshopSec1s.Where(w => ids.Contains(w.Id)).ToListAsync();
            if (!list.Any()) return Result.Failure(WorkshopErrors.WorkshopBulkNotFound);

            foreach (var w in list)
                w.IsPublished = isPublished;

            await _context.SaveChangesAsync();
            return Result.Success();
        }
        public async Task<Result<List<WorkshopSec1>>> GetLatestWorkshopsAsync(int count)
        {
            try
            {
                var workshops = await _context.workshopSec1s
                    .Where(w => w.IsPublished)
                    .OrderByDescending(w => w.CreatedAt)
                    .Take(count)
                    .Include(w => w.Activities)
                    .Include(w => w.Materials)
                    .ToListAsync();

                return Result.Success(workshops);
            }
            catch (Exception ex)
            {
                return Result.Failure<List<WorkshopSec1>>(new Error("Workshop.LatestFailed", ex.Message));
            }
        }

        public async Task<Result<List<WorkshopSec1>>> GetTopWorkshopsByPointsAsync(int count)
        {
            try
            {
                var workshops = await _context.workshopSec1s
                    .Where(w => w.IsPublished)
                    .OrderByDescending(w => w.TotalPoints)
                    .Take(count)
                    .Include(w => w.Activities)
                    .Include(w => w.Materials)
                    .ToListAsync();

                return Result.Success(workshops);
            }
            catch (Exception ex)
            {
                return Result.Failure<List<WorkshopSec1>>(new Error("Workshop.TopFailed", ex.Message));
            }
        }


        public async Task<bool> IsTitleExistsAsync(string title, int? excludeId = null)
        {
            return await _context.workshopSec1s
                .AnyAsync(w => w.Title == title && (!excludeId.HasValue || w.Id != excludeId.Value));
        }

        public async Task<IEnumerable<WorkshopSec1>> GetAllAsync() => await _context.workshopSec1s.ToListAsync();
        public async Task<WorkshopSec1?> GetByIdAsync(int id) => await _context.workshopSec1s.FindAsync(id);
        public async Task<IEnumerable<WorkshopSec1>> FindAsync(Expression<System.Func<WorkshopSec1, bool>> predicate)
            => await _context.workshopSec1s.Where(predicate).ToListAsync();
        public async Task<WorkshopSec1?> FirstOrDefaultAsync(Expression<System.Func<WorkshopSec1, bool>> predicate)
            => await _context.workshopSec1s.FirstOrDefaultAsync(predicate);
        public async Task<bool> AnyAsync(Expression<System.Func<WorkshopSec1, bool>> predicate)
            => await _context.workshopSec1s.AnyAsync(predicate);
        public async Task<int> CountAsync(Expression<System.Func<WorkshopSec1, bool>>? predicate = null)
            => predicate == null ? await _context.workshopSec1s.CountAsync() : await _context.workshopSec1s.CountAsync(predicate);
        public async Task<WorkshopSec1> AddAsync(WorkshopSec1 entity)
        {
            await _context.workshopSec1s.AddAsync(entity);
            await _context.SaveChangesAsync();
            return entity;
        }
        public async Task AddRangeAsync(IEnumerable<WorkshopSec1> entities)
        {
            await _context.workshopSec1s.AddRangeAsync(entities);
            await _context.SaveChangesAsync();
        }
        public void Update(WorkshopSec1 entity) => _context.workshopSec1s.Update(entity);
        public void Delete(WorkshopSec1 entity) => _context.workshopSec1s.Remove(entity);
        public async Task<bool> DeleteByIdAsync(int id)
        {
            var entity = await _context.workshopSec1s.FindAsync(id);
            if (entity == null) return false;

            _context.workshopSec1s.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }
        public void DeleteRange(IEnumerable<WorkshopSec1> entities) => _context.workshopSec1s.RemoveRange(entities);
        public async Task<int> SaveChangesAsync() => await _context.SaveChangesAsync();
    }

    static class WorkshopIncludeExtensions
    {
        public static IQueryable<WorkshopSec1> IncludeAll(this IQueryable<WorkshopSec1> query)
        {
            return query
                .Include(w => w.Materials)
                .Include(w => w.Activities)
                .Include(w => w.University);
        }
    }
}
