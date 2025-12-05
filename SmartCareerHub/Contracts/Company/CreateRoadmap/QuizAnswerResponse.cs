namespace SmartCareerHub.Contracts.Company.CreateRoadmap
{
    public record QuizAnswerResponse(
     int Id,
     int UserId,
     string? AnswerText,
     string? FileUrl
 );

}
