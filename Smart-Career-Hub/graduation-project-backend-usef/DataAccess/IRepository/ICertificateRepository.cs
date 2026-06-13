public interface ICertificateRepository
{
    Task<Certificate?> GetByIdAsync(Guid id);

    Task<Certificate?> GetByUserAndRoadmapAsync(string userId, int roadmapId);

    Task<bool> ExistsAsync(string userId, int roadmapId);

    Task AddAsync(Certificate certificate);
}