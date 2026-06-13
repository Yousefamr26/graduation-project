// DataAccess/Configuration/CompanyUserConfiguration.cs
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using DataAccess.Entities.Users;

namespace DataAccess.Configuration
{
    public class CompanyUserConfiguration : IEntityTypeConfiguration<CompanyUser>
    {
        public void Configure(EntityTypeBuilder<CompanyUser> builder)
        {
            builder.ToTable("CompanyUser");

            builder.HasKey(c => c.Id);

            builder.HasOne(c => c.User)
                .WithOne(u => u.CompanyProfile)
                .HasForeignKey<CompanyUser>(c => c.UserId)
                .IsRequired()
                .OnDelete(DeleteBehavior.Cascade);

            builder.Property(c => c.OrganizationName)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(c => c.Country)
                .IsRequired()
                .HasMaxLength(100);

            builder.Property(c => c.City)
                .IsRequired()
                .HasMaxLength(100);

            builder.Property(c => c.OrganizationLogo)
                .HasMaxLength(250)
                .IsRequired(false);

            // Jobs relation
            builder.HasMany(c => c.Jobs)
                .WithOne(j => j.CompanyUser)
                .HasForeignKey(j => j.CompanyUserId)
                .OnDelete(DeleteBehavior.Cascade);

            // Internships relation
            builder.HasMany(c => c.Internships)
                .WithOne(i => i.Company)
                .HasForeignKey(i => i.CompanyId)
                .OnDelete(DeleteBehavior.Cascade);

            // Workshops relation
            builder.HasMany(c => c.Workshops)
                .WithOne(w => w.Company)
                .HasForeignKey(w => w.CompanyId)
                .OnDelete(DeleteBehavior.Cascade);

            // ✅ Partnerships relation - جديد
            builder.HasMany(c => c.Partnerships)
                .WithOne(p => p.Company)
                .HasForeignKey(p => p.CompanyId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}