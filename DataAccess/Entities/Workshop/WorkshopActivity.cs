using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataAccess.Entities.Workshop
{
    public class WorkshopActivity
    {
        public int Id { get; set; }

        public string Name { get; set; }
        public string Description { get; set; }
        public string Difficulty { get; set; } 
        public int Points { get; set; }
        public DateTime CreatedAt { get; set; }
        public int WorkshopId { get; set; }
        public WorkshopSec1 Workshop { get; set; }
    }
}
