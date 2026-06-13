using DataAccess.Entities.User;
using DataAccess.Entities.Users;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.Configuration
{
    public class ApplicationUserConfiguration : IEntityTypeConfiguration<ApplicationUser>
    {
        public void Configure(EntityTypeBuilder<ApplicationUser> builder)
        {
            builder.Property(u => u.FirstName)
                .IsRequired()
                .HasMaxLength(100);
            builder.Property(u => u.LastName)
                .IsRequired()
                .HasMaxLength(100);
            builder.Property(u => u.UserType)
                .IsRequired()
                .HasMaxLength(50);
            builder.Property(u => u.Country)
                .IsRequired()
                .HasMaxLength(100);
            builder.Property(u => u.City)
                .IsRequired()
                .HasMaxLength(100);
            builder.Property(u => u.CreatedAt)
                .IsRequired();
            builder.Property(u => u.IsActive)
                .HasDefaultValue(true);
            builder.Property(u => u.IsEmailVerified)
                .HasDefaultValue(false);

            // Indexes
            builder.HasIndex(u => u.Email)
                .IsUnique();
            builder.HasIndex(u => u.UserType);
            builder.HasIndex(u => new { u.Country, u.City });

            // ---- علاقات One-to-One ----
            builder.HasOne(u => u.StudentProfile)
                   .WithOne(s => s.User)
                   .HasForeignKey<Student>(s => s.UserId)
                   .OnDelete(DeleteBehavior.Cascade);

            builder.HasOne(u => u.CompanyProfile)
                   .WithOne(c => c.User)
                   .HasForeignKey<CompanyUser>(c => c.Id)
                   .OnDelete(DeleteBehavior.Cascade);

            builder.HasOne(u => u.GraduateProfile)
                   .WithOne(g => g.User)
                   .HasForeignKey<Graduates>(g => g.UserId)
                   .OnDelete(DeleteBehavior.Cascade);

            builder.HasOne(u => u.UniversityProfile)
                   .WithOne(un => un.User)
                   .HasForeignKey<University>(un => un.UserId)
                   .OnDelete(DeleteBehavior.Cascade);

            builder.HasOne(u => u.TrainingCenterProfile)
                   .WithOne(un => un.User)
                   .HasForeignKey<TrainingCenter>(un => un.UserId)
                   .OnDelete(DeleteBehavior.Cascade);

            // ---- علاقات One-to-Many ----
            builder.HasMany(u => u.InternshipApplications)
                   .WithOne(a => a.User)
                   .HasForeignKey(a => a.UserId)
                   .OnDelete(DeleteBehavior.Restrict);

            builder.HasMany(u => u.CVs)
                   .WithOne(cv => cv.User)
                   .HasForeignKey(cv => cv.UserId)
                   .OnDelete(DeleteBehavior.Cascade);

            builder.HasMany(u => u.UploadedTemplates)
                   .WithOne(t => t.Company)
                   .HasForeignKey(t => t.CompanyId)
                   .OnDelete(DeleteBehavior.Cascade);
        }
    }
}