// DataAccess/Configurations/PartnershipEventConfiguration.cs
using DataAccess.Entities.Partnership;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.Configurations
{
    public class PartnershipEventConfiguration : IEntityTypeConfiguration<PartnershipEvent>
    {
        public void Configure(EntityTypeBuilder<PartnershipEvent> builder)
        {
            builder.ToTable("PartnershipEvents");

            builder.HasKey(pe => pe.Id);

            builder.Property(pe => pe.Id)
                .ValueGeneratedOnAdd();

            builder.Property(pe => pe.PartnershipId)
                .IsRequired();

            builder.Property(pe => pe.EventId)
                .IsRequired();

            builder.Property(pe => pe.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");

            // ========== Relationships ==========

            // PartnershipEvent -> Partnership (Many-to-One)
            builder.HasOne(pe => pe.Partnership)
                .WithMany(p => p.PartnershipEvents)
                .HasForeignKey(pe => pe.PartnershipId)
                .OnDelete(DeleteBehavior.Cascade);

            // PartnershipEvent -> Event (Many-to-One)
            builder.HasOne(pe => pe.Event)
                .WithMany(e => e.PartnershipEvents)
                .HasForeignKey(pe => pe.EventId)
                .OnDelete(DeleteBehavior.NoAction); // NoAction لتجنب cascade paths

            // ========== Indexes ==========

            builder.HasIndex(pe => pe.PartnershipId)
                .HasDatabaseName("IX_PartnershipEvents_PartnershipId");

            builder.HasIndex(pe => pe.EventId)
                .HasDatabaseName("IX_PartnershipEvents_EventId");

            // Unique constraint: منع تكرار ربط نفس Event بنفس Partnership
            builder.HasIndex(pe => new { pe.PartnershipId, pe.EventId })
                .IsUnique()
                .HasDatabaseName("IX_PartnershipEvents_Partnership_Event_Unique");
        }
    }
}