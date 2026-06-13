using FluentValidation;
using SmartCareerHub.Contracts.Workshops.Enrollment;

namespace SmartCareerHub.Contracts.Workshops.Validators
{
    public class EnrollWorkshopRequestValidator
        : AbstractValidator<EnrollWorkshopRequest>
    {
        public EnrollWorkshopRequestValidator()
        {
            RuleFor(x => x.WorkshopId)
                .GreaterThan(0)
                .WithMessage("WorkshopId is required");
        }
    }
}
