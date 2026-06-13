public record ChatRoomDto(
    int Id,
    string ApplicantId,
    string ApplicantName,
    string EntityId,
    string EntityName,
    DateTime CreatedAt,
    string LastMessage,
    DateTime? LastMessageAt,
    int UnreadCount
);