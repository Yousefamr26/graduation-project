using DataAccess.Entities.Users;
using DataAccess.Entities.RoadMap;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

public class UserRoadmapConfiguration : IEntityTypeConfiguration<UserRoadmap>
{
    public void Configure(EntityTypeBuilder<UserRoadmap> builder)
    {
        builder.ToTable("UserRoadmaps");

        builder.HasKey(ur => ur.Id);

        // User (AspNetUsers)
        builder.HasOne(ur => ur.User)
               .WithMany(u => u.UserRoadmaps)
               .HasForeignKey(ur => ur.UserId)
               .OnDelete(DeleteBehavior.Cascade);

        // Roadmap
        builder.HasOne(ur => ur.Roadmap)
               .WithMany()
               .HasForeignKey(ur => ur.RoadmapId)
               .OnDelete(DeleteBehavior.Restrict);

        builder.Property(ur => ur.Status)
               .HasMaxLength(50)
               .HasDefaultValue("In Progress")
               .IsRequired();

        builder.Property(ur => ur.ProgressPercent)
               .HasDefaultValue(0);

        builder.Property(ur => ur.JoinedAt)
               .HasDefaultValueSql("GETDATE()");
    }
}
