public class EventEnrollment
{
    public int Id { get; set; }
    public int EventId { get; set; }
    public Guid StudentId { get; set; }
    public string Email { get; set; }
    public string PhoneNumber { get; set; }
    public string? Motivation { get; set; }
    public DateTime EnrolledAt { get; set; }

    // Add this navigation property to fix CS1061
    public virtual Event Event { get; set; }
}