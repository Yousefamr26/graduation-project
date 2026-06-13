using DataAccess.Entities;
using DataAccess.Entities.Events;
using DataAccess.Entities.Interview;
using DataAccess.Entities.Job;
using DataAccess.Entities.Partnership;
using DataAccess.Entities.RoadMap;
using DataAccess.Entities.User;
using DataAccess.Entities.Users;
using DataAccess.Entities.Workshop;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using SmartCareerHub.Entities;
using System.Reflection;

namespace DataAccess.Contexts
{
    public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        // ==================== DbSets ====================
        public DbSet<CompanyUser> CompanyUsers { get; set; }
        public DbSet<Student> StudentUsers { get; set; }
        public DbSet<UserProgress> studentProgresses { get; set; }
        public DbSet<Graduates> Graduate { get; set; }

        public DbSet<UserRoadmap> userRoadmaps { get; set; }
        public DbSet<UserProgress> userProgresses { get; set; }
        public DbSet<RoadmapSec1> RoadmapsSec1 { get; set; }
        public DbSet<RequiredSkillSec2> RequiredSkillsSec2 { get; set; }
        public DbSet<LearningMaterialSec34> LearningMaterialsSec34 { get; set; }
        public DbSet<ProjectSec5> ProjectsSec5 { get; set; }
        public DbSet<Enrollment> enrollments { get; set; }

        public DbSet<QuizzesSec6> QuizzesSec6 { get; set; }
        public DbSet<QuizGenerationJob> QuizGenerationJobs { get; set; } // ✅ جديد

        public DbSet<Question> Questions { get; set; }
        public DbSet<QuizAnswer> QuizAnswers { get; set; }
        public DbSet<QuizAttempt> QuizAttempts { get; set; }

        public DbSet<WorkshopSec1> workshopSec1s { get; set; }
        public DbSet<WorkshopMaterial> WorkshopMaterials { get; set; }
        public DbSet<WorkshopActivity> WorkshopActivities { get; set; }
        public DbSet<WorkshopEnrollment> WorkshopEnrollments { get; set; }
        public DbSet<University> Universities { get; set; }
        public DbSet<TrainingCenter> TrainingCenters { get; set; }

        public DbSet<Event> events { get; set; }
        public DbSet<EventEnrollment> eventEnrollments { get; set; }
        public DbSet<Job> jobs { get; set; }
        public DbSet<JobApplication> jobApplications { get; set; }
        public DbSet<InterviewSchedule> interviews { get; set; }
        public DbSet<Internship> internships { get; set; }
        public DbSet<InternshipApplication> internshipApplications { get; set; }
        public DbSet<InternshipRequiredSkill> internshipRequiredSkills { get; set; }
        public DbSet<InternshipRequirement> internshipRequirements { get; set; }
        public DbSet<Partnership> Partnership { get; set; }
        public DbSet<PartnershipEvent> partnershipEvent { get; set; }

        public DbSet<UserCV> UserCVs { get; set; }
        public DbSet<CVTemplate> CVTemplates { get; set; }

        public DbSet<UserRoadmapItemProgress> studentRoadmapItemProgresses { get; set; }
        public DbSet<Payment> payments { get; set; }
        public DbSet<PasswordResetOtp> PasswordResetOtps { get; set; }
        public DbSet<ChatRoom> ChatRooms { get; set; }
        public DbSet<Message> Messages { get; set; }
        public DbSet<Certificate> Certificates { get; set; }
        public DbSet<CertificateRequest> CertificateRequests { get; set; }
        // ==================== OnModelCreating ====================
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());

            // ==================== Identity Tables ====================
            modelBuilder.Entity<ApplicationUser>().ToTable("Users");
            modelBuilder.Entity<Microsoft.AspNetCore.Identity.IdentityRole>().ToTable("Roles");
            modelBuilder.Entity<Microsoft.AspNetCore.Identity.IdentityUserRole<string>>().ToTable("UserRoles");
            modelBuilder.Entity<Microsoft.AspNetCore.Identity.IdentityUserClaim<string>>().ToTable("UserClaims");
            modelBuilder.Entity<Microsoft.AspNetCore.Identity.IdentityUserLogin<string>>().ToTable("UserLogins");
            modelBuilder.Entity<Microsoft.AspNetCore.Identity.IdentityRoleClaim<string>>().ToTable("RoleClaims");
            modelBuilder.Entity<Microsoft.AspNetCore.Identity.IdentityUserToken<string>>().ToTable("UserTokens");

            // ==================== CompanyUser ====================
            modelBuilder.Entity<CompanyUser>()
                .HasOne(c => c.User)
                .WithOne(u => u.CompanyProfile)
                .HasForeignKey<CompanyUser>(c => c.Id)
                .IsRequired(false)
                .OnDelete(DeleteBehavior.Cascade);

            // ==================== Roadmap & Quiz ====================
            modelBuilder.Entity<QuizzesSec6>()
                .ToTable("Quizzes")
                .HasOne(q => q.Roadmap)
                .WithMany(r => r.Quizzes)
                .HasForeignKey(q => q.RoadmapId)
                .OnDelete(DeleteBehavior.Cascade);

            // ==================== Quiz & Question ====================
            modelBuilder.Entity<Question>()
                .HasOne(q => q.Quiz)
                .WithMany(qz => qz.Questions)
                .HasForeignKey(q => q.QuizId)
                .OnDelete(DeleteBehavior.Cascade);

            // ==================== Question & Answer ====================
            modelBuilder.Entity<QuizAnswer>()
                .HasOne(a => a.Question)
                .WithMany(q => q.Answers)
                .HasForeignKey(a => a.QuestionId)
                .OnDelete(DeleteBehavior.Cascade);

            // ==================== Quiz & Answer ====================
            modelBuilder.Entity<QuizGenerationJob>(entity =>
            {
                entity.ToTable("QuizGenerationJobs");
                entity.HasKey(q => q.Id);

                entity.Property(q => q.Status)
                      .HasMaxLength(20)
                      .IsRequired();

                entity.Property(q => q.QuizType)
                      .HasMaxLength(50)
                      .IsRequired();

                entity.HasOne<QuizzesSec6>()
                      .WithMany()
                      .HasForeignKey(q => q.ResultQuizId)
                      .OnDelete(DeleteBehavior.SetNull);
            });


            // ✅ ==================== Internship Configuration ====================
            modelBuilder.Entity<Internship>(entity =>
            {
                entity.HasKey(i => i.Id);

                // ✅ علاقة الـ Required Skills
                entity.HasMany(i => i.RequiredSkills)
                      .WithOne()
                      .HasForeignKey(s => s.InternshipId)
                      .OnDelete(DeleteBehavior.Cascade);

                // ✅ علاقة الـ Requirements
                entity.HasMany(i => i.Requirements)
                      .WithOne()
                      .HasForeignKey(r => r.InternshipId)
                      .OnDelete(DeleteBehavior.Cascade);
            });

            // ✅ ==================== InternshipRequiredSkill Configuration ====================
            modelBuilder.Entity<InternshipRequiredSkill>(entity =>
            {
                entity.HasKey(s => s.Id);
                entity.Property(s => s.Skill).IsRequired().HasMaxLength(100);
            });
            modelBuilder.Entity<Certificate>(entity =>
            {
                entity.ToTable("Certificates");

                entity.HasKey(x => x.Id);

                // ===== User =====
                entity.HasOne(x => x.User)
                      .WithMany(u => u.Certificates)
                      .HasForeignKey(x => x.UserId)
                      .OnDelete(DeleteBehavior.Restrict);

                // ===== Roadmap =====
                entity.HasOne(x => x.Roadmap)
                      .WithMany(r => r.Certificates)
                      .HasForeignKey(x => x.RoadmapId)
                      .OnDelete(DeleteBehavior.Cascade);

                // ===== Issuer (Company / Training Center) =====
                entity.HasOne(x => x.IssuedBy)
                      .WithMany(c => c.IssuedCertificates)
                      .HasForeignKey(x => x.IssuedById)
                      .OnDelete(DeleteBehavior.Restrict);

                // ===== Properties =====
                entity.Property(x => x.CertificateCode)
                      .HasMaxLength(100)
                      .IsRequired();

                entity.Property(x => x.PdfUrl)
                      .HasMaxLength(500);

                entity.Property(x => x.IssuedAt)
                      .HasDefaultValueSql("GETUTCDATE()");

                entity.Property(x => x.IsValid)
                      .HasDefaultValue(true);

                // ===== Indexes =====
                entity.HasIndex(x => x.CertificateCode)
                      .IsUnique();

                entity.HasIndex(x => new { x.UserId, x.RoadmapId })
                      .IsUnique();
            });
            modelBuilder.Entity<CertificateRequest>(entity =>
            {
                entity.ToTable("CertificateRequests");

                entity.HasKey(x => x.Id);

                // ===== User =====
                entity.HasOne(x => x.User)
                      .WithMany(u => u.CertificateRequests)
                      .HasForeignKey(x => x.UserId)
                      .OnDelete(DeleteBehavior.Restrict);

                // ===== Roadmap =====
                entity.HasOne(x => x.Roadmap)
                      .WithMany(r => r.CertificateRequests)
                      .HasForeignKey(x => x.RoadmapId)
                      .OnDelete(DeleteBehavior.Cascade);

                entity.Property(x => x.RequestedAt)
                      .HasDefaultValueSql("GETUTCDATE()");

                entity.HasIndex(x => new { x.UserId, x.RoadmapId })
                      .IsUnique();
            });

            // ✅ ==================== InternshipRequirement Configuration ====================
            modelBuilder.Entity<InternshipRequirement>(entity =>
            {
                entity.HasKey(r => r.Id);
                entity.Property(r => r.Requirement).IsRequired().HasMaxLength(500);
            });
            modelBuilder.Entity<PasswordResetOtp>()
    .HasOne(o => o.User)
    .WithMany()
    .HasForeignKey(o => o.UserId)
    .OnDelete(DeleteBehavior.Cascade);
        }
    }
}