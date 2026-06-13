using FluentValidation;

public class UploadTemplateRequestValidator : AbstractValidator<UploadTemplateRequest>
{
    public UploadTemplateRequestValidator()
    {
        RuleFor(x => x.TemplateFile)
            .NotNull().WithMessage("Template file is required")
            .Must(x => x.Length > 0).WithMessage("Template file is empty")
            .Must(x => x.Length <= 10 * 1024 * 1024)
            .WithMessage("Template file must be less than 10MB");

        When(x => x.TemplateFile != null, () =>
        {
            RuleFor(x => x.TemplateFile.FileName)
                .Must(HaveValidExtension)
                .WithMessage("Only DOC, DOCX files are allowed");
        });

        RuleFor(x => x.Title)
            .NotEmpty().WithMessage("Title is required")
            .MaximumLength(200).WithMessage("Title max 200 characters");

        RuleFor(x => x.Description)
            .NotEmpty().WithMessage("Description is required")
            .MaximumLength(500).WithMessage("Description max 500 characters");
    }

    private bool HaveValidExtension(string fileName)
    {
        var allowed = new[] { ".doc", ".docx" };
        var extension = Path.GetExtension(fileName).ToLower();
        return allowed.Contains(extension);
    }
}