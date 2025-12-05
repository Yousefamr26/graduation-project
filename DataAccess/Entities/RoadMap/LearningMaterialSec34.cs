using DataAccess.Entities.RoadMap;
using System;

public class LearningMaterialSec34
{
    public int Id { get; set; }

    public string? TitleVideos { get; set; }   
    public string? TitlePdf { get; set; }     

    public string? VideoDuration { get; set; } 
    public string? PdfDuration { get; set; } 

    public string MaterialType { get; set; } 
    public string FilePath { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.Now;
    public DateTime? UpdatedAt { get; set; }
    public int Points { get; set; }


    public int RoadmapId { get; set; }
    public virtual RoadmapSec1 Roadmap { get; set; }
}
