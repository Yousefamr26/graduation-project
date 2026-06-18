public class InternshipApplication
{
    public string Id { get; set; }

    public int InternshipId { get; set; }
    public string UserId { get; set; }   // FK → ApplicationUser.Id

    public DateTime AppliedAt { get; set; } = DateTime.UtcNow;

    public ApplicationStatu Status { get; set; }

    // Navigation
    public virtual Internship Internship { get; set; }
    public virtual ApplicationUser User { get; set; }
}
