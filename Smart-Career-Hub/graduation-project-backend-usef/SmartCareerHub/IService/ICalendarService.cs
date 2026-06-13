public interface ICalendarService
{
    Task<IEnumerable<CalendarEventDto>> GetCalendarEventsAsync(
        string userId, string role, int month, int year);
}