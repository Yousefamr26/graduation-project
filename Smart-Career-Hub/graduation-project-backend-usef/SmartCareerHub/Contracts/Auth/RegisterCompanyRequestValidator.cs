using FluentValidation;
using SmartCareerHub.Contracts.Auth;
using Microsoft.AspNetCore.Http;
using System.IO;

namespace SmartCareerHub.Validators.Auth
{
    public class RegisterCompanyRequestValidator : AbstractValidator<RegisterCompanyRequest>
    {
        private const long MaxFileSize = 5 * 1024 * 1024; // 5MB
        private readonly string[] AllowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif" };

        public RegisterCompanyRequestValidator()
        {
            RuleFor(x => x.Email)
                .NotEmpty().WithMessage("Email is required")
                .EmailAddress().WithMessage("Invalid email address")
                .MaximumLength(256).WithMessage("Email must not exceed 256 characters");

            RuleFor(x => x.Password)
                .NotEmpty().WithMessage("Password is required")
                .MinimumLength(8).WithMessage("Password must be at least 8 characters")
                .MaximumLength(100).WithMessage("Password must not exceed 100 characters")
                .Matches("[A-Z]").WithMessage("Password must contain at least one uppercase letter")
                .Matches("[a-z]").WithMessage("Password must contain at least one lowercase letter")
                .Matches("[0-9]").WithMessage("Password must contain at least one number")
                .Matches("[^a-zA-Z0-9]").WithMessage("Password must contain at least one special character");

            RuleFor(x => x.FirstName)
                .NotEmpty().WithMessage("First name is required")
                .MaximumLength(100).WithMessage("First name must not exceed 100 characters")
                .Matches(@"^[a-zA-Z\s]+$").WithMessage("First name must contain letters only");

            RuleFor(x => x.LastName)
                .NotEmpty().WithMessage("Last name is required")
                .MaximumLength(100).WithMessage("Last name must not exceed 100 characters")
                .Matches(@"^[a-zA-Z\s]+$").WithMessage("Last name must contain letters only");

            RuleFor(x => x.OrganizationName)
                .NotEmpty().WithMessage("Organization name is required")
                .MinimumLength(2).WithMessage("Organization name must be at least 2 characters")
                .MaximumLength(200).WithMessage("Organization name must not exceed 200 characters")
                .Matches(@"^[a-zA-Z0-9\s\-\.\,\&]+$").WithMessage("Organization name contains invalid characters");

            RuleFor(x => x.OrganizationLogo)
                .Must(BeAValidFile).WithMessage("Logo must be a valid image (.jpg, .jpeg, .png, .gif)")
                .Must(BeUnderMaxFileSize).WithMessage("Logo file size must not exceed 5MB")
                .When(x => x.OrganizationLogo != null);

            RuleFor(x => x.Country)
                .NotEmpty().WithMessage("Country is required")
                .MaximumLength(100).WithMessage("Country must not exceed 100 characters")
                .Matches(@"^[a-zA-Z\s]+$").WithMessage("Country must contain letters only");

            RuleFor(x => x.City)
                .NotEmpty().WithMessage("City is required")
                .MaximumLength(100).WithMessage("City must not exceed 100 characters")
                .Matches(@"^[a-zA-Z\s]+$").WithMessage("City must contain letters only");
        }

        private bool BeAValidFile(IFormFile file)
        {
            if (file == null) return true; // nullable
            var ext = Path.GetExtension(file.FileName).ToLower();
            return AllowedExtensions.Contains(ext);
        }

        private bool BeUnderMaxFileSize(IFormFile file)
        {
            if (file == null) return true; // nullable
            return file.Length <= MaxFileSize;
        }
    }
}
