public record EventAnalyticsResponse(

    int TotalParticipants,
    Dictionary<string, int> ByMode
);
