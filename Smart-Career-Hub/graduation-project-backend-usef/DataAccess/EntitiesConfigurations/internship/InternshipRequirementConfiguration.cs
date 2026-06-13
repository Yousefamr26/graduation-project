using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

public class InternshipRequirementConfiguration : IEntityTypeConfiguration<InternshipRequirement>
{
    public void Configure(EntityTypeBuilder<InternshipRequirement> builder)
    {
        builder.HasKey(r => r.Id);

        builder.Property(r => r.Requirement)
            .IsRequired()
            .HasMaxLength(200);

      
    }
}
