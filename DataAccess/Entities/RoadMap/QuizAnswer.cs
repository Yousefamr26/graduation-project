using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataAccess.Entities.RoadMap
{
    public class QuizAnswer
    {
        public int Id { get; set; }
        public int UserId { get; set; }  
        public int QuizId { get; set; }
        public int QuestionId { get; set; }

        public string? AnswerText { get; set; }
        public string? FileUrl { get; set; }

        public virtual QuizzesSec6 Quiz { get; set; }
        public virtual Question Question { get; set; }
    }
}
