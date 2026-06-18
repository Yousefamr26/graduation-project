using DataAccess.Abstractions;
using DataAccess.Contexts;
using DataAccess.Repository;
using Microsoft.EntityFrameworkCore;

public class QuizAttemptRepository : GenericRepository<QuizAttempt>, IQuizAttemptRepository
{
    private readonly ApplicationDbContext _context;
    public QuizAttemptRepository(ApplicationDbContext context) : base(context) => _context = context;

    public async Task<Result<QuizAttempt>> GetByIdAsync(int id)
    {
        var attempt = await _context.Set<QuizAttempt>()
            .Include(a => a.Answers)
            .Include(a => a.Quiz)
                .ThenInclude(q => q.Questions)
            .FirstOrDefaultAsync(a => a.Id == id);

        return attempt != null ? Result.Success(attempt) : Result.Failure<QuizAttempt>(new Error("Attempt.NotFound", "Quiz attempt not found"));
    }
    public async Task<Result<QuizAttempt?>> GetByUserAndQuizAsync(string userId, int quizId)
    {
        var attempt = await _context.Set<QuizAttempt>()
            .Include(a => a.Answers)
            .Include(a => a.Quiz)
                .ThenInclude(q => q.Questions)
            .FirstOrDefaultAsync(a => a.UserId == userId && a.QuizId == quizId);

        return attempt != null
            ? Result.Success(attempt)
            : Result.Failure<QuizAttempt?>(new Error("Attempt.NotFound", "Quiz attempt not found"));
    }
    public async Task<QuizAttempt?> GetByUserIdAndQuizIdAsync(string userId, int quizId)
    {
        return await _context.QuizAttempts
            .FirstOrDefaultAsync(a => a.UserId == userId && a.QuizId == quizId && !a.IsCompleted);
    }
}