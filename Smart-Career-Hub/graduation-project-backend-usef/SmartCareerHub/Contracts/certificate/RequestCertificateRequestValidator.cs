using FluentValidation;

public class RequestCertificateRequestValidator : AbstractValidator<RequestCertificateRequest>
{
    public RequestCertificateRequestValidator()
    {
        RuleFor(x => x.RoadmapId)
            .GreaterThan(0)
            .WithMessage("RoadmapId must be greater than 0");
    }
}