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

            builder.Property(i => i.RoadmapId)
                .IsRequired();

            builder.Property(i => i.CV)
                .HasMaxLength(500);

            builder.Property(i => i.IsAIPick)
                .IsRequired()
                .HasDefaultValue(false)
                .ValueGeneratedNever(); 

            builder.Property(i => i.Date)
                .IsRequired();

            builder.Property(i => i.Time)
                .IsRequired();

            builder.Property(i => i.InterviewType)
                .IsRequired()
                .HasMaxLength(50);

            builder.Property(i => i.Location)
                .IsRequired()
                .HasMaxLength(500);

            builder.Property(i => i.InterviewerName)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(i => i.AdditionalNotes)
                .HasMaxLength(1000);

            builder.Property(i => i.Status)
                .IsRequired()
                .HasMaxLength(50)
                .HasDefaultValue("Scheduled");

            builder.Property(i => i.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETDATE()");

           
            builder.HasIndex(i => i.RoadmapId);
            builder.HasIndex(i => i.Date);
            builder.HasIndex(i => i.Status);
            builder.HasIndex(i => i.IsAIPick);

            
            builder.HasOne(i => i.Roadmap)
                .WithMany(r => r.Interviews)
                .HasForeignKey(i => i.RoadmapId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}
