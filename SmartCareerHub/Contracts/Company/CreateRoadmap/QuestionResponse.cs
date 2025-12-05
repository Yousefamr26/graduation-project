namespace SmartCareerHub.Contracts.Company.CreateRoadmap
{
    public record QuestionResponse(
     int Id,
     string Text,
     string Type,
     string OptionsJson,
     string CorrectAnswer,
     IEnumerable<QuizAnswerResponse>? Answers 
 );

}
