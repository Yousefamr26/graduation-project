using FluentValidation;
using System.Linq;

namespace SmartCareerHub.Contracts.Company.CreateRoadmap
{
    public class RequiredSkillRequestValidator : AbstractValidator<RequiredSkillRequest>
    {
        // لو الـ Level string، حدد القيم المسموح بها
        private static readonly string[] AllowedLevels = { "Beginner", "Intermediate", "Advanced" };

        public RequiredSkillRequestValidator()
        {
            // التحقق من اسم المهارة
            RuleFor(x => x.SkillName)
                .NotEmpty()
                .WithMessage("Skill Name is required")
                .Length(2, 150)
                .WithMessage("Skill Name must be between 2 and 150 characters");

            // التحقق من مستوى المهارة
            RuleFor(x => x.Level)
                .NotEmpty()
                .Must(l => AllowedLevels.Contains(l?.Trim()))
                .WithMessage($"Invalid Skill Level. Allowed values: {string.Join(", ", AllowedLevels)}");

            // التحقق من نقاط المستوى
            RuleFor(x => x.LevelPoints)
                .GreaterThan(0)
                .WithMessage("Level Points must be greater than 0");
        }
    }
}
