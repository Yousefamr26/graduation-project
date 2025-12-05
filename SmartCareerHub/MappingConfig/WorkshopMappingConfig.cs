using DataAccess.Entities.Workshop;
using Mapster;
using SmartCareerHub.Contracts.Company.WorkShops;
using System.Collections.Generic;
using System.Linq;

public static class WorkshopMappingConfig
{
    public static void RegisterMappings()
    {
        
        TypeAdapterConfig<WorkshopSec1, WorkshopResponse>
            .NewConfig()
            .Map(dest => dest.Id, src => src.Id)
            .Map(dest => dest.Title, src => src.Title)
            .Map(dest => dest.Description, src => src.Description)
            .Map(dest => dest.BannerUrl, src => src.BannerUrl)
            .Map(dest => dest.UniversityId, src => src.UniversityId)
            .Map(dest => dest.UniversityName, src => src.University != null ? src.University.Name : "")
            .Map(dest => dest.Location, src => src.Location)
            .Map(dest => dest.MaxCapacity, src => src.MaxCapacity)
            .Map(dest => dest.WorkshopType, src => src.WorkshopType)
            .Map(dest => dest.RequireCV, src => src.RequireCV)
            .Map(dest => dest.RequireRoadmapCompletion, src => src.RequireRoadmapCompletion)
            .Map(dest => dest.IsPublished, src => src.IsPublished)
            .Map(dest => dest.TotalPoints, src =>
                (src.Materials != null ? src.Materials.Sum(m => m.Points) : 0) +
                (src.Activities != null ? src.Activities.Sum(a => a.Points) : 0))
            .Map(dest => dest.Materials,
                src => src.Materials != null ? src.Materials.Adapt<List<MaterialResponse>>() : new List<MaterialResponse>())
            .Map(dest => dest.Activities,
                src => src.Activities != null ? src.Activities.Adapt<List<ActivityResponse>>() : new List<ActivityResponse>())
            .Map(dest => dest.CreatedAt, src => src.CreatedAt)
            .Map(dest => dest.UpdatedAt, src => src.UpdatedAt);

       
        TypeAdapterConfig<WorkshopRequest, WorkshopSec1>
            .NewConfig()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.BannerUrl)
            .Ignore(dest => dest.TotalPoints)
            .Ignore(dest => dest.TotalMaterials)
            .Ignore(dest => dest.University)
            .Ignore(dest => dest.Materials)
            .Ignore(dest => dest.Activities)
            .Ignore(dest => dest.CreatedAt)
            .Ignore(dest => dest.UpdatedAt);

       
        TypeAdapterConfig<MaterialRequest, WorkshopMaterial>
            .NewConfig()
            .Map(dest => dest.Type, src => src.Type)
            .Map(dest => dest.Duration, src => src.Duration)
            .Map(dest => dest.PageCount, src => src.PageCount)
            .Map(dest => dest.Points, src => src.Points)
            .Map(dest => dest.Title, src => ResolveMaterialTitle(src))   
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.WorkshopId)
            .Ignore(dest => dest.FileUrl)
            .Ignore(dest => dest.Workshop)
            .Ignore(dest => dest.CreatedAt);
    }

   
    private static string ResolveMaterialTitle(MaterialRequest src)
    {
        return src.Type switch
        {
            "Video" => string.IsNullOrWhiteSpace(src.TitleVideo)
                ? "Untitled Video"
                : src.TitleVideo,

            "PDF" => string.IsNullOrWhiteSpace(src.TitlePdf)
                ? "Untitled PDF"
                : src.TitlePdf,

            "Assignment" => string.IsNullOrWhiteSpace(src.TitleAssignment)
                ? "Untitled Assignment"
                : src.TitleAssignment,

            _ => "Untitled Material"
        };
    }
}
