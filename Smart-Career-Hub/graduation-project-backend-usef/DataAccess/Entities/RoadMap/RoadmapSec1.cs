using DataAccess.Entities.Interview;
using DataAccess.Entities.User;
using DataAccess.Entities.Users;
using SmartCareerHub.Entities;
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
        public decimal Price { get; set; } = 0;

        // ---- علاقة بالـ CompanyUser ----
        public string? CompanyUserId { get; set; }   // FK → CompanyUser
        public virtual CompanyUser Company { get; set; }
        public int? TrainingCenterId { get; set; }

        public virtual TrainingCenter? TrainingCenter { get; set; }

        // ---- Collections ----
        public virtual ICollection<RequiredSkillSec2> RequiredSkills { get; set; } = new List<RequiredSkillSec2>();
        public virtual ICollection<LearningMaterialSec34> LearningMaterials { get; set; } = new List<LearningMaterialSec34>();
        public virtual ICollection<ProjectSec5> Projects { get; set; } = new List<ProjectSec5>();
        public virtual ICollection<QuizzesSec6> Quizzes { get; set; } = new List<QuizzesSec6>();
        public virtual ICollection<InterviewSchedule> Interviews { get; set; } = new List<InterviewSchedule>();
        public ICollection<Enrollment> Enrollments { get; set; } = new List<Enrollment>();
        public virtual ICollection<Payment> Payments { get; set; } = new List<Payment>();
        public ICollection<Certificate> Certificates { get; set; }
    = new List<Certificate>();

        public ICollection<CertificateRequest> CertificateRequests { get; set; }
            = new List<CertificateRequest>();

    }
}
