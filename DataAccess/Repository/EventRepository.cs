using Business_Logic.Errors;
using DataAccess.Abstractions;
using DataAccess.Contexts;
using DataAccess.Entities.Events;
using DataAccess.Errors;
using DataAccess.IRepository;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;

namespace DataAccess.Repository
{
    public class EventRepository : IEventRepository
    {
        private readonly ApplicationDbContext _context;

        public EventRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<Result<Event>> GetByIdWithDetailsAsync(int id)
        {
            var ev = await _context.events.FindAsync(id);
            return ev != null
                ? Result.Success(ev)
                : Result.Failure<Event>(EventErrors.EventNotFound);
        }

        public async Task<Result<IEnumerable<Event>>> GetAllWithDetailsAsync()
        {
            var list = await _context.events.ToListAsync();
            return Result.Success(list.AsEnumerable());
        }

        public async Task<Result<IEnumerable<Event>>> GetPublishedEventsAsync()
        {
            var list = await _context.events.Where(e => e.IsPublished).ToListAsync();
            return Result.Success(list.AsEnumerable());
        }

        public async Task<Result<IEnumerable<Event>>> GetUpcomingEventsAsync()
        {
            var list = await _context.events.Where(e => e.StartDate >= DateTime.Now).ToListAsync();
            return Result.Success(list.AsEnumerable());
        }

        public async Task<Result<IEnumerable<Event>>> SearchEventsAsync(string searchTerm)
        {
            var list = await _context.events
                .Where(e => e.Title.Contains(searchTerm) || e.Description.Contains(searchTerm))
                .ToListAsync();
            return Result.Success(list.AsEnumerable());
        }

        public async Task<Result<IEnumerable<Event>>> GetLatestEventsAsync(int count = 20)
        {
            try
            {
                var events = await _context.events
                    .Where(e => e.IsPublished)
                    .OrderByDescending(e => e.CreatedAt)
                    .Take(count)
                    .ToListAsync();

                return Result.Success(events.AsEnumerable());
            }
            catch (Exception ex)
            {
                return Result.Failure<IEnumerable<Event>>(new Error("Event.LatestFailed", ex.Message));
            }
        }

        public async Task<Result<IEnumerable<Event>>> GetTopEventsByPointsAsync(int count = 20)
        {
            try
            {
                var events = await _context.events
                    .Where(e => e.IsPublished)
                    .OrderByDescending(e => e.PointsForFullParticipation)
                    .Take(count)
                    .ToListAsync();

                return Result.Success(events.AsEnumerable());
            }
            catch (Exception ex)
            {
                return Result.Failure<IEnumerable<Event>>(new Error("Event.TopFailed", ex.Message));
            }
        }

        public async Task<Result<Event>> AddEventAsync(Event entity)
        {
            try
            {
                if (await IsTitleExistsAsync(entity.Title))
                    return Result.Failure<Event>(EventErrors.EventTitleExists);

                await _context.events.AddAsync(entity);
                await _context.SaveChangesAsync();
                return Result.Success(entity);
            }
            catch (Exception ex)
            {
                return Result.Failure<Event>(new Error("Event.CreateFailed", ex.Message));
            }
        }

        public async Task<Result> UpdateAsync(Event entity)
        {
            var existing = await _context.events.FindAsync(entity.Id);
            if (existing == null) return Result.Failure(EventErrors.EventNotFound);

            _context.Entry(existing).CurrentValues.SetValues(entity);
            await _context.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<Result> DeleteAsync(int id)
        {
            var entity = await _context.events.FindAsync(id);
            if (entity == null) return Result.Failure(EventErrors.EventNotFound);

            _context.events.Remove(entity);
            await _context.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<Result> BulkDeleteAsync(List<int> ids)
        {
            if (ids == null || ids.Count == 0)
                return Result.Failure(EventErrors.EventNoIdsProvided);

            var list = await _context.events.Where(e => ids.Contains(e.Id)).ToListAsync();
            if (!list.Any()) return Result.Failure(EventErrors.EventBulkNotFound);

            _context.events.RemoveRange(list);
            await _context.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<Result> ToggleStatusAsync(int id)
        {
            var entity = await _context.events.FindAsync(id);
            if (entity == null) return Result.Failure(EventErrors.EventNotFound);

            entity.IsPublished = !entity.IsPublished;
            await _context.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<Result> BulkUpdateStatusAsync(List<int> ids, bool isPublished)
        {
            if (ids == null || ids.Count == 0)
                return Result.Failure(EventErrors.EventNoIdsProvided);

            var list = await _context.events.Where(e => ids.Contains(e.Id)).ToListAsync();
            if (!list.Any()) return Result.Failure(EventErrors.EventBulkNotFound);

            foreach (var e in list)
                e.IsPublished = isPublished;

            await _context.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<bool> IsTitleExistsAsync(string title, int? excludeId = null)
        {
            return await _context.events
                .AnyAsync(e => e.Title == title && (!excludeId.HasValue || e.Id != excludeId.Value));
        }

        public async Task<IEnumerable<Event>> GetAllAsync() => await _context.events.ToListAsync();
        public async Task<Event?> GetByIdAsync(int id) => await _context.events.FindAsync(id);
        public async Task<IEnumerable<Event>> FindAsync(Expression<Func<Event, bool>> predicate)
            => await _context.events.Where(predicate).ToListAsync();
        public async Task<Event?> FirstOrDefaultAsync(Expression<Func<Event, bool>> predicate)
            => await _context.events.FirstOrDefaultAsync(predicate);
        public async Task<bool> AnyAsync(Expression<Func<Event, bool>> predicate)
            => await _context.events.AnyAsync(predicate);
        public async Task<int> CountAsync(Expression<Func<Event, bool>>? predicate = null)
            => predicate == null ? await _context.events.CountAsync() : await _context.events.CountAsync(predicate);
        public async Task<Event> AddAsync(Event entity)
        {
            await _context.events.AddAsync(entity);
            await _context.SaveChangesAsync();
            return entity;
        }
        public async Task AddRangeAsync(IEnumerable<Event> entities)
        {
            await _context.events.AddRangeAsync(entities);
            await _context.SaveChangesAsync();
        }
        public void Update(Event entity) => _context.events.Update(entity);
        public void Delete(Event entity) => _context.events.Remove(entity);
        public async Task<bool> DeleteByIdAsync(int id)
        {
            var entity = await _context.events.FindAsync(id);
            if (entity == null) return false;

            _context.events.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }
        public void DeleteRange(IEnumerable<Event> entities) => _context.events.RemoveRange(entities);
        public async Task<int> SaveChangesAsync() => await _context.SaveChangesAsync();
    }
}
