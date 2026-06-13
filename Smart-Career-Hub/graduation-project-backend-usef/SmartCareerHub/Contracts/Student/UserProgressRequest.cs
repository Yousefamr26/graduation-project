using System;
using DataAccess.Entities.RoadMap;

namespace Business_Logic.DTOs.StudentProgress
{
    public record UserProgressRequest(
        
        int MaterialId,
        ProgressMaterialType MaterialType,
        int? PointsEarned = null,
        bool? Completed = null
    );
}
