using DataAccess.Entities.Workshop;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.EntitiesConfigurations.WorksShops
{
    public class WorkshopConfiguration : IEntityTypeConfiguration<WorkshopSec1>
    {
        public void Configure(EntityTypeBuilder<WorkshopSec1> builder)
        {
            builder.ToTable("Workshops");
            builder.HasKey(w => w.Id);

            builder.Property(w => w.Title)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(w => w.Description)
                .IsRequired()
                .HasColumnType("nvarchar(max)");

            builder.Property(w => w.BannerUrl)
                .HasMaxLength(500);

            builder.Property(w => w.Location)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(w => w.WorkshopType)
                .IsRequired()
                .HasMaxLength(50);

            // HostType - جديد
            builder.Property(w => w.HostType)
                .IsRequired()
                .HasMaxLength(50)
                .HasDefaultValue("University");

            // Duration - جديد
            builder.Property(w => w.Duration)
                .HasMaxLength(50);

            // WorkshopDate - جديد
            builder.Property(w => w.WorkshopDate)
                .IsRequired();

            // WorkshopTime - جديد
            builder.Property(w => w.WorkshopTime)
                .IsRequired();

            builder.Property(w => w.MaxCapacity)
                .IsRequired();

            builder.Property(w => w.TotalPoints)
                .HasDefaultValue(0);

            builder.Property(w => w.RequireCV)
                .HasDefaultValue(false);

            builder.Property(w => w.RequireRoadmapCompletion)
                .HasDefaultValue(false);

            builder.Property(w => w.IsPublished)
                .HasDefaultValue(false);

            builder.Property(w => w.TotalActivities)
                .HasDefaultValue(0);

            builder.Property(w => w.TotalMaterials)
                .HasDefaultValue(0);

            builder.Property(w => w.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETDATE()");

            builder.Property(w => w.UpdatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETDATE()");
            builder.Property(w => w.CompanyId)
    .HasMaxLength(450); // ✅ إضافة MaxLength للـ string

            // University Relation (nullable الآن)
            builder.HasOne(w => w.University)
                .WithMany(u => u.Workshops)
                .HasForeignKey(w => w.UniversityId)
                .OnDelete(DeleteBehavior.Restrict)
                .IsRequired(false); // مش required دايمًا

            // Company Relation - جديد
            builder.HasOne(w => w.Company)
      .WithMany(c => c.Workshops)
      .HasForeignKey(w => w.CompanyId)
      .OnDelete(DeleteBehavior.Restrict)
      .IsRequired(false);

            // Materials
            builder.HasMany(w => w.Materials)
                .WithOne(m => m.Workshop)
                .HasForeignKey(m => m.WorkshopId)
                .OnDelete(DeleteBehavior.Cascade);

            // Activities
            builder.HasMany(w => w.Activities)
                .WithOne(a => a.Workshop)
                .HasForeignKey(a => a.WorkshopId)
                .OnDelete(DeleteBehavior.Cascade);

            // Enrollments
            builder.HasMany(w => w.Enrollments)
                .WithOne(e => e.Workshop)
                .HasForeignKey(e => e.WorkshopId)
                .OnDelete(DeleteBehavior.Cascade);

            // إضافة Check Constraint - مهم جدًا!
            // علشان نتأكد إن إما UniversityId أو CompanyId موجود، مش الاتنين ولا ولا واحد
            builder.HasCheckConstraint(
     "CK_Workshop_HostType",
     "([HostType] = 'University' AND [UniversityId] IS NOT NULL) OR " +
     "([HostType] = 'Company' AND [CompanyId] IS NOT NULL)"
 );
        }
    }
}