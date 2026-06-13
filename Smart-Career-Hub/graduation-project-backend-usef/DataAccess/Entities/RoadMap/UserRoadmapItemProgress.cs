using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataAccess.Entities.RoadMap
{
    public class UserRoadmapItemProgress
    {
        public int Id { get; set; }


        public string UserId { get; set; }
        public ApplicationUser User { get; set; }
        public int RoadmapId { get; set; }

        public int ItemId { get; set; }
        public string ItemType { get; set; } 

        public bool IsCompleted { get; set; }
        public DateTime ? CompletedAt { get; set; } = DateTime.Now;
    }

}
