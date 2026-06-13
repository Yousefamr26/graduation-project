using FluentValidation;

public class ProgrammingTrackAnalyzerRequestValidator
    : AbstractValidator<ProgrammingTrackAnalyzerRequest>
{
    public ProgrammingTrackAnalyzerRequestValidator()
    {
        RuleFor(x => x.UserDescription)
            .NotEmpty().WithMessage("User description is required.")
            .MinimumLength(10).WithMessage("User description must be at least 10 characters.")
            .MaximumLength(2000).WithMessage("User description must not exceed 2000 characters.");
    }
}
