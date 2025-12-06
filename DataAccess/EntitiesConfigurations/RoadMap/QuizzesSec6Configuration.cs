using DataAccess.Entities.RoadMap;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.EntitiesConfigurations.RoadMap
{
    public class QuizzesSec6Configuration : IEntityTypeConfiguration<QuizzesSec6>
    {
        public void Configure(EntityTypeBuilder<QuizzesSec6> builder)
        {
            builder.ToTable("Quizzes", t =>
            {
                t.HasCheckConstraint("CK_Quizzes_Type",
                    "[Type] IN ('TrueandFalse','Mcq','Mixed')");
            });

            builder.HasKey(x => x.Id);

            builder.Property(x => x.Title)
                   .HasMaxLength(200)
                   .IsRequired(false); 

            builder.Property(x => x.Type)
                   .HasMaxLength(50)
                   .IsRequired(false); 

            builder.Property(x => x.QuestionsFile)
                   .HasMaxLength(500)
                   .IsRequired(false); 

            builder.Property(x => x.CreatedAt)
                   .IsRequired()
                   .HasDefaultValueSql("GETDATE()");

            builder.Property(x => x.Points)
                   .IsRequired()
                   .HasDefaultValue(0);

            builder.Property(x => x.RoadmapId)
                   .IsRequired();

            builder.HasIndex(x => x.RoadmapId);
            builder.HasIndex(x => x.Type);
            builder.HasIndex(x => x.Title);

            builder.HasOne(x => x.Roadmap)
                   .WithMany(x => x.Quizzes)
                   .HasForeignKey(x => x.RoadmapId)
                   .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
