using DataAccess.Abstractions;

public interface ICertificateService
{
    Task<Result<CertificateResponse>> RequestCertificateAsync(
        string userId,
        int roadmapId,
        CancellationToken cancellationToken = default);

    Task<byte[]> GenerateCertificatePdfAsync(
        Guid certificateId,
        CancellationToken cancellationToken = default);

    Task<string> GetDownloadUrlAsync(
        Guid certificateId,
        CancellationToken cancellationToken = default);

    Task<Certificate?> GetByIdAsync(Guid certificateId);
}