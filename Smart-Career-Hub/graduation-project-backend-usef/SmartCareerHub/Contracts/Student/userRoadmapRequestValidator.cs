using FluentValidation;

namespace Business_Logic.Validators
{
    public class userRoadmapRequestValidator : AbstractValidator<userRoadmapRequest>
    {
        public userRoadmapRequestValidator()
        {
          

            RuleFor(x => x.RoadmapId)
                .GreaterThan(0)
                .WithMessage("RoadmapId must be greater than 0.");
        }
    }
}
