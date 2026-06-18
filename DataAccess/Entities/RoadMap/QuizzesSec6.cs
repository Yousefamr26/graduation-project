using System;

namespace DataAccess.Entities.RoadMap
{

    public class QuizzesSec6
    {
        public int Id { get; set; }
        public string? Title { get; set; }  
        public string? Type { get; set; }   
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public string? QuestionsFile { get; set; }
        public int Points { get; set; }
        public int RoadmapId { get; set; }
        public virtual RoadmapSec1 Roadmap { get; set; }
        public virtual ICollection<Question>? Questions { get; set; }

    
   }
}
