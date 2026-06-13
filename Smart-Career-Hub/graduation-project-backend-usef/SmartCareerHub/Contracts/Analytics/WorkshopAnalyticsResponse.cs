public record WorkshopAnalyticsResponse(

    int TotalParticipants,
    Dictionary<string, int> ByType
);
