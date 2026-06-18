using FluentValidation;
using SmartCareerHub.Contracts.Events.Enrollment;

public class EventEnrollmentRequestValidator
    : AbstractValidator<EventEnrollmentRequest>
{
    public EventEnrollmentRequestValidator()
    {
        RuleFor(x => x.EventId)
            .GreaterThan(0);

        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress();

        RuleFor(x => x.PhoneNumber)
     .NotEmpty()
     .Matches(@"^01[0125][0-9]{8}$")
     .WithMessage("Phone number must be a valid  number (e.g. 01012345678)");

        RuleFor(x => x.Motivation)
            .MaximumLength(1000);
    }
}
