// DataAccess/EntitiesConfigurations/Events/EventConfiguration.cs
using DataAccess.Entities.Events;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.EntitiesConfigurations.Events
{
    public class EventConfiguration : IEntityTypeConfiguration<Event>
    {
        public void Configure(EntityTypeBuilder<Event> builder)
        {
            builder.ToTable("Events");

            builder.HasKey(e => e.Id);

            builder.Property(e => e.Title)
                .IsRequired()
                .HasMaxLength(300);

            builder.Property(e => e.Description)
                .IsRequired()
                .HasMaxLength(2000);

            builder.Property(e => e.BannerUrl)
                .HasMaxLength(500);

            builder.Property(e => e.EventType)
                .IsRequired()
                .HasMaxLength(100);

            builder.Property(e => e.Mode)
                .IsRequired()
                .HasMaxLength(50);

            builder.Property(e => e.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETDATE()");

            builder.Property(e => e.UpdatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETDATE()");

            // Enrollments Relationship
            builder.HasMany(e => e.Enrollments)
                .WithOne(en => en.Event)
                .HasForeignKey(en => en.EventId)
                .OnDelete(DeleteBehavior.Cascade);

            // ✅ PartnershipEvents Relationship - جديد
            builder.HasMany(e => e.PartnershipEvents)
                .WithOne(pe => pe.Event)
                .HasForeignKey(pe => pe.EventId)
                .OnDelete(DeleteBehavior.NoAction); // NoAction to avoid cascade paths

            // Indexes
            builder.HasIndex(e => e.StartDate)
                .HasDatabaseName("IX_Events_StartDate");

            builder.HasIndex(e => e.EventType)
                .HasDatabaseName("IX_Events_EventType");

            builder.HasIndex(e => e.IsPublished)
                .HasDatabaseName("IX_Events_IsPublished");
        }
    }
}