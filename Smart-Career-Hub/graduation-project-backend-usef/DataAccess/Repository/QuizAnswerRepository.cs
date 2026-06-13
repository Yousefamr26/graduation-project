using DataAccess.Abstractions;
using DataAccess.Contexts;
using DataAccess.IRepository;
using Microsoft.EntityFrameworkCore;

namespace DataAccess.Repository
{
    public class QuizAnswerRepository : GenericRepository<QuizAnswer>, IQuizAnswerRepository
    {
        public QuizAnswerRepository(ApplicationDbContext context) : base(context) { }

        public async Task<Result<IEnumerable<QuizAnswer>>> GetByUserAndQuizAsync(string userId, int quizId)
        {
            var answers = await _dbSet
                .Include(a => a.Attempt)
                .Where(a => a.Attempt.UserId == userId && a.Attempt.QuizId == quizId)
                .ToListAsync();

            return answers.Any()
                ? Result.Success(answers.AsEnumerable())
                : Result.Failure<IEnumerable<QuizAnswer>>(new Error("QuizAnswer.NotFound", "لا توجد إجابات لهذا المستخدم في هذا الكويز."));
        }

        public async Task<Result<QuizAnswer?>> GetByAttemptAndQuestionAsync(int attemptId, int questionId)
        {
            var answer = await _dbSet
                .FirstOrDefaultAsync(a => a.AttemptId == attemptId && a.QuestionId == questionId);

            return Result.Success(answer);
        }

        // 🔥 الـ Implementation بتاع ميثود التصحيح
        public async Task<IEnumerable<QuizAnswer>> GetAnswersWithQuestionsAsync(int attemptId)
        {
            return await _dbSet
                .Include(a => a.Question) // مهم جداً عشان نجيب الـ CorrectAnswer
                .Where(a => a.AttemptId == attemptId)
                .ToListAsync();
        }
    }
}