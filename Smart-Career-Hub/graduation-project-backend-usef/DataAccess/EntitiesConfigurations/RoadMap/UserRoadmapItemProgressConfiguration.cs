using DataAccess.Entities.RoadMap;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.EntitiesConfigurations.RoadMap
{
    public class UserRoadmapItemProgressConfiguration
        : IEntityTypeConfiguration<UserRoadmapItemProgress>
    {
        public void Configure(EntityTypeBuilder<UserRoadmapItemProgress> builder)
        {
            builder.ToTable("UserRoadmapItemProgress");

            builder.HasKey(x => x.Id);

            builder.Property(x => x.UserId)
                   .IsRequired();

            builder.Property(x => x.RoadmapId)
                   .IsRequired();

            builder.Property(x => x.ItemId)
                   .IsRequired();

            builder.Property(x => x.ItemType)
                   .HasMaxLength(50)
                   .IsRequired();

            builder.Property(x => x.IsCompleted)
                   .HasDefaultValue(false)
                   .IsRequired();

            builder.Property(x => x.CompletedAt)
                   .IsRequired(false);

            builder.HasIndex(x => new
            {
                x.UserId,
                x.RoadmapId,
                x.ItemId,
                x.ItemType
            }).IsUnique();
        }
    }
}
