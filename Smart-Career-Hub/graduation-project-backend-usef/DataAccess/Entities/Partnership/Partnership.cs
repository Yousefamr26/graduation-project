
using Microsoft.AspNetCore.Identity;
using DataAccess.Entities.User;

namespace DataAccess.Entities.Partnership
{
    public class Partnership
    {
        public int Id { get; set; }
        public int UniversityId { get; set; }
        public string CompanyId { get; set; } = string.Empty;
        public string PartnershipType { get; set; } = string.Empty;

        // Company Info
        public string CompanyName { get; set; } = string.Empty;
        public string Phone { get; set; }
        public string? IndustryField { get; set; }
        public string? ContactPersonName { get; set; }
        public string? ContactEmail { get; set; }
        public string? Website { get; set; }
        public string? Location { get; set; }

        // Partnership Details
        public string? PartnershipDetails { get; set; }
        public DateTime StartDate { get; set; }
        public string Status { get; set; } = "Pending"; // Active, Pending, Inactive

        // Stats
        public int EventsHosted { get; set; } = 0;
        public int StudentsReached { get; set; } = 0;

        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }

        // Navigation Properties
        public virtual University? University { get; set; }
        public virtual CompanyUser? Company { get; set; }
        public virtual ICollection<PartnershipEvent>? PartnershipEvents { get; set; }
    }
}