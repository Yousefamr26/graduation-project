using Stripe;
using DataAccess.Contexts;
using SmartCareerHub.Entities;

public interface IStripePaymentService
{
    Task<string> CreateRoadmapPaymentAsync(string userId, int roadmapId, long amount);
}


