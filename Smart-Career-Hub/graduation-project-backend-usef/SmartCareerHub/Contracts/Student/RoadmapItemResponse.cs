public record RoadmapItemResponse(
    int Id,
    string Title,
    string Type,        // Video | Project | Quiz
    bool Completed,
    int PointsEarned,
    string? Url,        // رابط الفيديو أو المشروع أو الملف
    int? Duration       // مدة الفيديو بالثواني (لو نوع Video)
);
