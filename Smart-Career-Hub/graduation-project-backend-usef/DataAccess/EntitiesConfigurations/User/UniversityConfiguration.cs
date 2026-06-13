using DataAccess.Entities.User;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.EntitiesConfigurations.User
{
    public class UniversityConfiguration : IEntityTypeConfiguration<University>
    {
        public void Configure(EntityTypeBuilder<University> builder)
        {
            builder.ToTable("Universities");

            builder.HasKey(u => u.Id);

            builder.Property(u => u.Id)
                .IsRequired();

            builder.Property(u => u.UserId)
                .IsRequired();

            builder.HasIndex(u => u.UserId)
                .IsUnique(); // ✅ عشان One-To-One

            builder.Property(u => u.Name)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(u => u.OrganizationLogo)
                .HasMaxLength(500);

            builder.Property(u => u.City)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(u => u.Country)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(u => u.CreatedAt)
                .HasDefaultValueSql("GETDATE()");

            // =============================
            // 🔥 One-To-One with ApplicationUser
            // =============================
            builder.HasOne(u => u.User)
                   .WithOne(a => a.UniversityProfile)
                   .HasForeignKey<University>(u => u.UserId)
                   .OnDelete(DeleteBehavior.Cascade);

            // =============================
            // Workshops
            // =============================
            builder.HasMany(u => u.Workshops)
                   .WithOne(w => w.University)
                   .HasForeignKey(w => w.UniversityId)
                   .OnDelete(DeleteBehavior.Restrict);

            // =============================
            // Partnerships
            // =============================
            builder.HasMany(u => u.Partnerships)
                   .WithOne(p => p.University)
                   .HasForeignKey(p => p.UniversityId)
                   .OnDelete(DeleteBehavior.Cascade);
        }
    }
}