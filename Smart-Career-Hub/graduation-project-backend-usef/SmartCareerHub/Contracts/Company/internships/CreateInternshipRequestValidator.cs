using FluentValidation;

public class CreateInternshipRequestValidator
    : AbstractValidator<CreateInternshipRequest>
{
    public CreateInternshipRequestValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty()
            .MaximumLength(200);

        RuleFor(x => x.Type)
            .IsInEnum();

        RuleFor(x => x.MaxTrainees)
            .GreaterThan(0);

        RuleFor(x => x.DurationInMonths)
            .GreaterThan(0)
            .LessThanOrEqualTo(24);

        RuleFor(x => x.ApplicationDeadline)
            .GreaterThan(DateTime.UtcNow);

        RuleFor(x => x.Location)
            .NotEmpty()
            .MaximumLength(200);

        RuleFor(x => x.Description)
            .NotEmpty()
            .MaximumLength(2000);

        RuleFor(x => x.RequiredSkills)
            .NotEmpty();

        RuleForEach(x => x.RequiredSkills)
            .NotEmpty()
            .MaximumLength(100);

        RuleFor(x => x.Requirements)
            .NotEmpty();

        RuleForEach(x => x.Requirements)
            .NotEmpty()
            .MaximumLength(200);
    }
}
