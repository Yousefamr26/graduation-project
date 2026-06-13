using FluentValidation;
using SmartCareerHub.Contracts.Company.CreateRoadmap;
using System.Linq;

public class ProjectRequestValidator : AbstractValidator<ProjectRequest>
{
    private static readonly string[] AllowedDifficulties = { "Easy", "Medium", "Hard" };

    public ProjectRequestValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty()
            .WithMessage("Project Title is required")
            .Length(3, 200)
            .WithMessage("Project Title must be between 3 and 200 characters");

        RuleFor(x => x.Description)
            .MaximumLength(2000)
            .WithMessage("Project Description must not exceed 2000 characters");

        RuleFor(x => x.Difficulty)
            .NotEmpty()
            .Must(d => AllowedDifficulties.Contains(d?.Trim()))
            .WithMessage($"Invalid Project Difficulty. Allowed values: {string.Join(", ", AllowedDifficulties)}");

        RuleFor(x => x.Points)
            .GreaterThan(0)
            .WithMessage("Points must be greater than 0");
    }
}
