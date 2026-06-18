using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

public class ChatRoomConfiguration : IEntityTypeConfiguration<ChatRoom>
{
    public void Configure(EntityTypeBuilder<ChatRoom> builder)
    {
        builder.ToTable("ChatRooms");

        builder.HasKey(c => c.Id);

        builder.Property(c => c.CreatedAt)
            .IsRequired();

        // العلاقة مع الطالب/الخريج
        builder.HasOne(c => c.Applicant)
            .WithMany()
            .HasForeignKey(c => c.ApplicantId)
            .OnDelete(DeleteBehavior.Restrict);

        // العلاقة مع الشركة/الجهة
        builder.HasOne(c => c.Entity)
            .WithMany()
            .HasForeignKey(c => c.EntityId)
            .OnDelete(DeleteBehavior.Restrict);

        // منع تكرار room بين نفس الاتنين
        builder.HasIndex(c => new { c.ApplicantId, c.EntityId })
            .IsUnique();
    }
}