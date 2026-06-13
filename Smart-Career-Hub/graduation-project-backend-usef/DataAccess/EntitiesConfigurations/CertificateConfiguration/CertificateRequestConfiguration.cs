using DataAccess.Entities.RoadMap;
using DataAccess.Entities.Users;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.EntitiesConfigurations.Certificates
{
    public class CertificateRequestConfiguration : IEntityTypeConfiguration<CertificateRequest>
    {
        public void Configure(EntityTypeBuilder<CertificateRequest> builder)
        {
            builder.ToTable("CertificateRequests");

            builder.HasKey(x => x.Id);

            // ===== User =====
            builder.HasOne(x => x.User)
                   .WithMany(u => u.CertificateRequests)
                   .HasForeignKey(x => x.UserId)
                   .OnDelete(DeleteBehavior.Restrict);

            // ===== Roadmap =====
            builder.HasOne(x => x.Roadmap)
                   .WithMany(r => r.CertificateRequests)
                   .HasForeignKey(x => x.RoadmapId)
                   .OnDelete(DeleteBehavior.Cascade);

            // ===== Properties =====
            builder.Property(x => x.RequestedAt)
                   .IsRequired()
                   .HasDefaultValueSql("GETUTCDATE()");

            // ===== Indexes =====

            // يمنع طلب شهادة أكثر من مرة لنفس الرودماب
            builder.HasIndex(x => new { x.UserId, x.RoadmapId })
                   .IsUnique();
        }
    }
}