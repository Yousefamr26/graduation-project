// QuizGenerationJobDto.cs
public class QuizGenerationJobDto
{
    public int Id { get; set; }
    public int RoadmapId { get; set; }
    public int? ResultQuizId { get; set; }
    public string Status { get; set; } // Pending, Processing, Completed, Failed
    public DateTime CreatedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
}