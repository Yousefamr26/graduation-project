public record ActivityDto(
    string ActivityId,
    string Title,
    string Type, // Workshop / Training / Event
    string CompanyName,
    DateTime RegisteredAt
);