using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SmartCareerHub.Entities;

namespace SmartCareerHub.Configurations
{
    public class PaymentConfiguration : IEntityTypeConfiguration<Payment>
    {
        public void Configure(EntityTypeBuilder<Payment> builder)
        {
            builder.ToTable("Payments");

            builder.HasKey(p => p.Id);

            builder.Property(p => p.Amount).IsRequired();
            builder.Property(p => p.Status)
                   .IsRequired()
                   .HasMaxLength(20);
            builder.Property(p => p.StripePaymentId)
                   .HasMaxLength(50);
            builder.Property(p => p.CreatedAt)
                   .HasDefaultValueSql("GETUTCDATE()");
            builder.Property(p => p.UpdatedAt)
                   .IsRequired(false);

            // علاقات Foreign Keys
            builder.HasOne(p => p.User)
                   .WithMany(u => u.Payments) // لازم تضيف ICollection<Payment> في ApplicationUser
                   .HasForeignKey(p => p.UserId)
                   .OnDelete(DeleteBehavior.Cascade);

            builder.HasOne(p => p.Roadmap)
                   .WithMany(r => r.Payments) // لازم تضيف ICollection<Payment> في Roadmap
                   .HasForeignKey(p => p.RoadmapId)
                   .OnDelete(DeleteBehavior.Cascade);

            // Index لتحسين البحث
            builder.HasIndex(p => new { p.UserId, p.RoadmapId });
        }
    }
}