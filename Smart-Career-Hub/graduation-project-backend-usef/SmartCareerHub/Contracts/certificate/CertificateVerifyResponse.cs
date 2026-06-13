public record CertificateVerifyResponse(
    bool IsValid,
    string StudentName,
    string RoadmapTitle,
    string CertificateCode,
    DateTime IssuedAt,
    string IssuedBy
);