namespace SmartCareerHub.Contracts.Events
{
    public record MyEventResponse(
        int EventId,
        string Title,
        string Description,
        string mode,
        DateTime EventDate,
        DateTime EnrolledAt
    );
}
