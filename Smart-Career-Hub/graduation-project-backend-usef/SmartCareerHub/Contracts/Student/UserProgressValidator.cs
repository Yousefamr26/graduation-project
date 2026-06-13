using FluentValidation;
using Business_Logic.DTOs.StudentProgress;

namespace Business_Logic.Validators
{
    public class UserProgressValidator : AbstractValidator<UserProgressRequest>
    {
        public UserProgressValidator()
        {
            RuleFor(x => x.MaterialId)
                .GreaterThan(0)
                .WithMessage("MaterialId must be greater than 0.");

            RuleFor(x => x.MaterialType)
                .IsInEnum()
                .WithMessage("MaterialType must be a valid value.");

            RuleFor(x => x.PointsEarned)
                .GreaterThanOrEqualTo(0)
                .WithMessage("PointsEarned cannot be negative.")
                .When(x => x.PointsEarned.HasValue);
        }
    }
}
