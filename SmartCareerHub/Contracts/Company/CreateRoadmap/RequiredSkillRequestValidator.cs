using FluentValidation;

namespace SmartCareerHub.Contracts.Company.CreateRoadmap
{
    public class RequiredSkillRequestValidator : AbstractValidator<RequiredSkillRequest>
    {
        public RequiredSkillRequestValidator()
        {
            RuleFor(x => x.SkillName)
                .NotEmpty()
                .WithMessage("Skill Name is required")
                .Length(2, 150)
                .WithMessage("Skill Name must be between 2 and 150 characters");

            RuleFor(x => x.Level)
                .IsInEnum()
                .WithMessage("Invalid Skill Level");
            RuleFor(x => x.LevelPoints)
    .GreaterThan(0)
    .WithMessage("Level Points must be greater than 0");

        }
    }
}
