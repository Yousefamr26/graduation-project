using DataAccess.Entities.Workshop;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.EntitiesConfigurations.WorksShops
{
    public class WorkshopEnrollmentConfiguration
        : IEntityTypeConfiguration<WorkshopEnrollment>
    {
        public void Configure(EntityTypeBuilder<WorkshopEnrollment> builder)
        {
            builder.ToTable("WorkshopEnrollments");

            builder.HasKey(e => e.Id);

            builder.Property(e => e.UserId)
                .IsRequired();

            builder.Property(e => e.WorkshopId)
                .IsRequired();

            builder.Property(e => e.RegisteredAt)
                .IsRequired()
                .HasDefaultValueSql("GETDATE()");

            builder.Property(e => e.CvUploaded)
                .HasDefaultValue(false);

            builder.Property(e => e.RoadmapCompleted)
                .HasDefaultValue(false);

            // منع نفس اليوزر يسجل في نفس الوركشوب مرتين
            builder.HasIndex(e => new { e.UserId, e.WorkshopId })
                .IsUnique();

            builder.HasOne(e => e.Workshop)
                .WithMany(w => w.Enrollments)
                .HasForeignKey(e => e.WorkshopId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
