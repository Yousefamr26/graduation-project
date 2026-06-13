public record EventParticipantResponse(
    string UserId,
    string Email,
    string PhoneNumber,
    string Motivation,
    DateTime EnrolledAt
);