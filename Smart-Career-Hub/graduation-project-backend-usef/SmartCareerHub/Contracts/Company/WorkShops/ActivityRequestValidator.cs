using FluentValidation;

namespace SmartCareerHub.Contracts.Company.WorkShops
{
    public class ActivityRequestValidator : AbstractValidator<ActivityRequest>
    {
        public ActivityRequestValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty().WithMessage("Activity name is required")
                .MaximumLength(200).WithMessage("Activity name must not exceed 200 characters");

            RuleFor(x => x.Description)
                .NotEmpty().WithMessage("Description is required")
                .MaximumLength(1000).WithMessage("Description must not exceed 1000 characters");

            RuleFor(x => x.Difficulty)
                .NotEmpty().WithMessage("Difficulty is required")
                .Must(BeValidDifficulty).WithMessage("Difficulty must be Easy, Medium, or Hard");

            RuleFor(x => x.Points)
                .GreaterThan(0).WithMessage("Points must be greater than 0")
                .LessThanOrEqualTo(100).WithMessage("Points must not exceed 100");
        }

        private bool BeValidDifficulty(string difficulty)
        {
            var validDifficulties = new[] { "Easy", "Medium", "Hard" };
            return validDifficulties.Contains(difficulty);
        }
    }

}
