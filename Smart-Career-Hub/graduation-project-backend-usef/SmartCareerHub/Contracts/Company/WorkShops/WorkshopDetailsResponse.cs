using System;

namespace SmartCareerHub.Contracts.Workshops.Enrollment
{
    public record WorkshopDetailsResponse(
        int WorkshopId,
        string Title,
        string Description,
        string? BannerUrl,
        string Location,
        string WorkshopType,
        int MaxCapacity,
        int CurrentEnrollments,
        bool RequireCV,
        bool RequireRoadmapCompletion,
        bool IsPublished,
        int TotalPoints,
        bool IsUserEnrolled = false,       // حالة المستخدم الحالي
        bool CvUploaded = false,
        bool RoadmapCompleted = false
    );
}