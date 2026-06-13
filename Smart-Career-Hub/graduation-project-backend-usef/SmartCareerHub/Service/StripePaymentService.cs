using DataAccess.Contexts;
using SmartCareerHub.Entities;
using Stripe;

public class StripePaymentService : IStripePaymentService
{
    private readonly ApplicationDbContext _dbContext;

    public StripePaymentService(ApplicationDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<string> CreateRoadmapPaymentAsync(string userId, int roadmapId, long amount)
    {
        var options = new PaymentIntentCreateOptions
        {
            Amount = amount,
            Currency = "usd",
            PaymentMethodTypes = new List<string> { "card" },
            Metadata = new Dictionary<string, string>
            {
                { "UserId", userId },
                { "RoadmapId", roadmapId.ToString() }
            }
        };

        var service = new PaymentIntentService();
        var paymentIntent = await service.CreateAsync(options);

        // حفظ العملية في DB
        var payment = new Payment
        {
            UserId = userId,
            RoadmapId = roadmapId,
            Amount = amount,
            Status = "Pending",
            StripePaymentId = paymentIntent.Id,
            CreatedAt = DateTime.UtcNow
        };
        _dbContext.payments.Add(payment);
        await _dbContext.SaveChangesAsync();

        return paymentIntent.ClientSecret;
    }
}