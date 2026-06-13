using System;
using System.Collections.Generic;
using System.Text.Json.Serialization;

public class Internship
{
    public int Id { get; set; }
    public string Title { get; set; }
    public string CompanyId { get; set; }  // FK → CompanyUser.Id
    public bool IsPaid { get; set; }
    public int MaxTrainees { get; set; }
    public InternshipType Type { get; set; } // Enum: OnSite / Remote / Hybrid
    public InternshipStatus Status { get; set; }

    public string Location { get; set; }
    public int DurationInMonths { get; set; }
    public DateTime ApplicationDeadline { get; set; }
    public string Description { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }

    // Navigation
    public virtual CompanyUser Company { get; set; }
    public ICollection<InternshipRequiredSkill> RequiredSkills { get; set; } = new List<InternshipRequiredSkill>();
    public ICollection<InternshipRequirement> Requirements { get; set; } = new List<InternshipRequirement>();
    [JsonIgnore]

    public ICollection<InternshipApplication> Applications { get; set; } = new List<InternshipApplication>();
}
