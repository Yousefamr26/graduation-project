using DataAccess.Entities.RoadMap;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataAccess.Entities.Interview
{
    public class InterviewSchedule
    {
        public int Id { get; set; }

        public string StudentName { get; set; }      
        public int RoadmapId { get; set; }           
        public RoadmapSec1 Roadmap { get; set; }        
        public string? CV { get; set; }              
        public bool IsAIPick { get; set; }         

        public DateTime Date { get; set; }           
        public TimeSpan Time { get; set; }           
        public string InterviewType { get; set; }  
        public string Location { get; set; }         
        public string InterviewerName { get; set; }  
        public string? AdditionalNotes { get; set; } 

        public string Status { get; set; }           
        public DateTime CreatedAt { get; set; }
    }
}
