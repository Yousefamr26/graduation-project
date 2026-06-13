using DataAccess.Entities.Job;
using DataAccess.Entities.Partnership;
using DataAccess.Entities.Workshop; // إضافة using للـ Workshop
using System.Text.Json.Serialization;

public class CompanyUser
{
    public string Id { get; set; }
    public string UserId { get; set; }
    public virtual ApplicationUser User { get; set; }
    public string OrganizationName { get; set; }
    public string? OrganizationLogo { get; set; }
    public string Country { get; set; }
    public string City { get; set; }

    [JsonIgnore]
    public virtual ICollection<Job> Jobs { get; set; } = new List<Job>();

    [JsonIgnore]
    public virtual ICollection<Internship> Internships { get; set; } = new List<Internship>();

    // إضافة الـ Workshops
    [JsonIgnore]
    public virtual ICollection<WorkshopSec1> Workshops { get; set; } = new List<WorkshopSec1>();
    [JsonIgnore]
    public virtual ICollection<Partnership>? Partnerships { get; set; }
    public ICollection<Certificate> IssuedCertificates { get; set; }
    = new List<Certificate>();
}