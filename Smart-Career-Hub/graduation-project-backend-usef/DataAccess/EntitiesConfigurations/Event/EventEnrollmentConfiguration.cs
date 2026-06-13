using DataAccess.Entities.Events;
using DataAccess.Entities.Users;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

public class EventEnrollmentConfiguration
    : IEntityTypeConfiguration<EventEnrollment>
{
    public void Configure(EntityTypeBuilder<EventEnrollment> builder)
    {
        // 🔹 Table name
        builder.ToTable("EventEnrollments");

        // 🔹 Primary Key
        builder.HasKey(e => e.Id);

        builder.Property(e => e.Id)
               .ValueGeneratedOnAdd();

        // 🔹 Required fields
        builder.Property(e => e.EventId)
               .IsRequired();

        builder.Property(e => e.UserId)
               .IsRequired();

        builder.Property(e => e.Email)
               .IsRequired()
               .HasMaxLength(256);

        builder.Property(e => e.PhoneNumber)
               .IsRequired()
               .HasMaxLength(30);

        builder.Property(e => e.Motivation)
               .HasMaxLength(1000);

        builder.Property(e => e.EnrolledAt)
               .IsRequired();

        // 🔹 Unique constraint (User can't enroll twice in same event)
        builder.HasIndex(e => new { e.EventId, e.UserId })
               .IsUnique();

        // 🔹 Relationship with ApplicationUser
        builder.HasOne(e => e.User)
               .WithMany()
               .HasForeignKey(e => e.UserId)
               .OnDelete(DeleteBehavior.Restrict);

        // 🔹 Relationship with Event
        builder.HasOne(e => e.Event)
               .WithMany(e => e.Enrollments)
               .HasForeignKey(e => e.EventId)
               .OnDelete(DeleteBehavior.Cascade);

        // 🔹 Index for queries
        builder.HasIndex(e => e.UserId);
    }
}
