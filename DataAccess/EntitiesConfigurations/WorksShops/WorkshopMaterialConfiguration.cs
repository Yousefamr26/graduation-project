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
    public class WorkshopMaterialConfiguration : IEntityTypeConfiguration<WorkshopMaterial>
    {
        public void Configure(EntityTypeBuilder<WorkshopMaterial> builder)
        {
            builder.ToTable("WorkshopMaterials");

            builder.HasKey(m => m.Id);

            builder.Property(m => m.Title)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(m => m.Type)
                .IsRequired()
                .HasMaxLength(50);

            builder.Property(m => m.FileUrl)
                .HasMaxLength(500);

            builder.Property(m => m.Duration)
                .IsRequired(false);

            builder.Property(m => m.PageCount)
                .IsRequired(false);

            builder.Property(m => m.Points)
                .HasDefaultValue(0);

            builder.Property(m => m.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETDATE()");

            builder.HasOne(m => m.Workshop)
                .WithMany(w => w.Materials)
                .HasForeignKey(m => m.WorkshopId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
