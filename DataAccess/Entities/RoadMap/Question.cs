using DataAccess.Entities.RoadMap;

public class Question
{
    public int Id { get; set; }
    public int QuizId { get; set; }
    public QuizzesSec6 Quiz { get; set; }
    public string? Text { get; set; }         
    public string? Type { get; set; }           
    public string? OptionsJson { get; set; }   
    public string? CorrectAnswer { get; set; }  
    public virtual ICollection<QuizAnswer> Answers { get; set; } = new List<QuizAnswer>();
}
