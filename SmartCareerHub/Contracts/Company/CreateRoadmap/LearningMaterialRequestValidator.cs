using DataAccess.Entities.RoadMap;
using FluentValidation;

namespace SmartCareerHub.Contracts.Company.CreateRoadmap
{
    public class LearningMaterialRequestValidator : AbstractValidator<LearningMaterialRequest>
    {
        private const long MaxFileSize = 100 * 1024 * 1024; 
        private const string MaterialTypeVideo = "Video";
        private const string MaterialTypePDF = "PDF";

        public LearningMaterialRequestValidator()
        {
            RuleFor(x => x.Type)
                .NotEmpty()
                .WithMessage("Invalid Material Type");
            RuleFor(x => x.Points)
    .GreaterThan(0)
    .WithMessage("Points must be greater than 0");


            When(x => x.Type == MaterialTypeVideo, () =>
            {
                RuleFor(x => x.TitleVideos)
                    .NotEmpty().WithMessage("Video Title is required for Video materials")
                    .MaximumLength(200).WithMessage("Video Title must not exceed 200 characters");

                RuleFor(x => x.Duration)
                    .NotNull().WithMessage("Duration is required for Video materials");
            });

            When(x => x.Type == MaterialTypePDF, () =>
            {
                RuleFor(x => x.TitlePdf)
                    .NotEmpty().WithMessage("PDF Title is required for PDF materials")
                    .MaximumLength(200).WithMessage("PDF Title must not exceed 200 characters");

                RuleFor(x => x.Durationpdf)
                    .NotNull().WithMessage("Duration is required for PDF materials");
            });

            RuleFor(x => x.FilePath)
                .NotNull().WithMessage("File is required")
                .Must(BeAValidFile).WithMessage("File must be a valid PDF or Video file")
                .Must(BeUnderMaxFileSize).WithMessage("File size must not exceed 100MB");
        }

        private bool BeAValidFile(IFormFile file)
        {
            if (file == null) return false;

            var allowedExtensions = new[] { ".mp4", ".mov", ".avi", ".mkv", ".pdf" };
            var ext = Path.GetExtension(file.FileName).ToLower();

            return allowedExtensions.Contains(ext);
        }

        private bool BeUnderMaxFileSize(IFormFile file)
        {
            if (file == null) return false;
            return file.Length <= MaxFileSize;
        }
    }
}
