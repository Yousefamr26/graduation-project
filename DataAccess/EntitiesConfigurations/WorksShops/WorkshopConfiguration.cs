using DataAccess.Entities.Workshop;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataAccess.EntitiesConfigurations.WorksShops
{
    public class WorkshopConfiguration : IEntityTypeConfiguration<WorkshopSec1>
    {
        public void Configure(EntityTypeBuilder<WorkshopSec1> builder)
        {
            builder.ToTable("Workshops");

            builder.HasKey(w => w.Id);

            builder.Property(w => w.Title)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(w => w.Description)
                .IsRequired()
                .HasColumnType("nvarchar(max)");

            builder.Property(w => w.BannerUrl)
                .HasMaxLength(500);

            builder.Property(w => w.Location)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(w => w.WorkshopType)
                .IsRequired()
                .HasMaxLength(50);

            builder.Property(w => w.MaxCapacity)
                .IsRequired();

            builder.Property(w => w.TotalPoints)
                .HasDefaultValue(0);

            builder.Property(w => w.RequireCV)
                .HasDefaultValue(false);

            builder.Property(w => w.RequireRoadmapCompletion)
                .HasDefaultValue(false);

            builder.Property(w => w.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETDATE()");

            builder.Property(w => w.UpdatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETDATE()");

            
            builder.HasOne(w => w.University)
                .WithMany(u => u.Workshops)
                .HasForeignKey(w => w.UniversityId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasMany(w => w.Materials)
                .WithOne(m => m.Workshop)
                .HasForeignKey(m => m.WorkshopId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasMany(w => w.Activities)
                .WithOne(a => a.Workshop)
                .HasForeignKey(a => a.WorkshopId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
