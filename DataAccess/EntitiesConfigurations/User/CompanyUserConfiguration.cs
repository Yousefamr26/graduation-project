using DataAccess.Entities.Users;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.Configuration
{
    public class CompanyUserConfiguration : IEntityTypeConfiguration<CompanyUser>
    {
        public void Configure(EntityTypeBuilder<CompanyUser> builder)
        {
            builder.HasKey(c => c.Id);

            builder.HasOne(c => c.User)
                   .WithOne(u => u.CompanyProfile)
                   .HasForeignKey<CompanyUser>(c => c.Id)
                   .IsRequired(false)                   
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
        }
    }
}
