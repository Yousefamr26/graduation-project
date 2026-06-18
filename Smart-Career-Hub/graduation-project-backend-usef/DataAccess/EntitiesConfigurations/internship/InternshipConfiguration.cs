using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

public class InternshipConfiguration : IEntityTypeConfiguration<Internship>
{
    public void Configure(EntityTypeBuilder<Internship> builder)
    {
        builder.HasKey(i => i.Id);

        builder.Property(i => i.Title)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(i => i.Status)
            .HasConversion<string>()
            .HasMaxLength(20)
            .HasDefaultValue(InternshipStatus.Open)
            .IsRequired();

        builder.Property(i => i.Type)
            .HasConversion<string>()
            .HasMaxLength(20)
            .IsRequired();

        builder.Property(i => i.Location)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(i => i.Description)
            .IsRequired()
            .HasMaxLength(2000);

        builder.Property(i => i.DurationInMonths)
            .IsRequired();

        builder.Property(i => i.MaxTrainees)
            .IsRequired();

        builder.Property(i => i.ApplicationDeadline)
            .IsRequired();

        // ================= Relations =================

        // Internship → CompanyUser
        builder.HasOne(i => i.Company)
            .WithMany(c => c.Internships)
            .HasForeignKey(i => i.CompanyId)
            .OnDelete(DeleteBehavior.Cascade);

        // Internship → Required Skills
        

        // Internship → Applications
        builder.HasMany(i => i.Applications)
            .WithOne(a => a.Internship)
            .HasForeignKey(a => a.InternshipId)
            .OnDelete(DeleteBehavior.Restrict); 
    }
}
