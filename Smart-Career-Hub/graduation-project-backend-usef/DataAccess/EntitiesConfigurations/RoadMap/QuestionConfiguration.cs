using DataAccess.Entities.RoadMap;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.EntitiesConfigurations.RoadMap
{
    public class QuestionConfiguration : IEntityTypeConfiguration<Question>
    {
        public void Configure(EntityTypeBuilder<Question> builder)
        {
            builder.ToTable("Questions");

            builder.HasKey(x => x.Id);

            builder.Property(x => x.Text)
                   .HasMaxLength(1000)
                   .IsRequired(false);
            builder.Property(x => x.Type)
                   .HasMaxLength(50)
                   .IsRequired(false); 

            builder.Property(x => x.OptionsJson)
                   .HasMaxLength(2000)
                   .IsRequired(false); 
            builder.Property(x => x.CorrectAnswer)
                   .HasMaxLength(500)
                   .IsRequired(false); 

            builder.HasOne(x => x.Quiz)
                   .WithMany(q => q.Questions)
                   .HasForeignKey(x => x.QuizId)
                   .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
