using DataAccess.Entities.RoadMap;

namespace SmartCareerHub.Contracts.Company.CreateRoadmap
{
    public class LearningMaterialRequest
    {
        public string? TitleVideos { get; set; }
        public string? TitlePdf { get; set; }
        public string? Duration { get; set; }
        public string? Durationpdf { get; set; }
        public string Type { get; set; }
        public int Points { get; set; }

        public IFormFile FilePath { get; set; }
    }
}
