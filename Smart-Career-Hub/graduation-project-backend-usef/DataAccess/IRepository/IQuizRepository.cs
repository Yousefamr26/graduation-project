using DataAccess.Abstractions;
using DataAccess.Entities.RoadMap;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DataAccess.IRepository
{
    public interface IQuizRepository : IGenericRepository<QuizzesSec6>
    {
        // ===== GET =====
        Task<Result<QuizzesSec6>> GetByIdAsync(int quizId);
        Task<Result<IEnumerable<QuizzesSec6>>> GetByRoadmapIdAsync(int roadmapId);
        Task<Result<IEnumerable<QuizzesSec6>>> SearchQuizzesAsync(int roadmapId, string searchTerm);

        // ===== CREATE / UPDATE =====
        Task<Result<QuizzesSec6>> CreateWithQuestionsAsync(QuizzesSec6 quiz, List<Question> questions);
        Task<Result<bool>> UpdateWithQuestionsAsync(QuizzesSec6 quiz, List<Question> questions);

        // ===== DELETE =====
        Task<Result<bool>> DeleteQuizWithAnswersAsync(int quizId);
        Task<Result<bool>> BulkDeleteAsync(List<int> ids);
        Task<Result<bool>> BulkUpdateAsync(List<QuizzesSec6> quizzes);

        // ===== ATTEMPTS =====
        Task<Result<QuizAttempt>> CreateAttemptAsync(int quizId, string userId);
        Task<Result<bool>> SaveAnswersAsync(int attemptId, List<QuizAnswer> answers);
        Task<Result<QuizAttempt>> CompleteAttemptAsync(int attemptId);
    }
}