
using FluentValidation;
using SmartCareerHub.Contracts.Company.Jobs;

namespace Application.Validators.Jobs
{
    public class JobRequestValidator : AbstractValidator<JobRequest>
    {
        private const long MaxLogoSize = 5 * 1024 * 1024; 

        public JobRequestValidator()
        {
            RuleFor(x => x.Title)
                .NotEmpty().WithMessage("Job title is required")
                .MaximumLength(200).WithMessage("Title must not exceed 200 characters");

            RuleFor(x => x.Description)
                .NotEmpty().WithMessage("Description is required");

            RuleFor(x => x.RequiredSkills)
                .NotEmpty().WithMessage("Required skills are required")
                .MaximumLength(500).WithMessage("Required skills must not exceed 500 characters");

            RuleFor(x => x.ExperienceLevel)
                .NotEmpty().WithMessage("Experience level is required")
                .Must(BeValidExperienceLevel).WithMessage("Experience level must be: Early Level, Mid Level, Senior Level, or Senior Manager");

            RuleFor(x => x.JobType)
                .NotEmpty().WithMessage("Job type is required")
                .Must(BeValidJobType).WithMessage("Job type must be: Remote, On-site, or Hybrid");

            RuleFor(x => x.Location)
                .NotEmpty().WithMessage("Location is required")
                .MaximumLength(200).WithMessage("Location must not exceed 200 characters");

            RuleFor(x => x.SalaryRange)
                .MaximumLength(100).WithMessage("Salary range must not exceed 100 characters");

            When(x => x.CompanyLogo != null, () =>
            {
                RuleFor(x => x.CompanyLogo)
                    .Must(BeAValidImage).WithMessage("Company logo must be a valid image file (jpg, jpeg, png, gif)")
                    .Must(BeUnderMaxLogoSize).WithMessage("Company logo size must not exceed 5MB");
            });
        }

        private bool BeValidExperienceLevel(string level)
        {
            var validLevels = new[] { "Early Level", "Mid Level", "Senior Level", "Senior Manager" };
            return validLevels.Contains(level);
        }

        private bool BeValidJobType(string type)
        {
            var validTypes = new[] { "Remote", "On-site", "Hybrid" };
            return validTypes.Contains(type);
        }

        private bool BeAValidImage(IFormFile file)
        {
            if (file == null) return false;
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif" };
            var ext = Path.GetExtension(file.FileName).ToLower();
            return allowedExtensions.Contains(ext);
        }

        private bool BeUnderMaxLogoSize(IFormFile file)
        {
            if (file == null) return false;
            return file.Length <= MaxLogoSize;
        }
    }
}