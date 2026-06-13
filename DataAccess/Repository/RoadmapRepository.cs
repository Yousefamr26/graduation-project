using DataAccess.Abstractions;
using Business_Logic.Errors;
using DataAccess.Contexts;
using DataAccess.Entities.RoadMap;
using DataAccess.IRepository;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;

namespace DataAccess.Repository
{
    public class RoadmapRepository : IRoadmapRepository
    {
        private readonly ApplicationDbContext _context;

        public RoadmapRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        
        public async Task<Result<RoadmapSec1>> GetByIdWithDetailsAsync(int id)
        {
            var roadmap = await _context.RoadmapsSec1
                .IncludeAll()
                .FirstOrDefaultAsync(r => r.Id == id);

            return roadmap is null
                ? Result.Failure<RoadmapSec1>(RoadmapErrors.RoadmapNotFound)
                : Result.Success(roadmap);
        }

        public async Task<Result<IEnumerable<RoadmapSec1>>> GetAllWithDetailsAsync()
        {
            var list = await _context.RoadmapsSec1.IncludeAll().ToListAsync();
            return Result.Success<IEnumerable<RoadmapSec1>>(list);
        }

        public async Task<Result<IEnumerable<RoadmapSec1>>> GetPublishedRoadmapsAsync()
        {
            var list = await _context.RoadmapsSec1
                .Where(r => r.IsPublished)
                .IncludeAll()
                .ToListAsync();

            return Result.Success<IEnumerable<RoadmapSec1>>(list);
        }

        public async Task<Result<IEnumerable<RoadmapSec1>>> GetByTargetRoleAsync(string role)
        {
            var valid = new[] { "Student", "Graduate", "Both" };
            if (!valid.Contains(role))
                return Result.Failure<IEnumerable<RoadmapSec1>>(RoadmapErrors.RoadmapInvalidTargetRole);

            var list = await _context.RoadmapsSec1
                .Where(r => r.TargetRole == role)
                .IncludeAll()
                .ToListAsync();

            return Result.Success<IEnumerable<RoadmapSec1>>(list);
        }

        public async Task<Result<IEnumerable<RoadmapSec1>>> SearchRoadmapsAsync(string search)
        {
            var list = await _context.RoadmapsSec1
                .Where(r => r.Title.Contains(search) || r.Description.Contains(search))
                .IncludeAll()
                .ToListAsync();

            return Result.Success<IEnumerable<RoadmapSec1>>(list);
        }

        public async Task<Result<IEnumerable<RoadmapSec1>>> GetLatestRoadmapsAsync(int count = 20)
        {
            var list = await _context.RoadmapsSec1
                .OrderByDescending(r => r.CreatedAt)
                .Take(count)
                .IncludeAll()
                .ToListAsync();

            return Result.Success<IEnumerable<RoadmapSec1>>(list);
        }

        public async Task<Result<IEnumerable<RoadmapSec1>>> GetTopRoadmapsByPointsAsync(int count = 20)
        {
            var list = await _context.RoadmapsSec1
                .OrderByDescending(r => r.TotalPoints)
                .Take(count)
                .IncludeAll()
                .ToListAsync();

            return Result.Success<IEnumerable<RoadmapSec1>>(list);
        }

        public async Task<Result<RoadmapSec1>> AddRoadmapAsync(RoadmapSec1 roadmap)
        {
            if (await IsTitleExistsAsync(roadmap.Title))
                return Result.Failure<RoadmapSec1>(RoadmapErrors.RoadmapTitleExists);

            await _context.RoadmapsSec1.AddAsync(roadmap);
            await _context.SaveChangesAsync();

            return Result.Success(roadmap);
        }

        public async Task<Result> UpdateAsync(RoadmapSec1 roadmap)
        {
            var existing = await _context.RoadmapsSec1.FindAsync(roadmap.Id);
            if (existing is null)
                return Result.Failure(RoadmapErrors.RoadmapNotFound);

            if (await IsTitleExistsAsync(roadmap.Title, roadmap.Id))
                return Result.Failure(RoadmapErrors.RoadmapTitleExists);

            _context.Entry(existing).CurrentValues.SetValues(roadmap);
            await _context.SaveChangesAsync();

            return Result.Success();
        }

        public async Task<Result> DeleteAsync(int id)
        {
            var entity = await _context.RoadmapsSec1.FindAsync(id);
            if (entity is null)
                return Result.Failure(RoadmapErrors.RoadmapNotFound);

            _context.RoadmapsSec1.Remove(entity);
            await _context.SaveChangesAsync();

            return Result.Success();
        }

        public async Task<Result> ToggleStatusAsync(int id)
        {
            var roadmap = await _context.RoadmapsSec1.FindAsync(id);
            if (roadmap is null)
                return Result.Failure(RoadmapErrors.RoadmapNotFound);

            roadmap.IsPublished = !roadmap.IsPublished;
            roadmap.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<Result> BulkUpdateStatusAsync(List<int> ids, bool isPublished)
        {
            var list = await _context.RoadmapsSec1.Where(r => ids.Contains(r.Id)).ToListAsync();
            if (!list.Any())
                return Result.Failure(RoadmapErrors.RoadmapBulkNotFound);

            foreach (var r in list)
            {
                r.IsPublished = isPublished;
                r.UpdatedAt = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<Result> BulkDeleteAsync(List<int> ids)
        {
            var list = await _context.RoadmapsSec1.Where(r => ids.Contains(r.Id)).ToListAsync();
            if (!list.Any())
                return Result.Failure(RoadmapErrors.RoadmapBulkNotFound);

            _context.RoadmapsSec1.RemoveRange(list);
            await _context.SaveChangesAsync();

            return Result.Success();
        }

        public async Task<bool> IsTitleExistsAsync(string title, int? excludeId = null)
        {
            return await _context.RoadmapsSec1
                .AnyAsync(r => r.Title == title && (!excludeId.HasValue || r.Id != excludeId.Value));
        }

     

        public async Task<IEnumerable<RoadmapSec1>> GetAllAsync()
        {
            return await _context.RoadmapsSec1.ToListAsync();
        }

        public async Task<RoadmapSec1?> GetByIdAsync(int id)
        {
            return await _context.RoadmapsSec1.FindAsync(id);
        }

        public async Task<IEnumerable<RoadmapSec1>> FindAsync(Expression<Func<RoadmapSec1, bool>> predicate)
        {
            return await _context.RoadmapsSec1.Where(predicate).ToListAsync();
        }

        public async Task<RoadmapSec1?> FirstOrDefaultAsync(Expression<Func<RoadmapSec1, bool>> predicate)
        {
            return await _context.RoadmapsSec1.FirstOrDefaultAsync(predicate);
        }

        public async Task<bool> AnyAsync(Expression<Func<RoadmapSec1, bool>> predicate)
        {
            return await _context.RoadmapsSec1.AnyAsync(predicate);
        }

        public async Task<int> CountAsync(Expression<Func<RoadmapSec1, bool>>? predicate = null)
        {
            return predicate is null
                ? await _context.RoadmapsSec1.CountAsync()
                : await _context.RoadmapsSec1.CountAsync(predicate);
        }

        public async Task<RoadmapSec1> AddAsync(RoadmapSec1 entity)
        {
            await _context.RoadmapsSec1.AddAsync(entity);
            await _context.SaveChangesAsync();
            return entity;
        }

        public async Task AddRangeAsync(IEnumerable<RoadmapSec1> entities)
        {
            await _context.RoadmapsSec1.AddRangeAsync(entities);
            await _context.SaveChangesAsync();
        }

        public void Update(RoadmapSec1 entity)
        {
            _context.RoadmapsSec1.Update(entity);
        }

        public void Delete(RoadmapSec1 entity)
        {
            _context.RoadmapsSec1.Remove(entity);
        }

        public async Task<bool> DeleteByIdAsync(int id)
        {
            var entity = await _context.RoadmapsSec1.FindAsync(id);
            if (entity == null) return false;

            _context.RoadmapsSec1.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }

        public void DeleteRange(IEnumerable<RoadmapSec1> entities)
        {
            _context.RoadmapsSec1.RemoveRange(entities);
        }

        public async Task<int> SaveChangesAsync()
        {
            return await _context.SaveChangesAsync();
        }
    }

    static class RoadmapIncludeExtensions
    {
        public static IQueryable<RoadmapSec1> IncludeAll(this IQueryable<RoadmapSec1> query)
        {
            return query
                .Include(r => r.RequiredSkills)
                .Include(r => r.Projects)
                .Include(r => r.Quizzes)
                    .ThenInclude(q => q.Questions) 
                .Include(r => r.LearningMaterials);
        }
    }
}
