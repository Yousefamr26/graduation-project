using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataAccess.Entities.Workshop
{
    public class University
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string? City { get; set; }
        public string? Country { get; set; }
        public DateTime CreatedAt { get; set; }
        public ICollection<WorkshopSec1> Workshops { get; set; }
    }
}
