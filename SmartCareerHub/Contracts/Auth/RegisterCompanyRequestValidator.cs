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
                .EmailAddress().WithMessage("Invalid email address");

            RuleFor(x => x.Password)
                .NotEmpty().WithMessage("Password is required")
                .MinimumLength(8).WithMessage("Password must be at least 8 characters");

            RuleFor(x => x.FirstName)
                .NotEmpty().WithMessage("First name is required")
                .MaximumLength(100);

            RuleFor(x => x.LastName)
                .NotEmpty().WithMessage("Last name is required")
                .MaximumLength(100);

            RuleFor(x => x.OrganizationName)
                .NotEmpty().WithMessage("Organization name is required")
                .MaximumLength(200);

            RuleFor(x => x.OrganizationLogo)
                .Must(BeAValidFile).WithMessage("Logo must be a valid image (.jpg, .png, .gif)")
                .Must(BeUnderMaxFileSize).WithMessage("Logo file size must not exceed 5MB")
                .When(x => x.OrganizationLogo != null);

            RuleFor(x => x.Country)
                .NotEmpty().WithMessage("Country is required")
                .MaximumLength(100);

            RuleFor(x => x.City)
                .NotEmpty().WithMessage("City is required")
                .MaximumLength(100);
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
