using DataAccess.Entities.Users;
using System;
using System.Collections.Generic;

namespace DataAccess.Entities.RoadMap
{
    // ---- تعريف نوع المادة حسب اسماء الجداول الحقيقية ----
    public enum ProgressMaterialType
    {
        LearningMaterial,   // LearningMaterialSec34
        Project,            // ProjectSec5
        Quiz                // QuizzesSec6
    }

    public class UserProgress
    {
        public int Id { get; set; }

        public int UserRoadmapId { get; set; }
        public UserRoadmap UserRoadmap { get; set; }

        public int MaterialId { get; set; }
        public ProgressMaterialType MaterialType { get; set; }

        public bool Completed { get; set; }
        public int PointsEarned { get; set; }
        public DateTime? CompletedAt { get; set; }
    }

}
