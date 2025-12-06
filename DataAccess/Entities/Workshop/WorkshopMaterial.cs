using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataAccess.Entities.Workshop
{
    public class WorkshopMaterial
    {
        public int Id { get; set; }

       
        public string Title { get; set; }

       
        public string Type { get; set; } 

        public string? FileUrl { get; set; }

        public int? Duration { get; set; } 
        public int? PageCount { get; set; } 
        public int Points { get; set; }

        public DateTime CreatedAt { get; set; }
        public int WorkshopId { get; set; }
        public WorkshopSec1 Workshop { get; set; }
    }
}
