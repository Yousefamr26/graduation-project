using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using DataAccess.Entities.Job;

namespace DataAccess.Contexts.Configurations
{
    public class JobApplicationConfiguration : IEntityTypeConfiguration<JobApplication>
    {
        public void Configure(EntityTypeBuilder<JobApplication> builder)
        {
            builder.ToTable("JobApplications");

            // Primary Key
            builder.HasKey(j => j.Id);

            // FK User
            builder.HasOne(j => j.User)
                   .WithMany(u => u.JobApplications) // لازم تضيف ICollection<JobApplication> في ApplicationUser
                   .HasForeignKey(j => j.UserId)
                   .OnDelete(DeleteBehavior.Cascade);

            // FK Job
            builder.HasOne(j => j.Job)
                   .WithMany(jb => jb.JobApplications) // لازم تضيف ICollection<JobApplication> في Job
                   .HasForeignKey(j => j.JobId)
                   .OnDelete(DeleteBehavior.Cascade);

            // Optional Interview FK
            builder.HasOne(j => j.Interview)
                   .WithOne()
                   .HasForeignKey<JobApplication>(j => j.InterviewId)
                   .OnDelete(DeleteBehavior.SetNull);

            // Store Enum as string
            builder.Property(j => j.Status)
                   .HasConversion<string>()
                   .HasMaxLength(50)
                   .IsRequired();

            // Check Constraint على القيم
            builder.HasCheckConstraint(
                "CK_JobApplications_Status",
                "[Status] IN ('Applied','UnderReview','InterviewScheduled','OfferReceived','Rejected')"
            );

            // Dates
            builder.Property(j => j.AppliedAt)
                   .HasDefaultValueSql("GETUTCDATE()");

            builder.Property(j => j.LastUpdatedAt)
                   .HasDefaultValueSql("GETUTCDATE()");
        }
    }
}
