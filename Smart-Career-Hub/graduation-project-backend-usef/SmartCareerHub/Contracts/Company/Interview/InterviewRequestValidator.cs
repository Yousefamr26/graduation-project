using FluentValidation;

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

           

          


            RuleFor(x => x.InterviewType)
                .NotEmpty().WithMessage("Interview type is required")
                .Must(BeValidInterviewType).WithMessage("Interview type must be: Online, On-site, or Hybrid");

          

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