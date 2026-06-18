public class StudentRoadmap
{
    public int Id { get; set; }
    public int StudentId { get; set; }
    public virtual Student Student { get; set; }
    public int RoadmapId { get; set; }
    public virtual RoadmapSec1 Roadmap { get; set; }
    public int ProgressPercent { get; set; }
    public string Status { get; set; }
    public DateTime JoinedAt { get; set; } // Add this property to match usage in RoadmapService
    public DateTime? UpdatedAt { get; set; }
    public virtual ICollection<StudentProgress> ProgressItems { get; set; }
}