using DataAccess.Entities.RoadMap;

public class Enrollment
{
    public int Id { get; set; } // <-- مفتاح أساسي
    public string UserId { get; set; }
    public double Progress { get; set; } // 0 - 100

    public int RoadmapId { get; set; } // Foreign Key
    public RoadmapSec1 Roadmap { get; set; }
}