namespace SmartCareerHub.Contracts.Company.WorkShops
{
    public record  WorkshopRequest(
    
        string Title ,
        string Description ,
         IFormFile? Banner ,
        int UniversityId ,
        string Location ,
        int MaxCapacity ,
        string WorkshopType , 
        bool RequireCV ,
        bool IsPublished,
        bool RequireRoadmapCompletion ,
        List<MaterialRequest>? Materials, 
        List<ActivityRequest>? Activities
    );
}
