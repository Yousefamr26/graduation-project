using DataAccess.Entities.Workshop;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.EntitiesConfigurations.WorksShops
{
    public class UniversityConfiguration : IEntityTypeConfiguration<University>
    {
        public void Configure(EntityTypeBuilder<University> builder)
        {
            builder.ToTable("Universities");

            builder.HasKey(u => u.Id);

            builder.Property(u => u.Name)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(u => u.City)
                .HasMaxLength(200);

            builder.Property(u => u.Country)
                .HasMaxLength(200);

            builder.Property(u => u.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETDATE()");

            // Relationship
            builder.HasMany(u => u.Workshops)
                .WithOne(w => w.University)
                .HasForeignKey(w => w.UniversityId)
                .OnDelete(DeleteBehavior.Restrict);

            // ✅ Seed Data - Fixed: استخدم تاريخ ثابت بدل DateTime.Now
            builder.HasData(
                new University
                {
                    Id = 1,
                    Name = "Alexandria University",
                    City = "Alexandria",
                    Country = "Egypt",
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new University
                {
                    Id = 2,
                    Name = "Cairo University",
                    City = "Cairo",
                    Country = "Egypt",
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new University
                {
                    Id = 3,
                    Name = "Ain Shams University",
                    City = "Cairo",
                    Country = "Egypt",
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new University
                {
                    Id = 4,
                    Name = "Mansoura University",
                    City = "Mansoura",
                    Country = "Egypt",
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new University
                {
                    Id = 5,
                    Name = "Assiut University",
                    City = "Assiut",
                    Country = "Egypt",
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new University
                {
                    Id = 6,
                    Name = "Tanta University",
                    City = "Tanta",
                    Country = "Egypt",
                    CreatedAt = new DateTime(2025, 1, 1)
                }
            );
        }
    }
}