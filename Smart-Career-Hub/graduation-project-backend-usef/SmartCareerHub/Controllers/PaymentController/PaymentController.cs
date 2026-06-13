using DataAccess.Contexts;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Stripe;

[ApiController]
[Route("api/payment")]
public class PaymentController : ControllerBase
{
    private readonly IStripePaymentService _stripeService;
    private readonly ApplicationDbContext _dbContext;
    private readonly IConfiguration _configuration;

    public PaymentController(IStripePaymentService stripeService,
        ApplicationDbContext dbContext,
        IConfiguration configuration)
    {
        _stripeService = stripeService;
        _dbContext = dbContext;
        _configuration = configuration;
    }

    // ===== فقط الطالب والخريج يقدروا يدفعوا =====
    [HttpPost("roadmap")]
    [Authorize(Roles = "Student,Graduate")]
    public async Task<IActionResult> CreateRoadmapPayment([FromBody] PaymentRequest request)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            return Unauthorized("User not identified");

        var roadmap = await _dbContext.RoadmapsSec1.FindAsync(request.RoadmapId);
        if (roadmap == null)
            return NotFound("Roadmap not found");

        if (roadmap.Price <= 0)
            return BadRequest("This roadmap is free or does not have a price set.");

        long amount = (long)(roadmap.Price * 100);
        var clientSecret = await _stripeService.CreateRoadmapPaymentAsync(userId, request.RoadmapId, amount);
        return Ok(new { clientSecret });
    }

    // ===== تحقق إن اليوزر دفع الـ Roadmap ده =====
    [HttpGet("status/{roadmapId}")]
    [Authorize(Roles = "Student,Graduate")]
    public IActionResult GetPaymentStatus(int roadmapId)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            return Unauthorized("User not identified");

        var payment = _dbContext.payments
            .FirstOrDefault(p => p.UserId == userId
                && p.RoadmapId == roadmapId
                && p.Status == "Succeeded");

        return Ok(new { paid = payment != null });
    }

    // ===== Webhook - Stripe بيبعت التأكيد مباشرة =====
    [HttpPost("webhook")]
    [AllowAnonymous]
    public async Task<IActionResult> StripeWebhook()
    {
        var json = await new StreamReader(HttpContext.Request.Body).ReadToEndAsync();

        try
        {
            var stripeEvent = EventUtility.ConstructEvent(
                json,
                Request.Headers["Stripe-Signature"],
                _configuration["Stripe:WebhookSecret"]
            );

            if (stripeEvent.Type == "payment_intent.succeeded")
            {
                var paymentIntent = stripeEvent.Data.Object as PaymentIntent;

                var payment = _dbContext.payments
                    .FirstOrDefault(p => p.StripePaymentId == paymentIntent.Id);

                if (payment != null)
                {
                    payment.Status = "Succeeded";
                    payment.UpdatedAt = DateTime.UtcNow;
                    await _dbContext.SaveChangesAsync();
                }
            }

            return Ok();
        }
        catch (StripeException e)
        {
            return BadRequest(e.Message);
        }
    }
}

public class PaymentRequest
{
    public int RoadmapId { get; set; }
}