using DataAccess.Entities.RoadMap;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.EntitiesConfigurations.RoadMap
{
    public class LearningMaterialSec34Configuration : IEntityTypeConfiguration<LearningMaterialSec34>
    {
        public void Configure(EntityTypeBuilder<LearningMaterialSec34> builder)
        {
            builder.ToTable("LearningMaterials", t =>
            {
                t.HasCheckConstraint("CK_LearningMaterials_Type",
                    "[MaterialType] IN ('Video','PDF')");
                t.HasCheckConstraint("CK_LearningMaterials_VideoDuration",
                    "[VideoDuration] IS NULL OR [VideoDuration] IN ('Short','Medium','Long','VeryLong')");
                t.HasCheckConstraint("CK_LearningMaterials_PdfDuration",
                    "[PdfDuration] IS NULL OR [PdfDuration] IN ('Short','Medium','Long')");
            });
            builder.HasKey(x => x.Id);

            builder.Property(x => x.TitleVideos)
                   .HasMaxLength(200);

            builder.Property(x => x.TitlePdf)
                   .HasMaxLength(200);

            builder.Property(x => x.VideoDuration)
                   .HasMaxLength(50);

            builder.Property(x => x.PdfDuration)
                   .HasMaxLength(50);

            builder.Property(x => x.MaterialType)
                   .HasMaxLength(50)
                   .IsRequired();

            builder.Property(x => x.FilePath)
                   .HasMaxLength(500)
                   .IsRequired();

            builder.Property(x => x.CreatedAt)
                   .IsRequired()
                   .HasDefaultValueSql("GETDATE()");

            builder.Property(x => x.UpdatedAt)
                   .IsRequired(false);
            builder.Property(x => x.Points)
       .IsRequired()
       .HasDefaultValue(0);

            builder.Property(x => x.RoadmapId)
                   .IsRequired();

            builder.HasIndex(x => x.RoadmapId);
            builder.HasIndex(x => x.MaterialType);
            builder.HasIndex(x => new { x.RoadmapId, x.MaterialType });

            builder.HasOne(x => x.Roadmap)
                   .WithMany(r => r.LearningMaterials)
                   .HasForeignKey(x => x.RoadmapId)
                   .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
