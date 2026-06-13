using FluentValidation;
using SmartCareerHub.Contracts.Company.CreateRoadmap;

public class QuestionRequestValidator : AbstractValidator<QuestionRequest>
{
    public QuestionRequestValidator()
    {
        RuleFor(x => x.Text)
            .NotEmpty().WithMessage("Question text is required")
            .MaximumLength(1000).WithMessage("Question text cannot exceed 1000 characters");

        RuleFor(x => x.Type)
            .NotEmpty().WithMessage("Question type is required")
            .Must(BeValidType).WithMessage("Invalid question type");

        RuleFor(x => x.OptionsJson)
            .NotEmpty().WithMessage("Options JSON is required")
            .MaximumLength(2000).WithMessage("Options JSON cannot exceed 2000 characters");

        RuleFor(x => x.CorrectAnswer)
            .NotEmpty().WithMessage("Correct answer is required")
            .MaximumLength(500).WithMessage("Correct answer cannot exceed 500 characters");
    }

    private bool BeValidType(string type)
    {
        var allowedTypes = new[] { "MCQ", "Descriptive", "Practical" };
        return allowedTypes.Contains(type);
    }
}
