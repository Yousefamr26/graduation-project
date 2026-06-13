using FluentValidation;

namespace SmartCareerHub.Contracts.Company.WorkShops
{
    public class MaterialRequestValidator : AbstractValidator<MaterialRequest>
    {
          private const long MaxFileSize = 100 * 1024 * 1024; 
        private const string MaterialTypeVideo = "Video";
        private const string MaterialTypePDF = "PDF";
        private const string MaterialTypeAssignment = "Assignment";

        public MaterialRequestValidator()
        {
            RuleFor(x => x.Type)
                .NotEmpty()
                .WithMessage("Invalid Material Type");

            RuleFor(x => x.Points)
                .GreaterThan(0)
                .WithMessage("Points must be greater than 0");

            When(x => x.Type == MaterialTypeVideo, () =>
            {
                RuleFor(x => x.TitleVideo)
                    .NotEmpty().WithMessage("Video Title is required for Video materials")
                    .MaximumLength(200).WithMessage("Video Title must not exceed 200 characters");

                RuleFor(x => x.Duration)
                    .NotNull().WithMessage("Duration is required for Video materials")
                    .GreaterThan(0).WithMessage("Duration must be greater than 0");
            });

            When(x => x.Type == MaterialTypePDF, () =>
            {
                RuleFor(x => x.TitlePdf)
                    .NotEmpty().WithMessage("PDF Title is required for PDF materials")
                    .MaximumLength(200).WithMessage("PDF Title must not exceed 200 characters");

                RuleFor(x => x.PageCount)
                    .NotNull().WithMessage("Page count is required for PDF materials")
                    .GreaterThan(0).WithMessage("Page count must be greater than 0");
            });

            When(x => x.Type == MaterialTypeAssignment, () =>
            {
                RuleFor(x => x.TitleAssignment)
                    .NotEmpty().WithMessage("Assignment Title is required for Assignment materials")
                    .MaximumLength(200).WithMessage("Assignment Title must not exceed 200 characters");
            });

            RuleFor(x => x.FilePath)
                .NotNull().WithMessage("File is required")
                .Must(BeAValidFile).WithMessage("File must be a valid PDF, Video, or Document file")
                .Must(BeUnderMaxFileSize).WithMessage("File size must not exceed 100MB");
        }

        private bool BeAValidFile(IFormFile file)
        {
            if (file == null) return false;

            var allowedExtensions = new[] { ".mp4", ".mov", ".avi", ".mkv", ".pdf", ".doc", ".docx" };
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
