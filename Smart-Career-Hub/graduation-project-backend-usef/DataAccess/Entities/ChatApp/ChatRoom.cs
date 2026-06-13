public class ChatRoom
{
    public int Id { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // الطالب أو الخريج اللي بدأ المحادثة
    public string ApplicantId { get; set; }
    public ApplicationUser Applicant { get; set; }

    // الشركة أو الجهة اللي بيتكلم معاها
    public string EntityId { get; set; }
    public ApplicationUser Entity { get; set; }

    public ICollection<Message> Messages { get; set; }
        = new List<Message>();
}