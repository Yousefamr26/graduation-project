public record MessageDto(
    int Id,
    string Content,
    DateTime SentAt,
    bool IsRead,
    string SenderId,
    string SenderName
);