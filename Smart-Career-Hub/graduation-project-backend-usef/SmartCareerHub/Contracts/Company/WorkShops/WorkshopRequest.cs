using SmartCareerHub.Contracts.Company.WorkShops;

public record WorkshopRequest(
    string Title,
    string Description,
    IFormFile? Banner,
    string? HostType,         
    int? UniversityId,
    string? CompanyId,
    string Location,
    int MaxCapacity,
    string WorkshopType,
    bool RequireCV = false,
    bool RequireRoadmapCompletion = false,
    bool IsPublished = false,
    List<MaterialRequest>? Materials = null,
    List<ActivityRequest>? Activities = null
);