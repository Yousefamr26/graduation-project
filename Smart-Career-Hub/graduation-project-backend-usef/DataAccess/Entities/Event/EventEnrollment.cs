using DataAccess.Entities.Events;
using DataAccess.Entities.Users;

public class EventEnrollment
{
    public string Id { get; set; }

    public int EventId { get; set; }

    // 🔥 نفس أسلوب الـ Roadmap
    public string UserId { get; set; }
    public ApplicationUser User { get; set; }

    public string Email { get; set; }
    public string PhoneNumber { get; set; }
    public string? Motivation { get; set; }

    public DateTime EnrolledAt { get; set; } = DateTime.UtcNow;

    public Event Event { get; set; }
}
