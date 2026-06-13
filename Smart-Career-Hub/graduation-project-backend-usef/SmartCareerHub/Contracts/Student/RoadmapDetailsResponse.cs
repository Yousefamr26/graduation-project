public record RoadmapDetailsResponse(
    int RoadmapId,
    string Title,
    string Description,
    int ProgressPercent,
    List<RoadmapSectionResponse> Sections
);
