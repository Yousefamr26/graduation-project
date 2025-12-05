using DataAccess.Entities.RoadMap;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.EntitiesConfigurations.RoadMap
{
    public class RequiredSkillSec2Configuration : IEntityTypeConfiguration<RequiredSkillSec2>
    {
        public void Configure(EntityTypeBuilder<RequiredSkillSec2> builder)
        {
            builder.ToTable("RequiredSkills", t =>
            {
                t.HasCheckConstraint("CK_RequiredSkills_Level",
                    "[Level] IN ('Beginner','Intermediate','Advanced')");
            });
            builder.HasKey(x => x.Id);

            builder.Property(x => x.SkillName)
                   .HasMaxLength(150)
                   .IsRequired();

            builder.Property(x => x.Level)
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
            builder.HasIndex(x => x.SkillName);
            builder.HasIndex(x => new { x.RoadmapId, x.SkillName });

            builder.HasOne(x => x.Roadmap)
                   .WithMany(r => r.RequiredSkills)
                   .HasForeignKey(x => x.RoadmapId)
                   .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
