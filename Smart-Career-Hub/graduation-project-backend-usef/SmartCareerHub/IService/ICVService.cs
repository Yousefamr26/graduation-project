public interface ICVService
{
    // Student/Graduate
    Task<UploadCVResponse> UploadAsync(UploadCVRequest request, string userId);
    Task<IEnumerable<UserCVDto>> GetUserCVsAsync(string userId);
    Task<(byte[] file, string contentType, string fileName)> DownloadAsync(int cvId);
    Task DeleteCVAsync(int cvId, string userId);

    // Company
    Task<UploadTemplateResponse> UploadTemplateAsync(UploadTemplateRequest request, string companyId);
    Task<IEnumerable<CVTemplateDto>> GetCompanyTemplatesAsync(string companyId);
    Task DeleteTemplateAsync(int templateId, string companyId);

    // Shared
    Task<IEnumerable<CVTemplateDto>> GetAllTemplatesAsync();
    Task<(byte[] file, string contentType, string fileName)> DownloadTemplateAsync(int templateId);
}