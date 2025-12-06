// EventRequestValidator.cs
using FluentValidation;
using SmartCareerHub.Contracts.Company.Event;

namespace SmartCareerHub.Contracts.Company.Events
{
    public class EventRequestValidator : AbstractValidator<EventRequest>
    {
        private const long MaxBannerSize = 5 * 1024 * 1024; 

        public EventRequestValidator()
        {
            RuleFor(x => x.Title)
                .NotEmpty().WithMessage("Event title is required")
                .MaximumLength(200).WithMessage("Title must not exceed 200 characters");

            RuleFor(x => x.Description)
                .NotEmpty().WithMessage("Description is required")
                .MaximumLength(2000).WithMessage("Description must not exceed 2000 characters");

            RuleFor(x => x.EventType)
                .NotEmpty().WithMessage("Event type is required")
                .MaximumLength(50).WithMessage("Event type must not exceed 50 characters");

            RuleFor(x => x.Mode)
                .NotEmpty().WithMessage("Mode is required")
                .Must(BeValidMode).WithMessage("Mode must be Online, Onsite, or Hybrid");

            RuleFor(x => x.StartDate)
                .NotEmpty().WithMessage("Start date is required")
                .GreaterThan(DateTime.Now).WithMessage("Start date must be in the future");

            When(x => x.EndDate.HasValue, () =>
            {
                RuleFor(x => x.EndDate)
                    .GreaterThanOrEqualTo(x => x.StartDate)
                    .WithMessage("End date must be after or equal to start date");
            });

            RuleFor(x => x.StartTime)
                .NotEmpty().WithMessage("Start time is required");

            When(x => x.EndTime.HasValue && x.EndDate.HasValue && x.EndDate == x.StartDate, () =>
            {
                RuleFor(x => x.EndTime)
                    .GreaterThan(x => x.StartTime)
                    .WithMessage("End time must be after start time");
            });

            RuleFor(x => x.MinimumRequiredPoints)
                .GreaterThanOrEqualTo(0).WithMessage("Minimum required points must be 0 or greater")
                .LessThanOrEqualTo(10000).WithMessage("Minimum required points must not exceed 10000");

            RuleFor(x => x.MaxCapacity)
                .GreaterThan(0).WithMessage("Max capacity must be greater than 0")
                .LessThanOrEqualTo(10000).WithMessage("Max capacity must not exceed 10000");

            RuleFor(x => x.PointsForAttendance)
                .GreaterThanOrEqualTo(0).WithMessage("Points for attendance must be 0 or greater")
                .LessThanOrEqualTo(1000).WithMessage("Points for attendance must not exceed 1000");

            RuleFor(x => x.PointsForFullParticipation)
                .GreaterThanOrEqualTo(0).WithMessage("Points for full participation must be 0 or greater")
                .LessThanOrEqualTo(1000).WithMessage("Points for full participation must not exceed 1000")
                .GreaterThanOrEqualTo(x => x.PointsForAttendance)
                .WithMessage("Points for full participation must be greater than or equal to points for attendance");

            RuleFor(x => x.IsPublished)
                .NotNull().WithMessage("IsPublished status is required");

            When(x => x.Banner != null, () =>
            {
                RuleFor(x => x.Banner)
                    .Must(BeAValidImage).WithMessage("Banner must be a valid image file (jpg, jpeg, png)")
                    .Must(BeUnderMaxBannerSize).WithMessage("Banner size must not exceed 5MB");
            });
        }

        private bool BeValidMode(string mode)
        {
            var validModes = new[] { "Online", "Onsite", "Hybrid" };
            return validModes.Contains(mode);
        }

        private bool BeAValidImage(IFormFile file)
        {
            if (file == null) return false;

            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png" };
            var ext = Path.GetExtension(file.FileName).ToLower();
            return allowedExtensions.Contains(ext);
        }

        private bool BeUnderMaxBannerSize(IFormFile file)
        {
            if (file == null) return false;
            return file.Length <= MaxBannerSize;
        }
    }
}