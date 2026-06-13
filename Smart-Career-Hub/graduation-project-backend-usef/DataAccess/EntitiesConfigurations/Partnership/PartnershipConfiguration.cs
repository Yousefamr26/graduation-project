// DataAccess/Configurations/PartnershipConfiguration.cs
using DataAccess.Entities.Partnership;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.Configurations
{
    public class PartnershipConfiguration : IEntityTypeConfiguration<Partnership>
    {
        public void Configure(EntityTypeBuilder<Partnership> builder)
        {
            builder.ToTable("Partnerships");

            builder.HasKey(p => p.Id);

            builder.Property(p => p.Id)
                .ValueGeneratedOnAdd();

            builder.Property(p => p.UniversityId)
                .IsRequired();

            builder.Property(p => p.CompanyId)
                .IsRequired()
                .HasMaxLength(450);

            builder.Property(p => p.PartnershipType)
                .IsRequired()
                .HasMaxLength(100);

            builder.Property(p => p.CompanyName)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(p => p.IndustryField)
                .HasMaxLength(200);

            builder.Property(p => p.ContactPersonName)
                .HasMaxLength(200);

            builder.Property(p => p.ContactEmail)
                .HasMaxLength(200);

            builder.Property(p => p.Website)
                .HasMaxLength(500);

            builder.Property(p => p.Location)
                .HasMaxLength(300);

            builder.Property(p => p.PartnershipDetails)
                .HasColumnType("NVARCHAR(MAX)");

            builder.Property(p => p.StartDate)
                .IsRequired();

            builder.Property(p => p.Status)
                .IsRequired()
                .HasMaxLength(50)
                .HasDefaultValue("Pending");

            builder.Property(p => p.EventsHosted)
                .HasDefaultValue(0);

            builder.Property(p => p.StudentsReached)
                .HasDefaultValue(0);

            builder.Property(p => p.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");

            builder.Property(p => p.UpdatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");
            builder.Property(p => p.Phone)
    .HasMaxLength(11);

            // ========== Relationships ==========

            // Partnership -> University (Many-to-One)
            builder.HasOne(p => p.University)
                .WithMany(u => u.Partnerships)
                .HasForeignKey(p => p.UniversityId)
                .OnDelete(DeleteBehavior.Restrict);

            // Partnership -> Company (Many-to-One)
            builder.HasOne(p => p.Company)
                .WithMany(c => c.Partnerships)
                .HasForeignKey(p => p.CompanyId)
                .OnDelete(DeleteBehavior.Restrict);

            // Partnership -> PartnershipEvents (One-to-Many)
            builder.HasMany(p => p.PartnershipEvents)
                .WithOne(pe => pe.Partnership)
                .HasForeignKey(pe => pe.PartnershipId)
                .OnDelete(DeleteBehavior.Cascade);

            // ========== Indexes ==========

            builder.HasIndex(p => p.UniversityId)
                .HasDatabaseName("IX_Partnerships_UniversityId");

            builder.HasIndex(p => p.CompanyId)
                .HasDatabaseName("IX_Partnerships_CompanyId");

            builder.HasIndex(p => p.Status)
                .HasDatabaseName("IX_Partnerships_Status");

            // Unique constraint: منع تكرار الشراكة بين نفس الجامعة والشركة
            builder.HasIndex(p => new { p.UniversityId, p.CompanyId })
                .IsUnique()
                .HasDatabaseName("IX_Partnerships_University_Company_Unique");
        }
    }
}