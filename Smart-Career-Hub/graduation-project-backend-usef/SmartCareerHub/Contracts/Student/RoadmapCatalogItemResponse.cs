namespace SmartCareerHub.Contracts.Student.Roadmaps
{
    public record RoadmapCatalogItemResponse(
        int RoadmapId,
        string Title,
        string TargetRole,
        string CompanyName,
        string? CoverImageUrl,

        bool IsEnrolled,
        int ProgressPercent,

        string Level,
        List<string> Skills
,
        bool IsAiPick

    );
}
