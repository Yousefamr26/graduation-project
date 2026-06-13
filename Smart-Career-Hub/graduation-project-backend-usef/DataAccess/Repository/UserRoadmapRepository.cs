using DataAccess.Abstractions;
using DataAccess.Contexts;
using DataAccess.Entities.RoadMap;
using DataAccess.Entities.Users;
using DataAccess.Errors;
using DataAccess.IRepository;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;
using System;

public class UserRoadmapRepository : IUserRoadmapRepository
{
    private readonly ApplicationDbContext _context;

    public UserRoadmapRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    // ==== Generic CRUD Methods ====
    public async Task<IEnumerable<UserRoadmap>> GetAllAsync()
    {
        return await _context.userRoadmaps
                             .Include(sr => sr.ProgressItems)
                             .Include(sr => sr.Roadmap)
                             .ToListAsync();
    }

    public async Task<UserRoadmap?> GetByIdAsync(int id)
    {
        return await _context.userRoadmaps
                             .Include(sr => sr.ProgressItems)
                             .Include(sr => sr.Roadmap)
                             .FirstOrDefaultAsync(sr => sr.Id == id);
    }

    public async Task<IEnumerable<UserRoadmap>> FindAsync(Expression<Func<UserRoadmap, bool>> predicate)
        => await _context.userRoadmaps.Where(predicate).ToListAsync();

    public async Task<UserRoadmap?> FirstOrDefaultAsync(Expression<Func<UserRoadmap, bool>> predicate)
        => await _context.userRoadmaps.FirstOrDefaultAsync(predicate);

    public async Task<bool> AnyAsync(Expression<Func<UserRoadmap, bool>> predicate)
        => await _context.userRoadmaps.AnyAsync(predicate);

    public async Task<int> CountAsync(Expression<Func<UserRoadmap, bool>>? predicate = null)
        => predicate == null
            ? await _context.userRoadmaps.CountAsync()
            : await _context.userRoadmaps.CountAsync(predicate);

    public async Task<UserRoadmap> AddAsync(UserRoadmap entity)
    {
        await _context.userRoadmaps.AddAsync(entity);
        await _context.SaveChangesAsync();
        return entity;
    }

    public async Task AddRangeAsync(IEnumerable<UserRoadmap> entities)
    {
        await _context.userRoadmaps.AddRangeAsync(entities);
        await _context.SaveChangesAsync();
    }

    public void Update(UserRoadmap entity) => _context.userRoadmaps.Update(entity);

    public void Delete(UserRoadmap entity) => _context.userRoadmaps.Remove(entity);

    public async Task<bool> DeleteByIdAsync(int id)
    {
        var entity = await GetByIdAsync(id);
        if (entity == null) return false;
        Delete(entity);
        await _context.SaveChangesAsync();
        return true;
    }

    public void DeleteRange(IEnumerable<UserRoadmap> entities) => _context.userRoadmaps.RemoveRange(entities);

    public async Task<int> SaveChangesAsync() => await _context.SaveChangesAsync();

    // ==== Specific methods for UserRoadmap ====

    public async Task<Result<UserRoadmap>> GetByIdWithProgressAsync(int id)
    {
        var sr = await _context.userRoadmaps
                               .Include(x => x.ProgressItems)
                               .Include(x => x.Roadmap)
                               .FirstOrDefaultAsync(x => x.Id == id);
        return sr == null
            ? Result.Failure<UserRoadmap>(StudentRoadmapErrors.StudentRoadmapNotFound)
            : Result.Success(sr);
    }

    public async Task<Result<IEnumerable<UserRoadmap>>> GetAllByUserIdAsync(string userId)
    {
        var list = await _context.userRoadmaps
                                 .Where(x => x.UserId == userId)
                                 .Include(x => x.ProgressItems)
                                 .Include(x => x.Roadmap)
                                 .ToListAsync();
        return Result.Success<IEnumerable<UserRoadmap>>(list);
    }

    public async Task<Result<UserRoadmap>> JoinRoadmapAsync(string userId, int roadmapId)
    {
        var alreadyJoined = await _context.userRoadmaps
                                          .AnyAsync(x => x.UserId == userId && x.RoadmapId == roadmapId);
        if (alreadyJoined)
            return Result.Failure<UserRoadmap>(StudentRoadmapErrors.StudentAlreadyJoined);

        var sr = new UserRoadmap
        {
            UserId = userId,
            RoadmapId = roadmapId,
            JoinedAt = DateTime.UtcNow,
            Status = "In Progress",
            ProgressPercent = 0
        };

        await _context.userRoadmaps.AddAsync(sr);
        await _context.SaveChangesAsync();

        return Result.Success(sr);
    }

    public async Task<Result> UpdateProgressAsync(UserProgress progress)
    {
        try
        {
            _context.userProgresses.Update(progress);
            await _context.SaveChangesAsync();
            return Result.Success();
        }
        catch
        {
            return Result.Failure(StudentRoadmapErrors.StudentRoadmapUpdateFailed);
        }
    }

    public async Task<Result<IEnumerable<UserProgress>>> GetProgressByUserRoadmapIdAsync(int userRoadmapId)
    {
        var list = await _context.userProgresses
                                 .Where(x => x.UserRoadmapId == userRoadmapId)
                                 .ToListAsync();
        return Result.Success<IEnumerable<UserProgress>>(list);
    }

    public async Task<Result<int>> GetTotalPointsAsync(string userId)
    {
        var points = await _context.userRoadmaps
                                   .Where(x => x.UserId == userId)
                                   .SelectMany(x => x.ProgressItems)
                                   .SumAsync(x => x.PointsEarned);
        return Result.Success(points);
    }

    public async Task<Result<double>> GetProgressPercentAsync(string userId, int roadmapId)
    {
        var ur = await _context.userRoadmaps
                               .Include(x => x.ProgressItems)
                               .FirstOrDefaultAsync(x => x.UserId == userId && x.RoadmapId == roadmapId);
        if (ur == null)
            return Result.Failure<double>(StudentRoadmapErrors.StudentRoadmapNotFound);

        var totalItems = ur.ProgressItems.Count;
        if (totalItems == 0) return Result.Success(0.0);

        var completedItems = ur.ProgressItems.Count(x => x.Completed);
        var percent = (double)completedItems / totalItems * 100;

        return Result.Success(percent);
    }

    public async Task<bool> IsJoinedAsync(string userId, int roadmapId)
    {
        return await _context.userRoadmaps
                             .AnyAsync(x => x.UserId == userId && x.RoadmapId == roadmapId);
    }

    // ✅ التعديل الأساسي - إضافة User مع StudentProfile و GraduateProfile
    public async Task<List<UserRoadmap>> GetByUserIdAsync(string userId)
    {
        return await _context.userRoadmaps
                             .Where(x => x.UserId == userId)
                             // ✅ جلب User مع Student/Graduate Profile
                             .Include(x => x.User)
                                .ThenInclude(u => u.StudentProfile)
                             .Include(x => x.User)
                                .ThenInclude(u => u.GraduateProfile)
                             // جلب باقي البيانات
                             .Include(x => x.ProgressItems)
                             .Include(x => x.Roadmap)
                                .ThenInclude(r => r.RequiredSkills)
                             .Include(x => x.Roadmap)
                                .ThenInclude(r => r.Company)
                             .ToListAsync();
    }

    public async Task<UserRoadmap?> GetByUserIdAndRoadmapAsync(string userId, int roadmapId)
    {
        return await _context.userRoadmaps
            .Include(ur => ur.Roadmap)
                .ThenInclude(r => r.RequiredSkills)
            .Include(ur => ur.Roadmap)
                .ThenInclude(r => r.LearningMaterials)
            .Include(ur => ur.Roadmap)
                .ThenInclude(r => r.Projects)
            .Include(ur => ur.Roadmap)
                .ThenInclude(r => r.Quizzes)
            .Include(ur => ur.ProgressItems)
            .FirstOrDefaultAsync(ur => ur.UserId == userId && ur.RoadmapId == roadmapId);
    }
    public async Task<Result> AddOrUpdateProgressAsync(UserProgress progress)
    {
        try
        {
            // البحث عن العنصر الحالي في progress
            var existing = await _context.userProgresses
                .FirstOrDefaultAsync(x => x.UserRoadmapId == progress.UserRoadmapId
                                       && x.MaterialId == progress.MaterialId
                                       && x.MaterialType == progress.MaterialType);

            if (existing == null)
            {
                // العنصر جديد → إضافة
                await _context.userProgresses.AddAsync(progress);
            }
            else
            {
                // العنصر موجود → تحديث
                existing.Completed = progress.Completed;
                existing.CompletedAt = progress.CompletedAt;
                existing.PointsEarned = progress.PointsEarned;

                _context.userProgresses.Update(existing);
            }

            await _context.SaveChangesAsync();
            return Result.Success();
        }
        catch
        {
            return Result.Failure(StudentRoadmapErrors.StudentRoadmapUpdateFailed);
        }
    }
    public async Task<IEnumerable<UserRoadmap>> GetByRoadmapIdAsync(int roadmapId)
    {
        return await _context.userRoadmaps
            .Where(ur => ur.RoadmapId == roadmapId)
            .Include(ur => ur.ProgressItems)
            .ToListAsync();
    }
}