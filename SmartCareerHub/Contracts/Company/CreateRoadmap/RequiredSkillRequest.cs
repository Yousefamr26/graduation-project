using DataAccess.Entities.RoadMap;

namespace SmartCareerHub.Contracts.Company.CreateRoadmap
{
    public record RequiredSkillRequest(
        string SkillName,
        string Level,
        int LevelPoints
    );

}
