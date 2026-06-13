public record CertificateResponse(
    Guid CertificateId,
    string CertificateCode,
    int RoadmapId,
    string RoadmapTitle,
    DateTime IssuedAt,
    string DownloadUrl
);