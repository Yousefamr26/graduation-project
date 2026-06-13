using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

public class InternshipApplicationConfiguration
    : IEntityTypeConfiguration<InternshipApplication>
{
    public void Configure(EntityTypeBuilder<InternshipApplication> builder)
    {
        builder.HasKey(a => a.Id);

        builder.Property(a => a.Status)
            .HasConversion<string>()
            .HasMaxLength(20)
            .HasDefaultValue(ApplicationStatu.Applied)
            .IsRequired();

        builder.Property(a => a.AppliedAt)
            .HasDefaultValueSql("GETUTCDATE()");

        // ================= Relations =================

        // Application → Internship
        builder.HasOne(a => a.Internship)
            .WithMany(i => i.Applications)
            .HasForeignKey(a => a.InternshipId)
            .OnDelete(DeleteBehavior.Restrict);

        // Application → User
        builder.HasOne(a => a.User)
            .WithMany(u => u.InternshipApplications)
            .HasForeignKey(a => a.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        // ================= Constraints =================

        builder.HasIndex(a => new { a.InternshipId, a.UserId })
            .IsUnique();
    }
}
