using FluentValidation;

public class CreatePartnershipRequestValidator
    : AbstractValidator<CreatePartnershipRequest>
{
    public CreatePartnershipRequestValidator()
    {
        RuleFor(x => x.CompanyName)
            .NotEmpty().WithMessage("Company name is required")
            .MaximumLength(100).WithMessage("Company name cannot exceed 100 characters");

        RuleFor(x => x.Industry)
            .NotEmpty().WithMessage("Industry is required")
            .MaximumLength(50);

        RuleFor(x => x.PartnershipType)
            .NotEmpty().WithMessage("Partnership type is required");

        RuleFor(x => x.ContactPerson)
            .NotEmpty().WithMessage("Contact person is required")
            .MaximumLength(50);

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email is required")
            .EmailAddress().WithMessage("Invalid email format");

        RuleFor(x => x.Phone)
            .NotEmpty().WithMessage("Phone number is required")
            .Matches(@"^\+?\d{7,15}$").WithMessage("Invalid phone number format");

        RuleFor(x => x.Website)
            .NotEmpty().WithMessage("Website is required")
            .Must(x => Uri.IsWellFormedUriString(x, UriKind.Absolute))
            .WithMessage("Invalid website URL");

        RuleFor(x => x.Location)
            .NotEmpty().WithMessage("Location is required");

        RuleFor(x => x.Details)
            .NotEmpty().WithMessage("Partnership details are required")
            .MaximumLength(500);
    }
}