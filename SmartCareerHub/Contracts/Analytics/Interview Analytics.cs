public record InterviewAnalyticsResponse(

    int CompletedCount,
    int ScheduledCount,
    Dictionary<string, int> CompletionRateOverTime
);
