using FluentValidation;
using Microsoft.AspNetCore.Http;
using System.IO;

namespace SmartCareerHub.Validators.Auth
{
    public class RegisterUniversityRequestValidator : AbstractValidator<UniversityRegisterRequest>
    {
        private const long MaxFileSize = 5 * 1024 * 1024;
        private readonly string[] AllowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif" };

        public RegisterUniversityRequestValidator()
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

            RuleFor(x => x.ConfirmPassword)
                .NotEmpty().WithMessage("Confirm password is required.")
                .Equal(x => x.Password).WithMessage("Passwords do not match.");

            RuleFor(x => x.Name)
                .NotEmpty().WithMessage("Organization name is required.")
                .MinimumLength(2).WithMessage("Organization name must be at least 2 characters.")
                .MaximumLength(200).WithMessage("Organization name must not exceed 200 characters.")
                .Matches(@"^[a-zA-Z0-9\s\-\.\,\&]+$").WithMessage("Organization name contains invalid characters.");

            RuleFor(x => x.PhoneNumber)
                .NotEmpty().WithMessage("Phone number is required.")
                .Matches(@"^01[0125][0-9]{8}$").WithMessage("Phone number must be a valid Egyptian number (e.g. 01012345678).");

            RuleFor(x => x.Country)
                .NotEmpty().WithMessage("Country is required.")
                .MaximumLength(100).WithMessage("Country must not exceed 100 characters.")
                .Matches(@"^[a-zA-Z\s]+$").WithMessage("Country must contain letters only.");

            RuleFor(x => x.City)
                .NotEmpty().WithMessage("City is required.")
                .MaximumLength(100).WithMessage("City must not exceed 100 characters.")
                .Matches(@"^[a-zA-Z\s]+$").WithMessage("City must contain letters only.");

            RuleFor(x => x.OrganizationLogo)
                .Must(BeAValidFile).WithMessage("Logo must be a valid image (.jpg, .jpeg, .png, .gif).")
                .Must(BeUnderMaxFileSize).WithMessage("Logo file size must not exceed 5MB.")
                .When(x => x.OrganizationLogo != null);
        }

        private bool BeAValidFile(IFormFile file)
        {
            if (file == null) return true;
            var ext = Path.GetExtension(file.FileName).ToLower();
            return AllowedExtensions.Contains(ext);
        }

        private bool BeUnderMaxFileSize(IFormFile file)
        {
            if (file == null) return true;
            return file.Length <= MaxFileSize;
        }
    }
}