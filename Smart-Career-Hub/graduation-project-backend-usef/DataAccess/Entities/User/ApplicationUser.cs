using DataAccess.Entities.Job;
using DataAccess.Entities.User;
using DataAccess.Entities.Users;
using Microsoft.AspNetCore.Identity;
using SmartCareerHub.Entities;
using System;

public class ApplicationUser : IdentityUser
{
    public string FirstName { get; set; }
    public string LastName { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }

    public bool IsActive { get; set; } = true;
    public bool IsEmailVerified { get; set; } = false;

    public string UserType { get; set; }
    public string Country { get; set; }
    public string City { get; set; }

    public CompanyUser CompanyProfile { get; set; }
    public virtual Student StudentProfile { get; set; }
    public virtual Graduates GraduateProfile { get; set; }
    public virtual University UniversityProfile { get; set; }   // ✅ أضفنا دي
    public virtual TrainingCenter TrainingCenterProfile { get; set; }   // ✅ أضفنا دي

    public ICollection<UserRoadmap> UserRoadmaps { get; set; }
       = new HashSet<UserRoadmap>();

    public ICollection<UserCV> CVs { get; set; } = new HashSet<UserCV>();
    public ICollection<JobApplication> JobApplications { get; set; } = new HashSet<JobApplication>();
    public ICollection<InternshipApplication> InternshipApplications { get; set; } = new List<InternshipApplication>();
    public virtual ICollection<Payment> Payments { get; set; } = new List<Payment>();

    // للشركة - optional
    public ICollection<CVTemplate> UploadedTemplates { get; set; } = new List<CVTemplate>();
    public ICollection<Certificate> Certificates { get; set; }
    = new List<Certificate>();

    public ICollection<CertificateRequest> CertificateRequests { get; set; }
        = new List<CertificateRequest>();
}




