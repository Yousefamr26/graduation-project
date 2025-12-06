using FluentValidation;
using SmartCareerHub.Contracts.Company.CreateRoadmap;

public class ProjectRequestValidator : AbstractValidator<ProjectRequest>
{
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
            .IsInEnum()
            .WithMessage("Invalid Project Difficulty");
        RuleFor(x => x.Points)
    .GreaterThan(0)
    .WithMessage("Points must be greater than 0");

    }
}
