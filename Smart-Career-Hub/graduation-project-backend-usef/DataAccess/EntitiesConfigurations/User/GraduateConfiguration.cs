using DataAccess.Entities.Users;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.Configuration
{
    public class GraduateConfiguration : IEntityTypeConfiguration<Graduates>
    {
        public void Configure(EntityTypeBuilder<Graduates> builder)
        {
            builder.HasKey(g => g.Id);

            builder.Property(g => g.Major)
                   .IsRequired()
                   .HasMaxLength(150);

            builder.Property(g => g.Degree)
                   .IsRequired()
                   .HasMaxLength(100);

            builder.Property(g => g.University)
                   .IsRequired()
                   .HasMaxLength(200);

            builder.Property(g => g.GraduationYear)
                   .IsRequired();

            builder.Property(g => g.YearsOfExperience)
                   .IsRequired()
                   .HasDefaultValue(0);

            builder.Property(g => g.ExperienceSummary)
                   .HasMaxLength(1000);

            builder.Property(g => g.GitHub)
                   .HasMaxLength(300);

            builder.Property(g => g.LinkedIn)
                   .HasMaxLength(300);

            builder.Property(g => g.ProfileImage)
                   .HasMaxLength(500);

            builder.Property(g => g.CreatedAt)
                   .IsRequired();

            // Indexes
            builder.HasIndex(g => g.GraduationYear);
            builder.HasIndex(g => g.YearsOfExperience);
        }
    }
}
