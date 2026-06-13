public record CalendarEventDto(
    int Id,
    string Title,
    DateTime Date,
    string Type,   // "workshop","event","interview","roadmap","job","internship"
    string Color   // "blue","orange","purple","green","red"
);