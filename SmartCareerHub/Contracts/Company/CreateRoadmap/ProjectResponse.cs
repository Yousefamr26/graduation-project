namespace SmartCareerHub.Contracts.Company.CreateRoadmap
{
    public record ProjectResponse(
     int Id,
     string Title,
     string Description,
     string Difficulty,
     int Points
 );
}
