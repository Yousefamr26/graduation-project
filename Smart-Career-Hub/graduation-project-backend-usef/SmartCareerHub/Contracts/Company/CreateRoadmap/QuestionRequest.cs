namespace SmartCareerHub.Contracts.Company.CreateRoadmap
{
    public record QuestionRequest(
     string Text,
     string Type,
     string OptionsJson, 
     string CorrectAnswer
 );

}
