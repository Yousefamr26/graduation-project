using FluentValidation;
using SmartCareerHub.Contracts.Company.CreateRoadmap;
using Microsoft.AspNetCore.Http;
using System.IO;

public class QuizRequestValidator : AbstractValidator<QuizRequest>
{
    private const long MaxFileSize = 5 * 1024 * 1024; // 5MB
    private readonly string[] AllowedExtensions = { ".pdf", ".txt", ".docx" };

    public QuizRequestValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty().WithMessage("Quiz Title is required")
            .Length(3, 200).WithMessage("Quiz Title must be between 3 and 200 characters");

        RuleFor(x => x.Points)
            .GreaterThan(0).WithMessage("Points must be greater than 0");

        RuleFor(x => x.Type)
            .NotEmpty().WithMessage("Quiz Type is required")
            .Must(BeValidType).WithMessage("Invalid Quiz Type");

        RuleFor(x => x.RoadmapId)
            .GreaterThan(0).WithMessage("RoadmapId must be valid");

        RuleFor(x => x.QuestionsFile)
            .NotNull().WithMessage("Questions File is required")
            .Must(BeAllowedExtension).WithMessage("File must be PDF, TXT, or DOCX")
            .Must(BeUnderMaxFileSize).WithMessage("File size must not exceed 5MB");
    }

    private bool BeValidType(string type)
    {
        // أنواع الكويزات الممكنة
        var allowedTypes = new[] { "MCQ", "Descriptive", "Practical" };
        return allowedTypes.Contains(type);
    }

    private bool BeAllowedExtension(IFormFile file)
    {
        if (file == null) return false;
        var ext = Path.GetExtension(file.FileName).ToLower();
        return AllowedExtensions.Contains(ext);
    }

    private bool BeUnderMaxFileSize(IFormFile file)
    {
        if (file == null) return false;
        return file.Length <= MaxFileSize;
    }
}
