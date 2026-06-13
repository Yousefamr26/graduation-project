namespace SmartCareerHub.Contracts.Events.Enrollment
{
    public record EventEnrollmentRequest(
        int EventId,
        string Email,
        string PhoneNumber,
        string? Motivation
    );
}
