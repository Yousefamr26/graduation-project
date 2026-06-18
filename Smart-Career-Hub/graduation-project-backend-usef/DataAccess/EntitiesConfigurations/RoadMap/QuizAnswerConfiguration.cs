using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

public class QuizAnswerConfiguration : IEntityTypeConfiguration<QuizAnswer>
{
    public void Configure(EntityTypeBuilder<QuizAnswer> builder)
    {
        builder.ToTable("QuizAnswers");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.AnswerText)
               .HasMaxLength(2000)
               .IsRequired(false);

        builder.HasOne(x => x.Question)
               .WithMany(q => q.Answers)
               .HasForeignKey(x => x.QuestionId)
               .OnDelete(DeleteBehavior.Restrict); // ✅

        builder.HasOne(x => x.Attempt)
               .WithMany(a => a.Answers)
               .HasForeignKey(x => x.AttemptId)
               .OnDelete(DeleteBehavior.Cascade); // ✅ يبقى المسار الأساسي للحذف
    }
}