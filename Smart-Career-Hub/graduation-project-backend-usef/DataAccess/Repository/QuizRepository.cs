using Business_Logic.Errors;
using DataAccess.Abstractions;
using DataAccess.Contexts;
using DataAccess.Entities.RoadMap;
using DataAccess.IRepository;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DataAccess.Repository
{
    public class QuizRepository : GenericRepository<QuizzesSec6>, IQuizRepository
    {
        private readonly ApplicationDbContext _context;

        public QuizRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;
        }

        // ================= GET =================
        public async Task<Result<IEnumerable<QuizzesSec6>>> GetByRoadmapIdAsync(int roadmapId)
        {
            var quizzes = await _dbSet
                .Where(q => q.RoadmapId == roadmapId)
                .Include(q => q.Questions)
                    .ThenInclude(q => q.Answers)
                .Include(q => q.Attempts)
                    .ThenInclude(a => a.Answers)
                .ToListAsync();

            return quizzes.Any()
                ? Result.Success(quizzes.AsEnumerable())
                : Result.Failure<IEnumerable<QuizzesSec6>>(QuizErrors.QuizNotFound);
        }

        public async Task<Result<QuizzesSec6>> GetByIdAsync(int quizId)
        {
            var quiz = await _dbSet
                .Include(q => q.Questions)
                    .ThenInclude(q => q.Answers)
                .Include(q => q.Attempts)
                    .ThenInclude(a => a.Answers)
                .FirstOrDefaultAsync(q => q.Id == quizId);

            return quiz != null
                ? Result.Success(quiz)
                : Result.Failure<QuizzesSec6>(QuizErrors.QuizNotFound);
        }

        public async Task<Result<IEnumerable<QuizzesSec6>>> SearchQuizzesAsync(int roadmapId, string searchTerm)
        {
            var quizzes = await _dbSet
                .Where(q => q.RoadmapId == roadmapId &&
                            q.Title != null &&
                            q.Title.Contains(searchTerm))
                .Include(q => q.Questions)
                    .ThenInclude(q => q.Answers)
                .Include(q => q.Attempts)
                    .ThenInclude(a => a.Answers)
                .ToListAsync();

            return quizzes.Any()
                ? Result.Success(quizzes.AsEnumerable())
                : Result.Failure<IEnumerable<QuizzesSec6>>(QuizErrors.QuizNotFound);
        }

        // ================= CREATE / UPDATE =================
        public async Task<Result<QuizzesSec6>> CreateWithQuestionsAsync(QuizzesSec6 quiz, List<Question> questions)
        {
            if (quiz == null) return Result.Failure<QuizzesSec6>(QuizErrors.QuizNull);

            await _dbSet.AddAsync(quiz);
            await _context.SaveChangesAsync();

            if (questions != null && questions.Any())
            {
                foreach (var q in questions)
                    q.QuizId = quiz.Id;

                await _context.Set<Question>().AddRangeAsync(questions);
                await _context.SaveChangesAsync();

                quiz.Questions = questions;
            }

            return Result.Success(quiz);
        }

        public async Task<Result<bool>> UpdateWithQuestionsAsync(QuizzesSec6 quiz, List<Question> questions)
        {
            if (quiz == null) return Result.Failure<bool>(QuizErrors.QuizNull);

            _dbSet.Update(quiz);

            if (questions != null && questions.Any())
            {
                foreach (var q in questions)
                    q.QuizId = quiz.Id;

                _context.Set<Question>().UpdateRange(questions);
            }

            await _context.SaveChangesAsync();
            return Result.Success(true);
        }

        // ================= DELETE =================
        public async Task<Result<bool>> DeleteQuizWithAnswersAsync(int quizId)
        {
            var quiz = await _dbSet
                .Include(q => q.Questions)
                    .ThenInclude(q => q.Answers)
                .Include(q => q.Attempts)
                    .ThenInclude(a => a.Answers)
                .FirstOrDefaultAsync(q => q.Id == quizId);

            if (quiz == null) return Result.Failure<bool>(QuizErrors.QuizNotFound);

            // حذف الإجابات المرتبطة بالمحاولات
            if (quiz.Attempts != null)
            {
                foreach (var attempt in quiz.Attempts)
                {
                    if (attempt.Answers != null && attempt.Answers.Any())
                        _context.Set<QuizAnswer>().RemoveRange(attempt.Answers);
                }
                _context.Set<QuizAttempt>().RemoveRange(quiz.Attempts);
            }

            // حذف الأسئلة وإجاباتها
            if (quiz.Questions != null)
            {
                foreach (var question in quiz.Questions)
                {
                    if (question.Answers != null && question.Answers.Any())
                        _context.Set<QuizAnswer>().RemoveRange(question.Answers);
                }
                _context.Set<Question>().RemoveRange(quiz.Questions);
            }

            _dbSet.Remove(quiz);
            await _context.SaveChangesAsync();

            return Result.Success(true);
        }

        public async Task<Result<bool>> BulkDeleteAsync(List<int> ids)
        {
            var quizzes = await _dbSet.Where(q => ids.Contains(q.Id)).ToListAsync();
            if (!quizzes.Any()) return Result.Failure<bool>(QuizErrors.QuizBulkNotFound);

            _dbSet.RemoveRange(quizzes);
            await _context.SaveChangesAsync();

            return Result.Success(true);
        }

        public async Task<Result<bool>> BulkUpdateAsync(List<QuizzesSec6> quizzes)
        {
            if (quizzes == null || !quizzes.Any()) return Result.Failure<bool>(QuizErrors.QuizNoQuestions);

            _dbSet.UpdateRange(quizzes);
            await _context.SaveChangesAsync();

            return Result.Success(true);
        }

        // ================= ATTEMPTS =================
        public async Task<Result<QuizAttempt>> CreateAttemptAsync(int quizId, string userId)
        {
            var attempt = new QuizAttempt
            {
                QuizId = quizId,
                UserId = userId,
                StartedAt = System.DateTime.UtcNow,
                IsCompleted = false,
                Score = 0
            };

            await _context.Set<QuizAttempt>().AddAsync(attempt);
            await _context.SaveChangesAsync();

            return Result.Success(attempt);
        }

        public async Task<Result<bool>> SaveAnswersAsync(int attemptId, List<QuizAnswer> answers)
        {
            foreach (var ans in answers)
                ans.AttemptId = attemptId;

            await _context.Set<QuizAnswer>().AddRangeAsync(answers);
            await _context.SaveChangesAsync();

            return Result.Success(true);
        }

        public async Task<Result<QuizAttempt>> CompleteAttemptAsync(int attemptId)
        {
            var attempt = await _context.Set<QuizAttempt>()
                .Include(a => a.Quiz)
                    .ThenInclude(q => q.Questions)
                .Include(a => a.Answers)
                .FirstOrDefaultAsync(a => a.Id == attemptId);

            if (attempt == null)
                return Result.Failure<QuizAttempt>(new Error("Attempt.NotFound", "Quiz attempt not found"));

            // حساب النقاط
            int score = 0;
            foreach (var q in attempt.Quiz.Questions)
            {
                var ans = attempt.Answers.FirstOrDefault(a => a.QuestionId == q.Id);
                if (ans != null && !string.IsNullOrEmpty(ans.AnswerText) && ans.AnswerText.Trim() == q.CorrectAnswer?.Trim())
                    score += 1;
            }

            attempt.Score = score;
            attempt.IsCompleted = true;
            attempt.CompletedAt = System.DateTime.UtcNow;

            _context.Set<QuizAttempt>().Update(attempt);
            await _context.SaveChangesAsync();

            return Result.Success(attempt);
        }
    }
}