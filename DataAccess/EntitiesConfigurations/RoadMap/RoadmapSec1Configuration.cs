using DataAccess.Entities.RoadMap;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.EntitiesConfigurations.RoadMap
{
    public class RoadmapSec1Configuration : IEntityTypeConfiguration<RoadmapSec1>
    {
        public void Configure(EntityTypeBuilder<RoadmapSec1> builder)
        {
            builder.ToTable("Roadmaps", t =>
            {
                t.HasCheckConstraint("CK_Roadmaps_TargetRole",
                    "[TargetRole] IN ('Student','Graduate','Both')");
            });

            builder.HasKey(x => x.Id);

            builder.Property(x => x.Title)
                   .HasMaxLength(200)
                   .IsRequired();

            builder.Property(x => x.Description)
                   .HasMaxLength(2000)
                   .IsRequired();

            builder.Property(x => x.CoverImageUrl)
                   .HasMaxLength(500);

            builder.Property(x => x.TargetRole)
                   .HasMaxLength(50)
                   .IsRequired();

            builder.Property(x => x.StartDate).IsRequired(false);
            builder.Property(x => x.EndDate).IsRequired(false);

            builder.Property(x => x.CreatedAt)
                   .IsRequired()
                   .HasDefaultValueSql("GETDATE()");

            builder.Property(x => x.UpdatedAt).IsRequired(false);

            builder.Property(x => x.IsPublished)
                   .IsRequired()
                   .HasDefaultValue(false);

            builder.Property(x => x.TotalPoints).HasDefaultValue(0);
            builder.Property(x => x.TotalMaterials).HasDefaultValue(0);
            builder.Property(x => x.TotalProjects).HasDefaultValue(0);
            builder.Property(x => x.TotalQuizzes).HasDefaultValue(0);

            builder.HasIndex(x => x.Title);
            builder.HasIndex(x => x.IsPublished);
            builder.HasIndex(x => x.TargetRole);
            builder.HasIndex(x => new { x.IsPublished, x.TargetRole });

            builder.HasMany(x => x.RequiredSkills)
                   .WithOne(rs => rs.Roadmap)
                   .HasForeignKey(rs => rs.RoadmapId)
                   .OnDelete(DeleteBehavior.Cascade);

            builder.HasMany(x => x.LearningMaterials)
                   .WithOne(lm => lm.Roadmap)
                   .HasForeignKey(lm => lm.RoadmapId)
                   .OnDelete(DeleteBehavior.Cascade);

            builder.HasMany(x => x.Projects)
                   .WithOne(p => p.Roadmap)
                   .HasForeignKey(p => p.RoadmapId)
                   .OnDelete(DeleteBehavior.Cascade);

            builder.HasMany(x => x.Quizzes)
                   .WithOne(q => q.Roadmap)
                   .HasForeignKey(q => q.RoadmapId)
                   .OnDelete(DeleteBehavior.Cascade);

            builder.HasMany(x => x.Interviews)
                   .WithOne(i => i.Roadmap)
                   .HasForeignKey(i => i.RoadmapId)
                   .OnDelete(DeleteBehavior.Restrict);  
        }
    }
}