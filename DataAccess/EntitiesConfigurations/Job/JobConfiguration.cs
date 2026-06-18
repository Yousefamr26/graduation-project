using DataAccess.Entities.Job;

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.Configurations
{
    public class JobConfiguration : IEntityTypeConfiguration<Job>
    {
        public void Configure(EntityTypeBuilder<Job> builder)
        {
            builder.ToTable("Jobs");

            builder.HasKey(j => j.Id);

            builder.Property(j => j.Title)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(j => j.Description)
                .IsRequired()
                .HasColumnType("nvarchar(max)");

            builder.Property(j => j.RequiredSkills)
                .IsRequired()
                .HasMaxLength(500);

            builder.Property(j => j.ExperienceLevel)
                .IsRequired()
                .HasMaxLength(50);

            builder.Property(j => j.JobType)
                .IsRequired()
                .HasMaxLength(50);

            builder.Property(j => j.Location)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(j => j.SalaryRange)
                .HasMaxLength(100);

            builder.Property(j => j.CompanyLogo)
                .HasMaxLength(500);

            builder.Property(j => j.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETDATE()");
        }
    }
}