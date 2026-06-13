using DataAccess.Entities;
using DataAccess.Entities.RoadMap;
using DataAccess.Entities.Users;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.EntitiesConfigurations.Certificates
{
    public class CertificateConfiguration : IEntityTypeConfiguration<Certificate>
    {
        public void Configure(EntityTypeBuilder<Certificate> builder)
        {
            builder.ToTable("Certificates");

            builder.HasKey(x => x.Id);

            // ===== User =====
            builder.HasOne(x => x.User)
                   .WithMany(u => u.Certificates)
                   .HasForeignKey(x => x.UserId)
                   .OnDelete(DeleteBehavior.Restrict);

            // ===== Roadmap =====
            builder.HasOne(x => x.Roadmap)
                   .WithMany(r => r.Certificates)
                   .HasForeignKey(x => x.RoadmapId)
                   .OnDelete(DeleteBehavior.Cascade);

            // ===== Issuer (Company / Training Center) =====
            builder.HasOne(x => x.IssuedBy)
                   .WithMany(c => c.IssuedCertificates)
                   .HasForeignKey(x => x.IssuedById)
                   .OnDelete(DeleteBehavior.Restrict);

            // ===== Properties =====
            builder.Property(x => x.CertificateCode)
                   .HasMaxLength(100)
                   .IsRequired();

            builder.Property(x => x.PdfUrl)
                   .HasMaxLength(500);

            builder.Property(x => x.IssuedAt)
                   .HasDefaultValueSql("GETDATE()");

            builder.Property(x => x.IsValid)
                   .HasDefaultValue(true);

            // ===== Indexes =====
            builder.HasIndex(x => x.CertificateCode)
                   .IsUnique();

            builder.HasIndex(x => new { x.UserId, x.RoadmapId })
                   .IsUnique(); // شهادة واحدة فقط لكل طالب في كل Roadmap
        }
    }
}