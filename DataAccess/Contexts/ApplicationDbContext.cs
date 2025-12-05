using DataAccess.Entities.Events;
using DataAccess.Entities.Interview;
using DataAccess.Entities.Job;
using DataAccess.Entities.RoadMap;
using DataAccess.Entities.Users;
using DataAccess.Entities.Workshop;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using System.Reflection;

namespace DataAccess.Contexts
{
    public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        public DbSet<CompanyUser> CompanyUser { get; set; }

        public DbSet<RoadmapSec1> RoadmapsSec1 { get; set; }
        public DbSet<RequiredSkillSec2> RequiredSkillsSec2 { get; set; }
        public DbSet<LearningMaterialSec34> LearningMaterialsSec34 { get; set; }
        public DbSet<ProjectSec5> ProjectsSec5 { get; set; }
        public DbSet<QuizzesSec6> QuizzesSec6 { get; set; }
        public DbSet<Question> Questions { get; set; }
        public DbSet<QuizAnswer> QuizAnswers { get; set; }

        public DbSet<WorkshopSec1> workshopSec1s { get; set; }
        public DbSet<WorkshopMaterial> WorkshopMaterials { get; set; }
        public DbSet<WorkshopActivity> WorkshopActivities { get; set; }
        public DbSet<University> Universities { get; set; }

        public DbSet<Event> events { get; set; }

        public DbSet<Job> jobs { get; set; }
        public DbSet<InterviewSchedule> interviews { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());

            modelBuilder.Entity<ApplicationUser>().ToTable("Users");
            modelBuilder.Entity<Microsoft.AspNetCore.Identity.IdentityRole>().ToTable("Roles");
            modelBuilder.Entity<Microsoft.AspNetCore.Identity.IdentityUserRole<string>>().ToTable("UserRoles");
            modelBuilder.Entity<Microsoft.AspNetCore.Identity.IdentityUserClaim<string>>().ToTable("UserClaims");
            modelBuilder.Entity<Microsoft.AspNetCore.Identity.IdentityUserLogin<string>>().ToTable("UserLogins");
            modelBuilder.Entity<Microsoft.AspNetCore.Identity.IdentityRoleClaim<string>>().ToTable("RoleClaims");
            modelBuilder.Entity<Microsoft.AspNetCore.Identity.IdentityUserToken<string>>().ToTable("UserTokens");

            modelBuilder.Entity<CompanyUser>()
                .HasOne(c => c.User)
                .WithOne(u => u.CompanyProfile)
                .HasForeignKey<CompanyUser>(c => c.Id)
                .IsRequired(false)
                .OnDelete(DeleteBehavior.Cascade);



            modelBuilder.Entity<QuizzesSec6>()
                .HasOne(q => q.Roadmap)
                .WithMany(r => r.Quizzes)
                .HasForeignKey(q => q.RoadmapId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Question>()
                .HasOne(q => q.Quiz)
                .WithMany(qz => qz.Questions)
                .HasForeignKey(q => q.QuizId)
                .OnDelete(DeleteBehavior.Cascade);
            modelBuilder.Entity<QuizAnswer>()
                .HasOne(a => a.Question)
                .WithMany(q => q.Answers)
                .HasForeignKey(a => a.QuestionId)
                .OnDelete(DeleteBehavior.Cascade); 

            modelBuilder.Entity<QuizAnswer>()
                .HasOne<QuizzesSec6>()         
                .WithMany()                     
                .HasForeignKey(a => a.QuizId)
                .OnDelete(DeleteBehavior.NoAction); 


        }
    }
}
