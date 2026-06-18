using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

public class InternshipRequiredSkillConfiguration : IEntityTypeConfiguration<InternshipRequiredSkill>
{
    public void Configure(EntityTypeBuilder<InternshipRequiredSkill> builder)
    {
        builder.HasKey(s => s.Id);

        builder.Property(s => s.Skill)
            .IsRequired()
            .HasMaxLength(100);

       
    }
}
