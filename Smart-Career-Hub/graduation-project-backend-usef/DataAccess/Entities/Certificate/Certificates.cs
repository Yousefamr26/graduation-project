using DataAccess.Entities.RoadMap;

public class Certificate
{
    public Guid Id { get; set; }

    // الطالب
    public string UserId { get; set; }
    public ApplicationUser User { get; set; }

    // الرودماب
    public int RoadmapId { get; set; }
    public RoadmapSec1 Roadmap { get; set; }

    // مين أصدرها
    public string IssuedById { get; set; }
    public CompanyUser IssuedBy { get; set; }

    public DateTime IssuedAt { get; set; } = DateTime.UtcNow;

    // 🔥 مهم
    public string CertificateCode { get; set; } // للتحقق

    public string? PdfUrl { get; set; }

    public bool IsValid { get; set; } = true;
}