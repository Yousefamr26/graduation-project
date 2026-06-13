using DataAccess.Abstractions;

namespace DataAccess.IRepository
{
    public interface IQuizAnswerRepository : IGenericRepository<QuizAnswer>
    {
        Task<Result<IEnumerable<QuizAnswer>>> GetByUserAndQuizAsync(string userId, int quizId);
        Task<Result<QuizAnswer?>> GetByAttemptAndQuestionAsync(int attemptId, int questionId);

        // 🔥 الميثود الجديدة لجلب الإجابات مع بيانات الأسئلة (عشان التصحيح)
        Task<IEnumerable<QuizAnswer>> GetAnswersWithQuestionsAsync(int attemptId);
    }
}