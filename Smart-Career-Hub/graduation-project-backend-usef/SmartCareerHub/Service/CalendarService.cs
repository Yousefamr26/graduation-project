using DataAccess.Contexts;
using Microsoft.EntityFrameworkCore;
using System;

public class CalendarService : ICalendarService
{
    private readonly ApplicationDbContext _context;

    public CalendarService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<CalendarEventDto>> GetCalendarEventsAsync(
        string userId, string role, int month, int year)
    {
        var events = new List<CalendarEventDto>();

        // تحديد بداية ونهاية الشهر
        var startOfMonth = new DateTime(year, month, 1);
        var startOfNextMonth = startOfMonth.AddMonths(1);

        // ==============================
        // Student & Graduate
        // ==============================
        if (role == "Student" || role == "Graduate")
        {
            // Workshops المسجل فيها
            var workshops = await _context.WorkshopEnrollments
                .Include(e => e.Workshop)
                .Where(e => e.UserId == userId &&
                            e.Workshop.WorkshopDate >= startOfMonth &&
                            e.Workshop.WorkshopDate < startOfNextMonth)
                .Select(e => new CalendarEventDto(
                    e.WorkshopId,
                    e.Workshop.Title,
                    e.Workshop.WorkshopDate,
                    "workshop",
                    "blue"))
                .ToListAsync();

            // Events المسجل فيها
            var enrolledEvents = await _context.eventEnrollments
                .Include(e => e.Event)
                .Where(e => e.UserId == userId &&
                            e.Event.StartDate >= startOfMonth &&
                            e.Event.StartDate < startOfNextMonth)
                .Select(e => new CalendarEventDto(
                    e.EventId,
                    e.Event.Title,
                    e.Event.StartDate,
                    "event",
                    "orange"))
                .ToListAsync();

            // Interviews
            var interviews = await _context.interviews
                .Where(i => i.UserId == userId &&
                            i.ScheduledAt >= startOfMonth &&
                            i.ScheduledAt < startOfNextMonth)
                .Select(i => new CalendarEventDto(
                    i.Id,
                    "Interview: " + i.InterviewerName,
                    i.ScheduledAt,
                    "interview",
                    "purple"))
                .ToListAsync();

            // Roadmaps المسجل فيها
            var roadmaps = await _context.userRoadmaps
                .Include(e => e.Roadmap)
                .Where(e => e.UserId == userId &&
                            e.Roadmap.CreatedAt >= startOfMonth &&
                            e.Roadmap.CreatedAt < startOfNextMonth)
                .Select(e => new CalendarEventDto(
                    e.RoadmapId,
                    e.Roadmap.Title,
                    e.Roadmap.CreatedAt,
                    "roadmap",
                    "green"))
                .ToListAsync();

            // Job Applications
            var jobs = await _context.jobApplications
                .Include(j => j.Job)
                .Where(j => j.UserId == userId &&
                            j.AppliedAt >= startOfMonth &&
                            j.AppliedAt < startOfNextMonth)
                .Select(j => new CalendarEventDto(
                    j.JobId,
                    "Applied: " + j.Job.Title,
                    j.AppliedAt,
                    "job",
                    "red"))
                .ToListAsync();

            events.AddRange(workshops);
            events.AddRange(enrolledEvents);
            events.AddRange(interviews);
            events.AddRange(roadmaps);
            events.AddRange(jobs);
        }

        // ==============================
        // Company
        // ==============================
        else if (role == "Company")
        {
            var workshops = await _context.workshopSec1s
                .Where(w => w.CompanyId == userId &&
                            w.WorkshopDate >= startOfMonth &&
                            w.WorkshopDate < startOfNextMonth)
                .Select(w => new CalendarEventDto(
                    w.Id, w.Title, w.WorkshopDate, "workshop", "blue"))
                .ToListAsync();

            var companyEvents = await _context.events
                .Where(e => e.CreatedById == userId &&
                            e.StartDate >= startOfMonth &&
                            e.StartDate < startOfNextMonth)
                .Select(e => new CalendarEventDto(
                    e.Id, e.Title, e.StartDate, "event", "orange"))
                .ToListAsync();

            var interviews = await _context.interviews
                .Where(i => i.Roadmap.CompanyUserId == userId &&
                            i.ScheduledAt >= startOfMonth &&
                            i.ScheduledAt < startOfNextMonth)
                .Select(i => new CalendarEventDto(
                    i.Id,
                    "Interview: " + i.StudentName,
                    i.ScheduledAt,
                    "interview",
                    "purple"))
                .ToListAsync();

            var jobs = await _context.jobs
                .Where(j => j.CompanyUserId == userId &&
                            j.CreatedAt >= startOfMonth &&
                            j.CreatedAt < startOfNextMonth)
                .Select(j => new CalendarEventDto(
                    j.Id, j.Title, j.CreatedAt, "job", "red"))
                .ToListAsync();

            events.AddRange(workshops);
            events.AddRange(companyEvents);
            events.AddRange(interviews);
            events.AddRange(jobs);
        }

        // ==============================
        // University
        // ==============================
        else if (role == "University")
        {
            var workshops = await _context.workshopSec1s
                .Where(w => w.UniversityId.ToString() == userId &&
                            w.WorkshopDate >= startOfMonth &&
                            w.WorkshopDate < startOfNextMonth)
                .Select(w => new CalendarEventDto(
                    w.Id, w.Title, w.WorkshopDate, "workshop", "blue"))
                .ToListAsync();

            var uniEvents = await _context.events
                .Where(e => e.CreatedById == userId &&
                            e.StartDate >= startOfMonth &&
                            e.StartDate < startOfNextMonth)
                .Select(e => new CalendarEventDto(
                    e.Id, e.Title, e.StartDate, "event", "orange"))
                .ToListAsync();

            events.AddRange(workshops);
            events.AddRange(uniEvents);
        }

        // ==============================
        // Training Center
        // ==============================
        else if (role == "TrainingCenter")
        {
            var roadmaps = await _context.RoadmapsSec1
                .Where(r => r.CompanyUserId == userId &&
                            r.CreatedAt >= startOfMonth &&
                            r.CreatedAt < startOfNextMonth)
                .Select(r => new CalendarEventDto(
                    r.Id,
                    r.Title,
                    r.CreatedAt,
                    "roadmap",
                    "green"))
                .ToListAsync();

            events.AddRange(roadmaps);
        }

        return events.OrderBy(e => e.Date);
    }
}