using DataAccess.Entities.Interview;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.EntitiesConfigurations.Interviews
{
    public class InterviewConfiguration : IEntityTypeConfiguration<InterviewSchedule>
    {
        public void Configure(EntityTypeBuilder<InterviewSchedule> builder)
        {
            builder.ToTable("Interviews");

            builder.HasKey(i => i.Id);

            builder.Property(i => i.StudentName)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(i => i.UserId)
                .IsRequired()
                .HasMaxLength(450);

            builder.Property(i => i.RoadmapId)
                .IsRequired();

            builder.Property(i => i.CV)
                .HasMaxLength(500);

            builder.Property(i => i.IsAIPick)
                .IsRequired()
                .HasDefaultValue(false);

            // ✅ بدل Date + Time
            builder.Property(i => i.ScheduledAt)
                .IsRequired();

            builder.Property(i => i.InterviewType)
                .IsRequired()
                .HasMaxLength(50);

            builder.Property(i => i.MeetingLink)
                .HasMaxLength(500);

            builder.Property(i => i.Location)
                .HasMaxLength(500);

            builder.Property(i => i.InterviewerName)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(i => i.AdditionalNotes)
                .HasMaxLength(1000);

            // ✅ Enum Status
            builder.Property(i => i.Status)
                .HasConversion<string>() // يخزنها كنص في الداتا بيز
                .IsRequired()
                .HasDefaultValue(InterviewStatus.Pending);

            // ✅ Enum Result
            builder.Property(i => i.Result)
                .HasConversion<string>()
                .IsRequired()
                .HasDefaultValue(InterviewResult.None);

            builder.Property(i => i.Feedback)
                .HasMaxLength(2000);

            builder.Property(i => i.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETDATE()");

            // 🔥 Indexes مهمة للأداء
            builder.HasIndex(i => i.UserId);
            builder.HasIndex(i => i.RoadmapId);
            builder.HasIndex(i => i.ScheduledAt);
            builder.HasIndex(i => i.Status);
            builder.HasIndex(i => i.IsAIPick);

            // 🔹 Roadmap Relationship
            builder.HasOne(i => i.Roadmap)
                .WithMany(r => r.Interviews)
                .HasForeignKey(i => i.RoadmapId)
                .OnDelete(DeleteBehavior.Restrict);

            // 🔹 User Relationship
            builder.HasOne(i => i.User)
                .WithMany() // أو WithMany(u => u.Interviews) لو ضفت collection
                .HasForeignKey(i => i.UserId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}