
using DataAccess.Entities.Events;

namespace DataAccess.Entities.Partnership
{
    public class PartnershipEvent
    {
        public int Id { get; set; }
        public int PartnershipId { get; set; }
        public int EventId { get; set; }
        public DateTime CreatedAt { get; set; }

        
        public virtual Partnership? Partnership { get; set; }
        public virtual Event? Event { get; set; }
    }
}