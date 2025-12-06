using Business_Logic.Errors;
using DataAccess.Abstractions;
using DataAccess.Contexts;
using DataAccess.Entities.Workshop;
using DataAccess.IRepository;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DataAccess.Repository
{
    public class WorkshopActivityRepository : IWorkshopActivityRepository
    {
        private readonly ApplicationDbContext _context;

        public WorkshopActivityRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<Result<IEnumerable<WorkshopActivity>>> GetByWorkshopIdAsync(int workshopId)
        {
            var activities = await _context.WorkshopActivities
                .Where(a => a.WorkshopId == workshopId)
                .ToListAsync();

            return Result.Success(activities.AsEnumerable());
        }

        public async Task<Result<WorkshopActivity>> AddAsync(WorkshopActivity activity)
        {
            try
            {
                await _context.WorkshopActivities.AddAsync(activity);
                await _context.SaveChangesAsync();
                return Result.Success(activity);
            }
            catch (System.Exception ex)
            {
                return Result.Failure<WorkshopActivity>(new Error("WorkshopActivity.CreateFailed", ex.Message));
            }
        }

        public async Task<Result> UpdateAsync(WorkshopActivity activity)
        {
            var existing = await _context.WorkshopActivities.FindAsync(activity.Id);
            if (existing == null) return Result.Failure(WorkshopErrors.WorkshopUpdateFailed);

            _context.Entry(existing).CurrentValues.SetValues(activity);
            await _context.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<Result> DeleteAsync(int id)
        {
            var entity = await _context.WorkshopActivities.FindAsync(id);
            if (entity == null) return Result.Failure(WorkshopErrors.WorkshopDeleteFailed);

            _context.WorkshopActivities.Remove(entity);
            await _context.SaveChangesAsync();
            return Result.Success();
        }


        public async Task<IEnumerable<WorkshopActivity>> GetAllAsync() => await _context.WorkshopActivities.ToListAsync();

        public async Task<WorkshopActivity?> GetByIdAsync(int id) => await _context.WorkshopActivities.FindAsync(id);

        public async Task<IEnumerable<WorkshopActivity>> FindAsync(System.Linq.Expressions.Expression<System.Func<WorkshopActivity, bool>> predicate)
            => await _context.WorkshopActivities.Where(predicate).ToListAsync();

        public async Task<WorkshopActivity?> FirstOrDefaultAsync(System.Linq.Expressions.Expression<System.Func<WorkshopActivity, bool>> predicate)
            => await _context.WorkshopActivities.FirstOrDefaultAsync(predicate);

        public async Task<bool> AnyAsync(System.Linq.Expressions.Expression<System.Func<WorkshopActivity, bool>> predicate)
            => await _context.WorkshopActivities.AnyAsync(predicate);

        public async Task<int> CountAsync(System.Linq.Expressions.Expression<System.Func<WorkshopActivity, bool>>? predicate = null)
            => predicate != null ? await _context.WorkshopActivities.CountAsync(predicate) : await _context.WorkshopActivities.CountAsync();

        public async Task AddRangeAsync(IEnumerable<WorkshopActivity> entities)
        {
            await _context.WorkshopActivities.AddRangeAsync(entities);
            await _context.SaveChangesAsync();
        }

        public void Update(WorkshopActivity entity) => _context.WorkshopActivities.Update(entity);

        public void Delete(WorkshopActivity entity) => _context.WorkshopActivities.Remove(entity);

        public async Task<bool> DeleteByIdAsync(int id)
        {
            var entity = await _context.WorkshopActivities.FindAsync(id);
            if (entity == null) return false;

            _context.WorkshopActivities.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }

        public void DeleteRange(IEnumerable<WorkshopActivity> entities) => _context.WorkshopActivities.RemoveRange(entities);

        public async Task<int> SaveChangesAsync() => await _context.SaveChangesAsync();

        async Task<WorkshopActivity> IGenericRepository<WorkshopActivity>.AddAsync(WorkshopActivity entity)
        {
            await _context.WorkshopActivities.AddAsync(entity);
            await _context.SaveChangesAsync();
            return entity;
        }
    }
}
