using FluentValidation;

public class ApplyInternshipRequestValidator
    : AbstractValidator<ApplyInternshipRequest>
{
    public ApplyInternshipRequestValidator()
    {
        RuleFor(x => x.InternshipId)
            .GreaterThan(0);
    }
}
