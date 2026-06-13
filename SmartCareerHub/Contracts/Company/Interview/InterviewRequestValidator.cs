using FluentValidation;
using SmartCareerHub.Contracts.Company.Interview;

namespace Application.Validators.Interviews
{
    public class InterviewRequestValidator : AbstractValidator<InterviewRequest>
    {
        public InterviewRequestValidator()
        {
            RuleFor(x => x.StudentName)
                .NotEmpty().WithMessage("Student name is required")
                .MaximumLength(200).WithMessage("Student name must not exceed 200 characters");

            RuleFor(x => x.RoadmapId)
                .GreaterThan(0).WithMessage("Roadmap ID must be valid");

            RuleFor(x => x.CV)
                .MaximumLength(500).WithMessage("CV link must not exceed 500 characters")
                .When(x => !string.IsNullOrEmpty(x.CV));

            RuleFor(x => x.Date)
                .NotEmpty().WithMessage("Interview date is required")
                .GreaterThan(DateTime.Now.Date).WithMessage("Interview date must be in the future");

            RuleFor(x => x.Time)
                .NotEmpty().WithMessage("Interview time is required");

            RuleFor(x => x.InterviewType)
                .NotEmpty().WithMessage("Interview type is required")
                .Must(BeValidInterviewType).WithMessage("Interview type must be: Online, On-site, or Hybrid");

            RuleFor(x => x.Location)
                .NotEmpty().WithMessage("Location or meeting link is required")
                .MaximumLength(500).WithMessage("Location must not exceed 500 characters");

            RuleFor(x => x.InterviewerName)
                .NotEmpty().WithMessage("Interviewer name is required")
                .MaximumLength(200).WithMessage("Interviewer name must not exceed 200 characters");

            RuleFor(x => x.AdditionalNotes)
                .MaximumLength(1000).WithMessage("Additional notes must not exceed 1000 characters");
        }

        private bool BeValidInterviewType(string type)
        {
            var validTypes = new[] { "Online", "On-site", "Hybrid" };
            return validTypes.Contains(type);
        }
    }
}