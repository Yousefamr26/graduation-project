using DataAccess.Entities.RoadMap;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.EntitiesConfigurations.RoadMap
{
    public class QuizAttemptConfiguration : IEntityTypeConfiguration<QuizAttempt>
    {
        public void Configure(EntityTypeBuilder<QuizAttempt> builder)
        {
            builder.ToTable("QuizAttempts");

            builder.HasKey(x => x.Id);

            // ================= Properties =================

            builder.Property(x => x.UserId)
                   .IsRequired()
                   .HasMaxLength(450); // مناسب لـ Identity

            builder.Property(x => x.StartedAt)
                   .IsRequired();

            builder.Property(x => x.CompletedAt)
                   .IsRequired(false);

            builder.Property(x => x.Score)
                   .HasDefaultValue(0);

            builder.Property(x => x.IsCompleted)
                   .HasDefaultValue(false);

            // ================= Relationships =================

            builder.HasOne(x => x.Quiz)
                   .WithMany(q => q.Attempts)
                   .HasForeignKey(x => x.QuizId)
                   .OnDelete(DeleteBehavior.Restrict);

            builder.HasMany(x => x.Answers)
                   .WithOne(a => a.Attempt)
                   .HasForeignKey(a => a.AttemptId)
                   .OnDelete(DeleteBehavior.Cascade);

            // ================= Indexes =================

            builder.HasIndex(x => new { x.UserId, x.QuizId, x.IsCompleted });
        }
    }
}