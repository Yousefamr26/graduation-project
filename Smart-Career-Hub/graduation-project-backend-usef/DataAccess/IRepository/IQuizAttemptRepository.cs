using DataAccess.Abstractions;
using DataAccess.IRepository;

public interface IQuizAttemptRepository : IGenericRepository<QuizAttempt>
{
    Task<Result<QuizAttempt>> GetByIdAsync(int id);
    Task<Result<QuizAttempt?>> GetByUserAndQuizAsync(string userId, int quizId);
    Task<QuizAttempt?> GetByUserIdAndQuizIdAsync(string userId, int quizId);

}