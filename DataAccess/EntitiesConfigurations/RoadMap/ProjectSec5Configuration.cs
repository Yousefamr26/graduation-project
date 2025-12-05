using DataAccess.Entities.RoadMap;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.EntitiesConfigurations.RoadMap
{
    public class ProjectSec5Configuration : IEntityTypeConfiguration<ProjectSec5>
    {
        public void Configure(EntityTypeBuilder<ProjectSec5> builder)
        {
            builder.ToTable("Projects", t =>
            {
                t.HasCheckConstraint("CK_Projects_Difficulty", "[Difficulty] IN ('Easy','Medium','Hard')");
            });
            builder.HasKey(x => x.Id);

            builder.Property(x => x.Title)
                   .HasMaxLength(200)
                   .IsRequired();

            builder.Property(x => x.Description)
                   .HasMaxLength(2000);

            builder.Property(x => x.Difficulty)
                   .HasMaxLength(50)
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
            builder.HasIndex(x => x.Difficulty);
            builder.HasIndex(x => x.Title);

            builder.HasOne(x => x.Roadmap)
                   .WithMany(r => r.Projects)
                   .HasForeignKey(x => x.RoadmapId)
                   .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
