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
    public class WorkshopActivityConfiguration : IEntityTypeConfiguration<WorkshopActivity>
    {
        public void Configure(EntityTypeBuilder<WorkshopActivity> builder)
        {
            builder.ToTable("WorkshopActivities");

            builder.HasKey(a => a.Id);

            builder.Property(a => a.Name)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(a => a.Description)
                .IsRequired()
                .HasColumnType("nvarchar(max)");

            builder.Property(a => a.Difficulty)
                .IsRequired()
                .HasMaxLength(50);

            builder.Property(a => a.Points)
                .IsRequired()
                .HasDefaultValue(10);

            builder.Property(a => a.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETDATE()");

            builder.HasOne(a => a.Workshop)
                .WithMany(w => w.Activities)
                .HasForeignKey(a => a.WorkshopId)
                .OnDelete(DeleteBehavior.Cascade);

        }
    }
}
