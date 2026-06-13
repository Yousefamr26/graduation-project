public interface IInternshipAnalyticsRepository
{
    Task<int> GetActiveProgramsAsync();
    Task<int> GetTotalApplicantsAsync();
    Task<double> GetAcceptanceRateAsync();
    Task<Dictionary<string, int>> GetByDepartmentAsync();
}