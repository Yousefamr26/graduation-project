using DataAccess.IRepository;

public class CVService : ICVService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IWebHostEnvironment _env;

    public CVService(IUnitOfWork unitOfWork, IWebHostEnvironment env)
    {
        _unitOfWork = unitOfWork;
        _env = env;
    }

    // ✅ Student/Graduate - رفع CV
    public async Task<UploadCVResponse> UploadAsync(
        UploadCVRequest request,
        string userId)
    {
        var file = request.CV;
        var fileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
        var folderPath = Path.Combine(_env.WebRootPath, "cvs");
        Directory.CreateDirectory(folderPath);
        var fullPath = Path.Combine(folderPath, fileName);

        using var stream = new FileStream(fullPath, FileMode.Create);
        await file.CopyToAsync(stream);

        var cv = new UserCV
        {
            FileName = file.FileName,
            FilePath = fullPath,
            ContentType = file.ContentType!,
            UserId = userId,
            UploadedAt = DateTime.UtcNow
        };

        await _unitOfWork.userCVRepository.AddAsync(cv);
        await _unitOfWork.SaveChangesAsync();

        return new UploadCVResponse(cv.Id, "CV uploaded successfully");
    }

    // ✅ Student/Graduate - جيب كل CVs بتاعته
    public async Task<IEnumerable<UserCVDto>> GetUserCVsAsync(string userId)
    {
        var cvs = await _unitOfWork.userCVRepository.GetByUserIdAsync(userId);
        return cvs.Select(cv => new UserCVDto(
            cv.Id,
            cv.FileName,
            cv.UploadedAt,
            cv.CVTemplate != null ? cv.CVTemplate.Title : null
        ));
    }

    // ✅ Student/Graduate - تحميل CV بتاعه
    public async Task<(byte[] file, string contentType, string fileName)>
        DownloadAsync(int cvId)
    {
        var cv = await _unitOfWork.userCVRepository.GetByIdAsync(cvId)
            ?? throw new Exception("CV not found");

        var bytes = await File.ReadAllBytesAsync(cv.FilePath);
        return (bytes, cv.ContentType, cv.FileName);
    }

    // ✅ Student/Graduate - مسح CV
    public async Task DeleteCVAsync(int cvId, string userId)
    {
        var cv = await _unitOfWork.userCVRepository.GetByIdAsync(cvId)
            ?? throw new Exception("CV not found");

        if (cv.UserId != userId)
            throw new UnauthorizedAccessException("You can't delete this CV");

        // امسح الفايل من السيرفر
        if (File.Exists(cv.FilePath))
            File.Delete(cv.FilePath);

        await _unitOfWork.userCVRepository.DeleteAsync(cv);
        await _unitOfWork.SaveChangesAsync();
    }

    // ✅ Company - رفع Template
    public async Task<UploadTemplateResponse> UploadTemplateAsync(
        UploadTemplateRequest request,
        string companyId)
    {
        var file = request.TemplateFile;
        var fileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
        var folderPath = Path.Combine(_env.WebRootPath, "cv-templates");
        Directory.CreateDirectory(folderPath);
        var fullPath = Path.Combine(folderPath, fileName);

        using var stream = new FileStream(fullPath, FileMode.Create);
        await file.CopyToAsync(stream);

        var template = new CVTemplate
        {
            Title = request.Title,
            Description = request.Description,
         
            FileName = file.FileName,
            FilePath = fullPath,
            ContentType = file.ContentType!,
            CompanyId = companyId,
            UploadedAt = DateTime.UtcNow
        };

        await _unitOfWork.cvTemplateRepository.AddAsync(template);
        await _unitOfWork.SaveChangesAsync();

        return new UploadTemplateResponse(
            template.Id,
            template.Title,
            "Template uploaded successfully"
        );
    }

    // ✅ Company - جيب تمبليتس الشركة
    public async Task<IEnumerable<CVTemplateDto>> GetCompanyTemplatesAsync(string companyId)
    {
        var templates = await _unitOfWork.cvTemplateRepository
            .GetByCompanyIdAsync(companyId);

        return templates.Select(t => new CVTemplateDto(
            t.Id,
            t.Title,
            t.Description,
           
            t.UploadedAt,
            t.Company?.UserName ?? "Unknown"
        ));
    }

    // ✅ Company - مسح تمبليت
    public async Task DeleteTemplateAsync(int templateId, string companyId)
    {
        var template = await _unitOfWork.cvTemplateRepository.GetByIdAsync(templateId)
            ?? throw new Exception("Template not found");

        if (template.CompanyId != companyId)
            throw new UnauthorizedAccessException("You can't delete this template");

        if (File.Exists(template.FilePath))
            File.Delete(template.FilePath);

        await _unitOfWork.cvTemplateRepository.DeleteAsync(template);
        await _unitOfWork.SaveChangesAsync();
    }

    // ✅ Shared - جيب كل التمبليتس
    public async Task<IEnumerable<CVTemplateDto>> GetAllTemplatesAsync()
    {
        var templates = await _unitOfWork.cvTemplateRepository.GetAllAsync();
        return templates.Select(t => new CVTemplateDto(
            t.Id,
            t.Title,
            t.Description,
          
            t.UploadedAt,
            t.Company?.UserName ?? "Unknown"
        ));
    }

    // ✅ Shared - تحميل تمبليت
    public async Task<(byte[] file, string contentType, string fileName)>
        DownloadTemplateAsync(int templateId)
    {
        var template = await _unitOfWork.cvTemplateRepository.GetByIdAsync(templateId)
            ?? throw new Exception("Template not found");

        var bytes = await File.ReadAllBytesAsync(template.FilePath);
        return (bytes, template.ContentType, template.FileName);
    }
}