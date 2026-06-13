using DataAccess.Entities.RoadMap;

namespace SmartCareerHub.Contracts.Company.CreateRoadmap
{
    public record ProjectRequest(
        string Title,
        string Description,
        string Difficulty,
        int Points
    );

}
