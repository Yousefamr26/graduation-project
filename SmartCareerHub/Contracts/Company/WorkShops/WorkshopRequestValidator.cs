using FluentValidation;

namespace SmartCareerHub.Contracts.Company.WorkShops
{
    public class WorkshopRequestValidator:AbstractValidator<WorkshopRequest>
    {
        private const long MaxBannerSize = 5 * 1024 * 1024;
        public WorkshopRequestValidator()
        {
            RuleFor(x => x.Title)
               .NotEmpty().WithMessage("Workshop title is required")
               .MaximumLength(200).WithMessage("Title must not exceed 200 characters");

            RuleFor(x => x.Description)
                .NotEmpty().WithMessage("Description is required")
                .MaximumLength(2000).WithMessage("Description must not exceed 2000 characters");

            RuleFor(x => x.UniversityId)
                .GreaterThan(0).WithMessage("Please select a valid university");

            RuleFor(x => x.Location)
                .NotEmpty().WithMessage("Location is required")
                .MaximumLength(200).WithMessage("Location must not exceed 200 characters");

            RuleFor(x => x.MaxCapacity)
                .GreaterThan(0).WithMessage("Max capacity must be greater than 0")
                .LessThanOrEqualTo(1000).WithMessage("Max capacity must not exceed 1000");

            RuleFor(x => x.WorkshopType)
                .NotEmpty().WithMessage("Workshop type is required")
                .Must(BeValidWorkshopType).WithMessage("Workshop type must be Online, Onsite, or Hybrid");
            RuleFor(x => x.IsPublished)
                .NotNull().WithMessage("IsPublished status is required");
            When(x => x.Banner != null, () =>
            {
                RuleFor(x => x.Banner)
                    .Must(BeAValidImage).WithMessage("Banner must be a valid image file (jpg, jpeg, png)")
                    .Must(BeUnderMaxBannerSize).WithMessage("Banner size must not exceed 5MB");
            });

            RuleForEach(x => x.Materials)
                .SetValidator(new MaterialRequestValidator());

            RuleForEach(x => x.Activities)
                .SetValidator(new ActivityRequestValidator());
        }

        private bool BeValidWorkshopType(string type)
        {
            var validTypes = new[] { "Online", "Onsite", "Hybrid" };
            return validTypes.Contains(type);
        }

        private bool BeAValidImage(IFormFile file)
        {
            if (file == null) return false;

            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png" };
            var ext = Path.GetExtension(file.FileName).ToLower();
            return allowedExtensions.Contains(ext);
        }

        private bool BeUnderMaxBannerSize(IFormFile file)
        {
            if (file == null) return false;
            return file.Length <= MaxBannerSize;
        }


    }


}

