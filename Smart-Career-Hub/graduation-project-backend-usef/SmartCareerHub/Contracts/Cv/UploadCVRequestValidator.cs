using FluentValidation;

public class UploadCVRequestValidator : AbstractValidator<UploadCVRequest>
{
    public UploadCVRequestValidator()
    {
        RuleFor(x => x.CV)
            .NotNull().WithMessage("CV file is required")
            .Must(x => x.Length > 0).WithMessage("CV file is empty")
            // ✅ أضف size validation
            .Must(x => x.Length <= 5 * 1024 * 1024)
            .WithMessage("CV file must be less than 5MB");

        // ✅ When بيحميك من null crash
        When(x => x.CV != null, () =>
        {
            RuleFor(x => x.CV.FileName)
                .Must(HaveValidExtension)
                .WithMessage("Only PDF, DOC, DOCX files are allowed");
        });
    }

    private bool HaveValidExtension(string fileName)
    {
        var allowed = new[] { ".pdf", ".doc", ".docx" };
        var extension = Path.GetExtension(fileName).ToLower();
        return allowed.Contains(extension);
    }
}