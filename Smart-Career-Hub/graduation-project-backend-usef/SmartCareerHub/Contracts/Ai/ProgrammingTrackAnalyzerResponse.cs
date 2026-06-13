public record ProgrammingTrackAnalyzerResponse(
    string Track,
    string Reason,
    string? FollowUpQuestion,
    List<string> Roadmap
);