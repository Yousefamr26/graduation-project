namespace SmartCareerHub.Contracts.Company.CreateRoadmap
{
    public record LearningMaterialResponse(
    int Id,
    string? TitleVideos,
    string? TitlePdf,
    string? Duration,
    string? Durationpdf,
    string Type,
    string FilePath
);
}
