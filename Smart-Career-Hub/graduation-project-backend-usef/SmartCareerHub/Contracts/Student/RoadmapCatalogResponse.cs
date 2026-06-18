namespace SmartCareerHub.Contracts.Student.Roadmaps
{
    public record RoadmapCatalogResponse(
        string AiMessage,
        List<RoadmapCatalogItemResponse> Roadmaps
    );
}
