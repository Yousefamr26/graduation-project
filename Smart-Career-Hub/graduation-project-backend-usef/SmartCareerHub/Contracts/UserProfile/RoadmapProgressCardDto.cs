public record RoadmapProgressCardDto(
      int RoadmapId,
      string Title,
      string Description,
      string TargetRole,
      string CompanyName,
      string? CoverImageUrl,
      int ProgressPercent,
      string Status,
      int EarnedPoints,
      int TotalPoints,
      DateTime EnrolledAt,
      DateTime? CompletedAt,
      ProgressBreakdownDto Breakdown
  );