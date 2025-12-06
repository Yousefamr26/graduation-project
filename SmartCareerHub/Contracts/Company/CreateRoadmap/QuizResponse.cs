namespace SmartCareerHub.Contracts.Company.CreateRoadmap
{

    public record QuizResponse(
        int Id,
    string Title,
    string Type,
    string? QuestionsFile,
    int Points,
    int RoadmapId,
    IEnumerable<QuestionResponse> Questions // كل الأسئلة المرتبطة
        );

}
