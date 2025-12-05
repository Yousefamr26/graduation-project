using SmartCareerHub.Contracts.Company.CreateRoadmap;

public class QuizRequest
{
    public string Title { get; set; } = string.Empty;

    public string Type { get; set; } = string.Empty; 

    public int Points { get; set; }

    public int RoadmapId { get; set; }

    public List<QuestionRequest>? QuestionRequests { get; set; }

    public IFormFile? QuestionsFile { get; set; }
}
