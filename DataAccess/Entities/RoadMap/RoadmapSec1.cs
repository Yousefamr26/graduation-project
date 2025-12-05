using DataAccess.Entities.Interview;
using System;
using System.Collections.Generic;

namespace DataAccess.Entities.RoadMap
{
    public class RoadmapSec1
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }

        public string TargetRole { get; set; }

        public string? CoverImageUrl { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }
        public bool IsPublished { get; set; }
        public int TotalPoints { get; set; }
        public int TotalMaterials { get; set; }
        public int TotalProjects { get; set; }
        public int TotalQuizzes { get; set; }

        public virtual ICollection<RequiredSkillSec2> RequiredSkills { get; set; }
        public virtual ICollection<LearningMaterialSec34> LearningMaterials { get; set; }
        public virtual ICollection<ProjectSec5> Projects { get; set; }
        public virtual ICollection<QuizzesSec6> Quizzes { get; set; }
        public virtual ICollection<InterviewSchedule> Interviews { get; set; }

    }
}
