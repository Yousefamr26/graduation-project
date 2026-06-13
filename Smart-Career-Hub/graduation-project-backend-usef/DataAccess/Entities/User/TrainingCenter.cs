using DataAccess.Entities.Workshop;
using System.Text.Json.Serialization;

namespace DataAccess.Entities.User
{
    public class TrainingCenter
    {
        public int Id { get; set; }
        public string UserId { get; set; }      // FK
        public virtual ApplicationUser User { get; set; }
        public string? OrganizationLogo { get; set; }
        public string Name { get; set; }
        public string? City { get; set; }
        public string? Country { get; set; }
        public DateTime CreatedAt { get; set; }
        public ICollection<WorkshopSec1> Workshops { get; set; }
        [JsonIgnore]
        public virtual ICollection<Partnership.Partnership>? Partnerships { get; set; }
    }
}