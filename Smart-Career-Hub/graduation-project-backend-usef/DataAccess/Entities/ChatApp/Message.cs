public class Message
{
    public int Id { get; set; }
    public string Content { get; set; }
    public DateTime SentAt { get; set; } = DateTime.UtcNow;
    public bool IsRead { get; set; } = false;

    // مين بعت
    public string SenderId { get; set; }
    public ApplicationUser Sender { get; set; }

    // في أنهي محادثة
    public int ChatRoomId { get; set; }
    public ChatRoom ChatRoom { get; set; }
}