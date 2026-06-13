using Business_Logic.IService;
using DataAccess.Abstractions;
using DataAccess.Entities.RoadMap;
using DataAccess.IRepository;

public class CertificateService : ICertificateService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IWebHostEnvironment _env;

    public CertificateService(IUnitOfWork unitOfWork, IWebHostEnvironment env)
    {
        _unitOfWork = unitOfWork;
        _env = env;
    }

    // ================= REQUEST CERTIFICATE =================
    public async Task<Result<CertificateResponse>> RequestCertificateAsync(
        string userId,
        int roadmapId,
        CancellationToken cancellationToken = default)
    {
        // 1) Get roadmap
        var roadmapResult = await _unitOfWork.Roadmaps.GetByIdWithDetailsAsync(roadmapId);

        if (roadmapResult.IsFailure)
            return Result.Failure<CertificateResponse>(
                new Error("Roadmap.NotFound", "Roadmap not found"));

        var roadmap = roadmapResult.Value;

        // 2) Check enrollment
        var enrollment = await _unitOfWork.userRoadmaps
            .FirstOrDefaultAsync(x => x.UserId == userId && x.RoadmapId == roadmapId);

        if (enrollment == null)
            return Result.Failure<CertificateResponse>(
                new Error("Not.Enrolled", "User not enrolled"));

        if (enrollment.ProgressPercent < 100)
            return Result.Failure<CertificateResponse>(
                new Error("Not.Completed", "Roadmap not completed"));

        // 3) Check exists
        var exists = await _unitOfWork.Certificates
            .ExistsAsync(userId, roadmapId);

        if (exists)
            return Result.Failure<CertificateResponse>(
                new Error("Exists", "Certificate already exists"));

        // 4) Create certificate
        var certificate = new Certificate
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            RoadmapId = roadmapId,
            IssuedById = roadmap.CompanyUserId,
            CertificateCode = Guid.NewGuid().ToString("N")[..10].ToUpper(),
            IssuedAt = DateTime.UtcNow,
            IsValid = true
        };

        await _unitOfWork.Certificates.AddAsync(certificate);
        await _unitOfWork.SaveChangesAsync();

        // 5) Response mapping
        var response = new CertificateResponse(
            CertificateId: certificate.Id,
            CertificateCode: certificate.CertificateCode,
            RoadmapId: roadmapId,
            RoadmapTitle: roadmap.Title,
            IssuedAt: certificate.IssuedAt,
            DownloadUrl: $"/api/certificates/{certificate.Id}/download"
        );

        return Result.Success(response);
    }

    // ================= GET BY ID =================
   

    // ================= GENERATE PDF =================
    public async Task<byte[]> GenerateCertificatePdfAsync(
        Guid certificateId,
        CancellationToken cancellationToken = default)
    {
        var certificate = await _unitOfWork.Certificates
            .GetByIdAsync(certificateId);

        if (certificate == null)
            throw new Exception("Certificate not found");

        var generator = new CertificatePdfGenerator();
        return generator.Generate(certificate);
    }
    public async Task<Certificate?> GetByIdAsync(Guid id)
    {
        return await _unitOfWork.Certificates.GetByIdAsync(id);
    }

    // ================= DOWNLOAD URL =================
    public async Task<string> GetDownloadUrlAsync(
        Guid certificateId,
        CancellationToken cancellationToken = default)
    {
        var pdf = await GenerateCertificatePdfAsync(certificateId, cancellationToken);

        var folder = Path.Combine(_env.WebRootPath, "certificates");

        if (!Directory.Exists(folder))
            Directory.CreateDirectory(folder);

        var fileName = $"certificate_{certificateId}.pdf";
        var path = Path.Combine(folder, fileName);

        await File.WriteAllBytesAsync(path, pdf, cancellationToken);

        return $"/certificates/{fileName}";
    }
}