using DataAccess.Entities.RoadMap;
using System;

namespace SmartCareerHub.Entities
{
    public class Payment
    {
        public int Id { get; set; } // Primary Key

        public string UserId { get; set; } // FK ل ApplicationUser
        public int RoadmapId { get; set; } // FK ل Roadmap

        public long Amount { get; set; } // بالمئة (مثلاً 10000 = $100)
        public string Status { get; set; } // Pending / Succeeded / Failed
        public string StripePaymentId { get; set; } // رقم العملية في Stripe
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        // Navigation properties
        public virtual ApplicationUser User { get; set; }
        public virtual RoadmapSec1 Roadmap { get; set; }
    }
}