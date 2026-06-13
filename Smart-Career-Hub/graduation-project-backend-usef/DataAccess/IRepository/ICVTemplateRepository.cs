public interface ICVTemplateRepository
{
    Task<CVTemplate?> GetByIdAsync(int id);
    Task AddAsync(CVTemplate template);
    Task<IEnumerable<CVTemplate>> GetAllAsync();
    // ✅ جيب تمبليتس شركة معينة
    Task<IEnumerable<CVTemplate>> GetByCompanyIdAsync(string companyId);
    Task DeleteAsync(CVTemplate template);
}