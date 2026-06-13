using FluentValidation;
using Microsoft.AspNetCore.Http;
using SmartCareerHub.Contracts.Auth;
using System;
using System.IO;
using System.Linq;

namespace SmartCareerHub.Validators.Student
{
    public class StudentRegisterRequestValidator : AbstractValidator<RegisterStudentRequest>
    {
        private const long MaxProfileImageSize = 5 * 1024 * 1024;

        public StudentRegisterRequestValidator()
        {
            RuleFor(x => x.Email)
                .NotEmpty().WithMessage("Email is required.")
                .EmailAddress().WithMessage("Invalid email address.")
                .MaximumLength(256).WithMessage("Email must not exceed 256 characters.");

            RuleFor(x => x.Password)
                .NotEmpty().WithMessage("Password is required.")
                .MinimumLength(8).WithMessage("Password must be at least 8 characters.")
                .MaximumLength(100).WithMessage("Password must not exceed 100 characters.")
                .Matches("[A-Z]").WithMessage("Password must contain at least one uppercase letter.")
                .Matches("[a-z]").WithMessage("Password must contain at least one lowercase letter.")
                .Matches("[0-9]").WithMessage("Password must contain at least one number.")
                .Matches("[^a-zA-Z0-9]").WithMessage("Password must contain at least one special character.");

            RuleFor(x => x.FirstName)
                .NotEmpty().WithMessage("First name is required.")
                .MaximumLength(100).WithMessage("First name must not exceed 100 characters.")
                .Matches(@"^[a-zA-Z\s]+$").WithMessage("First name must contain letters only.");

            RuleFor(x => x.LastName)
                .NotEmpty().WithMessage("Last name is required.")
                .MaximumLength(100).WithMessage("Last name must not exceed 100 characters.")
                .Matches(@"^[a-zA-Z\s]+$").WithMessage("Last name must contain letters only.");

            RuleFor(x => x.University)
                .NotEmpty().WithMessage("University is required.")
                .MaximumLength(150).WithMessage("University must not exceed 150 characters.");

            RuleFor(x => x.Faculty)
                .NotEmpty().WithMessage("Faculty is required.")
                .MaximumLength(150).WithMessage("Faculty must not exceed 150 characters.");

            RuleFor(x => x.Major)
                .NotEmpty().WithMessage("Major is required.")
                .MaximumLength(100).WithMessage("Major must not exceed 100 characters.");

            RuleFor(x => x.Degree)
                .NotEmpty().WithMessage("Degree is required.")
                .MaximumLength(50).WithMessage("Degree must not exceed 50 characters.");

            RuleFor(x => x.ExpectedGraduation)
                .GreaterThan(DateTime.Now.AddYears(-10))
                    .WithMessage("Expected graduation cannot be more than 10 years in the past.")
                .LessThanOrEqualTo(DateTime.Now.AddYears(10))
                    .WithMessage("Expected graduation must be within 10 years from now.");

            RuleFor(x => x.LinkedIn)
                .MaximumLength(300).WithMessage("LinkedIn URL must not exceed 300 characters.")
                .Matches(@"^https?://(www\.)?linkedin\.com/.*$").WithMessage("LinkedIn must be a valid LinkedIn URL.")
                .When(x => !string.IsNullOrEmpty(x.LinkedIn));

            RuleFor(x => x.GitHub)
                .MaximumLength(300).WithMessage("GitHub URL must not exceed 300 characters.")
                .Matches(@"^https?://(www\.)?github\.com/.*$").WithMessage("GitHub must be a valid GitHub URL.")
                .When(x => !string.IsNullOrEmpty(x.GitHub));

            RuleFor(x => x.Portfolio)
                .MaximumLength(300).WithMessage("Portfolio URL must not exceed 300 characters.")
                .Matches(@"^https?://.*$").WithMessage("Portfolio must be a valid URL starting with http or https.")
                .When(x => !string.IsNullOrEmpty(x.Portfolio));

            RuleFor(x => x.City)
                .NotEmpty().WithMessage("City is required.")
                .MaximumLength(100).WithMessage("City must not exceed 100 characters.")
                .Matches(@"^[a-zA-Z\s]+$").WithMessage("City must contain letters only.");

            RuleFor(x => x.Country)
                .NotEmpty().WithMessage("Country is required.")
                .MaximumLength(100).WithMessage("Country must not exceed 100 characters.")
                .Matches(@"^[a-zA-Z\s]+$").WithMessage("Country must contain letters only.");

            RuleFor(x => x.ProfileImage)
                .Must(BeAValidImage).WithMessage("Profile image must be a valid image file (jpg, jpeg, png, gif).")
                .Must(BeUnderMaxSize).WithMessage("Profile image size must not exceed 5MB.")
                .When(x => x.ProfileImage != null);
        }

        private bool BeAValidImage(IFormFile file)
        {
            if (file == null) return true;
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif" };
            var ext = Path.GetExtension(file.FileName).ToLower();
            return allowedExtensions.Contains(ext);
        }

        private bool BeUnderMaxSize(IFormFile file)
        {
            if (file == null) return true;
            return file.Length <= MaxProfileImageSize;
        }
    }
}