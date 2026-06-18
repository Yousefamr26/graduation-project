using FluentValidation;
using Microsoft.AspNetCore.Http;
using System;
using System.IO;
using System.Linq;

namespace SmartCareerHub.Contracts.Company.CreateRoadmap
{
    public class RoadmapRequestValidator : AbstractValidator<RoadmapRequest>
    {
        private static readonly string[] AllowedImageExtensions = { ".jpg", ".jpeg", ".png", ".gif" };
        private const long MaxImageSize = 5 * 1024 * 1024;

        public RoadmapRequestValidator()
        {
          

            RuleFor(x => x.Title)
                .NotEmpty()
                    .WithMessage("Title is required")
                .Length(3, 200)
                    .WithMessage("Title must be between 3 and 200 characters");

            RuleFor(x => x.Description)
                .MaximumLength(2000)
                    .WithMessage("Description must not exceed 2000 characters");

            RuleFor(x => x.TargetRole)
                .IsInEnum()
                    .WithMessage("Invalid Target Role");

            RuleFor(x => x.CoverImage)
                .Must(BeAValidImage)
                    .When(x => x.CoverImage != null)
                    .WithMessage("Cover Image must be a valid image file (jpg, jpeg, png, gif)")
                .Must(BeUnderMaxSize)
                    .When(x => x.CoverImage != null)
                    .WithMessage("Cover Image size must not exceed 5MB");

            RuleFor(x => x.StartDate)
                .GreaterThanOrEqualTo(DateTime.Today)
                    .When(x => x.StartDate.HasValue)
                    .WithMessage("Start Date must be today or in the future");

            RuleFor(x => x.EndDate)
                .GreaterThan(DateTime.Today)
                    .When(x => x.EndDate.HasValue)
                    .WithMessage("End Date must be in the future");

            RuleFor(x => x)
                .Must(HasValidDates)
                    .WithName(nameof(RoadmapRequest.EndDate))
                    .WithMessage("EndDate must be greater than StartDate");

        

            RuleForEach(x => x.SkillRequests)
                .SetValidator(new RequiredSkillRequestValidator());

         

            RuleForEach(x => x.LearningMaterialRequests)
                .SetValidator(new LearningMaterialRequestValidator());

           
            RuleForEach(x => x.ProjectRequests)
                .SetValidator(new ProjectRequestValidator());

          

            RuleForEach(x => x.QuizRequests)
                .SetValidator(new QuizRequestValidator());
        }

        private bool BeAValidImage(IFormFile? file)
        {
            if (file == null) return false;
            var ext = Path.GetExtension(file.FileName).ToLower();
            return AllowedImageExtensions.Contains(ext);
        }

        private bool BeUnderMaxSize(IFormFile? file)
        {
            if (file == null) return false;
            return file.Length <= MaxImageSize;
        }

        private bool HasValidDates(RoadmapRequest req)
        {
            if (!req.StartDate.HasValue || !req.EndDate.HasValue)
                return true;
            return req.EndDate > req.StartDate;
        }
    }
}