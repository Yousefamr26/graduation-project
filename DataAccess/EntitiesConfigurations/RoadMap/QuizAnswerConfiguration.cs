using DataAccess.Entities.RoadMap;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.EntitiesConfigurations.RoadMap
{
    public class QuizAnswerConfiguration : IEntityTypeConfiguration<QuizAnswer>
    {
        public void Configure(EntityTypeBuilder<QuizAnswer> builder)
        {
            builder.ToTable("QuizAnswers");

            builder.HasKey(x => x.Id);

            builder.Property(x => x.AnswerText)
                   .HasMaxLength(2000)
                   .IsRequired(false);

            builder.Property(x => x.FileUrl)
                   .HasMaxLength(500)
                   .IsRequired(false);

            builder.HasOne(x => x.Quiz)
                   .WithMany()
                   .HasForeignKey(x => x.QuizId)
                   .OnDelete(DeleteBehavior.Cascade);

            builder.HasOne(x => x.Question)
                   .WithMany(q => q.Answers)
                   .HasForeignKey(x => x.QuestionId)
                   .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
