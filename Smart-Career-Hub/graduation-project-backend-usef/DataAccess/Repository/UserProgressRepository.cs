using Business_Logic.Errors;
using DataAccess.Abstractions;
using DataAccess.Contexts;
using DataAccess.Entities.RoadMap;
using DataAccess.Errors;
using DataAccess.IRepository;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;

public class UserProgressRepository : IuserProgressRepository
{
    private readonly ApplicationDbContext _context;

    public UserProgressRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    // ================= Generic Repository Methods =================
    public async Task<IEnumerable<UserProgress>> GetAllAsync()
    {
        return await _context.studentProgresses
                             .Include(sp => sp.UserRoadmap)
                             .ThenInclude(sr => sr.Roadmap)
                             .ToListAsync();
    }

    async Task<UserProgress?> IGenericRepository<UserProgress>.GetByIdAsync(int id)
    {
        return await _context.studentProgresses
                             .Include(sp => sp.UserRoadmap)
                             .ThenInclude(sr => sr.Roadmap)
                             .FirstOrDefaultAsync(sp => sp.Id == id);
    }

    public async Task<IEnumerable<UserProgress>> FindAsync(Expression<Func<UserProgress, bool>> predicate)
    {
        return await _context.studentProgresses.Where(predicate)
                             .Include(sp => sp.UserRoadmap)
                             .ThenInclude(sr => sr.Roadmap)
                             .ToListAsync();
    }

    public async Task<UserProgress?> FirstOrDefaultAsync(Expression<Func<UserProgress, bool>> predicate)
    {
        return await _context.studentProgresses.FirstOrDefaultAsync(predicate);
    }

    public async Task<bool> AnyAsync(Expression<Func<UserProgress, bool>> predicate)
    {
        return await _context.studentProgresses.AnyAsync(predicate);
    }

    public async Task<int> CountAsync(Expression<Func<UserProgress, bool>>? predicate = null)
    {
        return predicate == null
            ? await _context.studentProgresses.CountAsync()
            : await _context.studentProgresses.CountAsync(predicate);
    }

    public async Task<UserProgress> AddAsync(UserProgress entity)
    {
        await _context.studentProgresses.AddAsync(entity);
        await _context.SaveChangesAsync();
        return entity;
    }

    public async Task AddRangeAsync(IEnumerable<UserProgress> entities)
    {
        await _context.studentProgresses.AddRangeAsync(entities);
        await _context.SaveChangesAsync();
    }

    public void Update(UserProgress entity)
    {
        _context.studentProgresses.Update(entity);
    }

    public void Delete(UserProgress entity)
    {
        _context.studentProgresses.Remove(entity);
    }

    public async Task<bool> DeleteByIdAsync(int id)
    {
        var entity = await ((IGenericRepository<UserProgress>)this).GetByIdAsync(id);
        if (entity == null) return false;
        Delete(entity);
        await _context.SaveChangesAsync();
        return true;
    }

    public void DeleteRange(IEnumerable<UserProgress> entities)
    {
        _context.studentProgresses.RemoveRange(entities);
    }

    public async Task<int> SaveChangesAsync()
    {
        return await _context.SaveChangesAsync();
    }

    // ================= IStudentProgressRepository Methods =================
    public async Task<Result<UserProgress>> GetByIdAsync(int id)
    {
        var progress = await ((IGenericRepository<UserProgress>)this).GetByIdAsync(id);
        if (progress == null)
            return (Result<UserProgress>)Result<UserProgress>.Failure(StudentProgressErrors.StudentProgressNotFound);

        return Result<UserProgress>.Success(progress);
    }

    public async Task<Result<IEnumerable<UserProgress>>> GetAllByStudentRoadmapIdAsync(int studentRoadmapId)
    {
        var list = await _context.studentProgresses
                                 .Where(sp => sp.UserRoadmapId == studentRoadmapId)
                                 .Include(sp => sp.UserRoadmap)
                                 .ThenInclude(sr => sr.Roadmap)
                                 .ToListAsync();
        return Result<IEnumerable<UserProgress>>.Success((IEnumerable<UserProgress>)list);


    }

    public async Task<Result> MarkAsCompletedAsync(int studentProgressId)
    {
        var progress = await ((IGenericRepository<UserProgress>)this).GetByIdAsync(studentProgressId);
        if (progress == null)
            return Result.Failure(StudentProgressErrors.StudentProgressNotFound);

        progress.Completed = true;
        progress.CompletedAt = DateTime.Now;

        try
        {
            Update(progress);
            await SaveChangesAsync();
            return Result.Success();
        }
        catch
        {
            return Result.Failure(StudentProgressErrors.StudentProgressUpdateFailed);
        }
    }

    public async Task<Result> UpdatePointsAsync(int studentProgressId, int points)
    {
        var progress = await ((IGenericRepository<UserProgress>)this).GetByIdAsync(studentProgressId);
        if (progress == null)
            return Result.Failure(StudentProgressErrors.StudentProgressNotFound);

        progress.PointsEarned = points;

        try
        {
            Update(progress);
            await SaveChangesAsync();
            return Result.Success();
        }
        catch
        {
            return Result.Failure(StudentProgressErrors.StudentProgressUpdateFailed);
        }
    }
}
