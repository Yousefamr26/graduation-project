using DataAccess.Entities.RoadMap;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.Configuration
{
    public class UserProgressConfiguration : IEntityTypeConfiguration<UserProgress>
    {
        public void Configure(EntityTypeBuilder<UserProgress> builder)
        {
            builder.ToTable("UserProgress");

            // PK
            builder.HasKey(up => up.Id);

            // Relation: UserRoadmap (1) -> UserProgress (Many)
            builder.HasOne(up => up.UserRoadmap)
                   .WithMany(ur => ur.ProgressItems)
                   .HasForeignKey(up => up.UserRoadmapId)
                   .OnDelete(DeleteBehavior.Cascade);

            // Enum → string
            builder.Property(up => up.MaterialType)
                   .HasConversion<string>()
                   .HasMaxLength(50)
                   .IsRequired();

            builder.Property(up => up.Completed)
                   .HasDefaultValue(false);

            builder.Property(up => up.PointsEarned)
                   .HasDefaultValue(0);

            builder.Property(up => up.CompletedAt)
                   .IsRequired(false);

            // Unique constraint
            builder.HasIndex(up => new
            {
                up.UserRoadmapId,
                up.MaterialId,
                up.MaterialType
            }).IsUnique();
        }
    }
}
