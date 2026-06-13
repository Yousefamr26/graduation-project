using DataAccess.Entities.RoadMap;

public class QuizzesSec6
{
    public int Id { get; set; }
    public string? Title { get; set; }
    public string? Type { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.Now;
    public string? QuestionsFile { get; set; }
    public int Points { get; set; }

    // --- التعديل هنا ---
    // بنخلي القيمة الافتراضية "Manual" عشان أي كويز تعمله بإيدك يتسجل كدة أوتوماتيك
    public string CreationSource { get; set; } = "Manual";
    // ------------------

    public int RoadmapId { get; set; }
    public virtual RoadmapSec1 Roadmap { get; set; }
    public ICollection<Question> Questions { get; set; } = new List<Question>();
    public virtual ICollection<QuizAttempt> Attempts { get; set; } = new List<QuizAttempt>();
}