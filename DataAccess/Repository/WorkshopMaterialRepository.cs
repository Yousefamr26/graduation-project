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
    public class WorkshopMaterialRepository : IWorkshopMaterialRepository
    {
        private readonly ApplicationDbContext _context;

        public WorkshopMaterialRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<Result<IEnumerable<WorkshopMaterial>>> GetByWorkshopIdAsync(int workshopId)
        {
            var list = await _context.WorkshopMaterials
                .Where(m => m.WorkshopId == workshopId)
                .ToListAsync();

            return Result.Success(list.AsEnumerable());
        }

        public async Task<Result<WorkshopMaterial>> AddAsync(WorkshopMaterial material)
        {
            try
            {
                await _context.WorkshopMaterials.AddAsync(material);
                await _context.SaveChangesAsync();
                return Result.Success(material);
            }
            catch (System.Exception ex)
            {
                return Result.Failure<WorkshopMaterial>(new Error("WorkshopMaterial.CreateFailed", ex.Message));
            }
        }

        public async Task<Result> UpdateAsync(WorkshopMaterial material)
        {
            var existing = await _context.WorkshopMaterials.FindAsync(material.Id);
            if (existing == null) return Result.Failure(WorkshopErrors.WorkshopNotFound);

            _context.Entry(existing).CurrentValues.SetValues(material);
            await _context.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<Result> DeleteAsync(int id)
        {
            var existing = await _context.WorkshopMaterials.FindAsync(id);
            if (existing == null) return Result.Failure(WorkshopErrors.WorkshopNotFound);

            _context.WorkshopMaterials.Remove(existing);
            await _context.SaveChangesAsync();
            return Result.Success();
        }


        public async Task<IEnumerable<WorkshopMaterial>> GetAllAsync() => await _context.WorkshopMaterials.ToListAsync();

        public async Task<WorkshopMaterial?> GetByIdAsync(int id) => await _context.WorkshopMaterials.FindAsync(id);

        public async Task<IEnumerable<WorkshopMaterial>> FindAsync(System.Linq.Expressions.Expression<System.Func<WorkshopMaterial, bool>> predicate)
            => await _context.WorkshopMaterials.Where(predicate).ToListAsync();

        public async Task<WorkshopMaterial?> FirstOrDefaultAsync(System.Linq.Expressions.Expression<System.Func<WorkshopMaterial, bool>> predicate)
            => await _context.WorkshopMaterials.FirstOrDefaultAsync(predicate);

        public async Task<bool> AnyAsync(System.Linq.Expressions.Expression<System.Func<WorkshopMaterial, bool>> predicate)
            => await _context.WorkshopMaterials.AnyAsync(predicate);

        public async Task<int> CountAsync(System.Linq.Expressions.Expression<System.Func<WorkshopMaterial, bool>>? predicate = null)
            => predicate == null ? await _context.WorkshopMaterials.CountAsync() : await _context.WorkshopMaterials.CountAsync(predicate);

        public async Task AddRangeAsync(IEnumerable<WorkshopMaterial> entities)
        {
            await _context.WorkshopMaterials.AddRangeAsync(entities);
            await _context.SaveChangesAsync();
        }

        public void Update(WorkshopMaterial entity) => _context.WorkshopMaterials.Update(entity);

        public void Delete(WorkshopMaterial entity) => _context.WorkshopMaterials.Remove(entity);

        public async Task<bool> DeleteByIdAsync(int id)
        {
            var entity = await _context.WorkshopMaterials.FindAsync(id);
            if (entity == null) return false;

            _context.WorkshopMaterials.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }

        public void DeleteRange(IEnumerable<WorkshopMaterial> entities) => _context.WorkshopMaterials.RemoveRange(entities);

        public async Task<int> SaveChangesAsync() => await _context.SaveChangesAsync();

        async Task<WorkshopMaterial> IGenericRepository<WorkshopMaterial>.AddAsync(WorkshopMaterial entity)
        {
            await _context.WorkshopMaterials.AddAsync(entity);
            await _context.SaveChangesAsync();
            return entity;
        }
    }
}
