using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using DataAccess.Entities.Events;

namespace DataAccess.Configurations
{
    public class EventConfiguration : IEntityTypeConfiguration<Event>
    {
        public void Configure(EntityTypeBuilder<Event> builder)
        {
            builder.ToTable("Events");

            builder.HasKey(e => e.Id);

            builder.Property(e => e.Title)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(e => e.Description)
                .IsRequired()
                .HasColumnType("nvarchar(max)");

            builder.Property(e => e.BannerUrl)
                .HasMaxLength(500);

            builder.Property(e => e.EventType)
                .IsRequired()
                .HasMaxLength(50);

            builder.Property(e => e.Mode)
                .IsRequired()
                .HasMaxLength(50);

            builder.Property(e => e.StartDate)
                .IsRequired();

            builder.Property(e => e.StartTime)
                .IsRequired();

            builder.Property(e => e.MinimumRequiredPoints)
                .HasDefaultValue(0);

            builder.Property(e => e.CompletedRoadmap)
                .HasDefaultValue(false);

            builder.Property(e => e.Completed50PercentCourses)
                .HasDefaultValue(false);

            builder.Property(e => e.HighCommunicationSkills)
                .HasDefaultValue(false);

            builder.Property(e => e.HighTechnicalSkills)
                .HasDefaultValue(false);

            builder.Property(e => e.Top30PercentProgress)
                .HasDefaultValue(false);

            builder.Property(e => e.InviteOnlyEligibleStudents)
                .HasDefaultValue(false);

            builder.Property(e => e.EligibleStudentsCount)
                .HasDefaultValue(0);

            builder.Property(e => e.ExpectedAttendees)
                .HasDefaultValue(0);

            builder.Property(e => e.CurrentRegistrations)
                .HasDefaultValue(0);

            builder.Property(e => e.MaxCapacity)
                .IsRequired();

            builder.Property(e => e.AllowWaitingList)
                .HasDefaultValue(false);

            builder.Property(e => e.SendAutoEmailToEligibleStudents)
                .HasDefaultValue(false);

            builder.Property(e => e.PointsForAttendance)
                .HasDefaultValue(0);

            builder.Property(e => e.PointsForFullParticipation)
                .HasDefaultValue(0);

            builder.Property(e => e.IsPublished)
                .HasDefaultValue(false);

            builder.Property(e => e.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETDATE()");

            builder.Property(e => e.UpdatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETDATE()");
        }
    }
}