namespace SmartCareerHub.Contracts.Student.Roadmaps
{
    public record EnrollRoadmapRequest(
        int RoadmapId
    )
    {
        public string? StripePaymentId { get; set; }
        public string? PaymentStatus { get; set; } // "Succeeded" / "Failed" / null
    }
}