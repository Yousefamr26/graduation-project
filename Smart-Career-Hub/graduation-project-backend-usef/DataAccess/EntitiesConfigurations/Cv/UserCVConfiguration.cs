using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

public class UserCVConfiguration : IEntityTypeConfiguration<UserCV>
{
    public void Configure(EntityTypeBuilder<UserCV> builder)
    {
        builder.ToTable("UserCVs");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.FileName)
            .IsRequired()
            .HasMaxLength(250);

        builder.Property(x => x.FilePath)
            .IsRequired();

        builder.Property(x => x.ContentType)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(x => x.UserId)
            .IsRequired();

        builder.Property(x => x.UploadedAt)
            .HasDefaultValueSql("GETUTCDATE()");

        builder.HasOne(x => x.User)
            .WithMany(u => u.CVs)
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        // ✅ أضف العلاقة مع CVTemplate
        builder.HasOne(x => x.CVTemplate)
            .WithMany()
            .HasForeignKey(x => x.CVTemplateId)
            .OnDelete(DeleteBehavior.NoAction);
    }
}