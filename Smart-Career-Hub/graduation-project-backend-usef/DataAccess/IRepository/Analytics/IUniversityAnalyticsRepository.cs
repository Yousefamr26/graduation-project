public interface IUniversityAnalyticsRepository
{
    Task<int> GetTotalActivePartnersAsync();
    Task<string> GetMostActiveCampusAsync();
    Task<int> GetNewPartnershipsAsync(int year, int quarter);
}