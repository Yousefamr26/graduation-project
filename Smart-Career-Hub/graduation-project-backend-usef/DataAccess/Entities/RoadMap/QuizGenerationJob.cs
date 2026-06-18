using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DataAccess.Entities.RoadMap
{
    public class QuizGenerationJob
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int RoadmapId { get; set; }

        [Required]
        [MaxLength(50)]
        public string QuizType { get; set; } = string.Empty;

        [Required]
        public int NumQuestions { get; set; }

        [Required]
        [MaxLength(20)]
        public string Status { get; set; } = "Pending"; // Pending | Processing | Completed | Failed

        public int? ResultQuizId { get; set; } // FK to Quizzes table
        public string? ErrorMessage { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? StartedAt { get; set; }
        public DateTime? CompletedAt { get; set; }
    }
}