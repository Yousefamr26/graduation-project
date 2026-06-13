using DataAccess.Entities.User;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.EntitiesConfigurations.User
{
    public class TrainingCenterConfiguration : IEntityTypeConfiguration<TrainingCenter>
    {
        public void Configure(EntityTypeBuilder<TrainingCenter> builder)
        {
            builder.ToTable("TrainingCenters");
            builder.HasKey(t => t.Id);
            builder.Property(t => t.Id)
                .IsRequired();
            builder.Property(t => t.UserId)
                .IsRequired();
            builder.HasIndex(t => t.UserId)
                .IsUnique();
            builder.Property(t => t.Name)
                .IsRequired()
                .HasMaxLength(200);
            builder.Property(t => t.OrganizationLogo)
                .HasMaxLength(500);
            builder.Property(t => t.City)
                .IsRequired()
                .HasMaxLength(200);
            builder.Property(t => t.Country)
                .IsRequired()
                .HasMaxLength(200);
            builder.Property(t => t.CreatedAt)
                .HasDefaultValueSql("GETDATE()");

            // =============================
            // One-To-One with ApplicationUser
            // =============================
            builder.HasOne(t => t.User)
                   .WithOne(a => a.TrainingCenterProfile)
                   .HasForeignKey<TrainingCenter>(t => t.UserId)
                   .OnDelete(DeleteBehavior.Cascade);



        }
    }
}