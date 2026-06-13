using DataAccess.Entities.RoadMap;

public class CertificateRequest
{
    public int Id { get; set; }

    public string UserId { get; set; }
    public ApplicationUser User { get; set; }

    public int RoadmapId { get; set; }
    public RoadmapSec1 Roadmap { get; set; }

    public DateTime RequestedAt { get; set; } = DateTime.UtcNow;
}