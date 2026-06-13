using FluentValidation;
using Microsoft.AspNetCore.Http;
using System.IO;
using System.Linq;

namespace SmartCareerHub.Contracts.Company.WorkShops
{
    public class WorkshopRequestValidator : AbstractValidator<WorkshopRequest>
    {
        private const long MaxBannerSize = 5 * 1024 * 1024; // 5MB

        public WorkshopRequestValidator()
        {
            // Title
            RuleFor(x => x.Title)
                .NotEmpty().WithMessage("Workshop title is required")
                .MaximumLength(200);

            // Description
            RuleFor(x => x.Description)
                .NotEmpty()
                .MaximumLength(2000);

            // Location
            RuleFor(x => x.Location)
                .NotEmpty()
                .MaximumLength(200);

            // Max Capacity
            RuleFor(x => x.MaxCapacity)
                .GreaterThan(0)
                .LessThanOrEqualTo(1000);

            // Workshop Type
            RuleFor(x => x.WorkshopType)
                .NotEmpty()
                .Must(BeValidWorkshopType)
                .WithMessage("WorkshopType must be Online, Onsite, or Hybrid");

            // Banner
            When(x => x.Banner != null, () =>
            {
                RuleFor(x => x.Banner!)
                    .Must(BeAValidImage)
                    .WithMessage("Banner must be jpg, jpeg, or png")
                    .Must(BeUnderMaxBannerSize)
                    .WithMessage("Banner must not exceed 5MB");
            });

            // Materials & Activities
            RuleForEach(x => x.Materials)
                .SetValidator(new MaterialRequestValidator());

            RuleForEach(x => x.Activities)
                .SetValidator(new ActivityRequestValidator());

            // Cross-field rule
            When(x => x.WorkshopType != "Online", () =>
            {
                RuleFor(x => x.RequireRoadmapCompletion)
                    .NotNull()
                    .WithMessage("RequireRoadmapCompletion must be specified for non-online workshops");
            });
        }

        private bool BeValidWorkshopType(string type)
        {
            var validTypes = new[] { "Online", "Onsite", "Hybrid" };
            return validTypes.Contains(type);
        }

        private bool BeAValidImage(IFormFile file)
        {
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png" };
            var ext = Path.GetExtension(file.FileName).ToLower();
            return allowedExtensions.Contains(ext);
        }

        private bool BeUnderMaxBannerSize(IFormFile file)
        {
            return file.Length <= MaxBannerSize;
        }
    }
}