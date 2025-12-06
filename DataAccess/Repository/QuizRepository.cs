using DataAccess.Abstractions;
using Business_Logic.Errors;
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

        private bool BeValidType(string type)
        {
            if (string.IsNullOrEmpty(type)) return false;
            var allowedTypes = new[] { "MCQ", "TrueFalse", "EssayFile" };
            return allowedTypes.Contains(type);
        }

        private bool HasQuestions(string type) => type == "MCQ" || type == "TrueFalse";
        private bool HasFile(string type) => type == "EssayFile";

        private QuizzesSec6 MapSafeQuiz(QuizzesSec6 q)
        {
            return new QuizzesSec6
            {
                Id = q.Id,
                Title = q.Title ?? string.Empty,
                Type = BeValidType(q.Type) ? q.Type : string.Empty,
                QuestionsFile = HasFile(q.Type) ? q.QuestionsFile : null,
                Points = q.Points,
                RoadmapId = q.RoadmapId,
                CreatedAt = q.CreatedAt,
                Questions = HasQuestions(q.Type)
                    ? q.Questions?.Select(qq => new Question
                    {
                        Id = qq.Id,
                        QuizId = qq.QuizId,
                        Text = qq.Text ?? string.Empty,
                        Type = qq.Type ?? string.Empty,
                        OptionsJson = qq.OptionsJson ?? string.Empty,
                        CorrectAnswer = qq.CorrectAnswer ?? string.Empty
                    }).ToList() ?? new List<Question>()
                    : new List<Question>()
            };
        }

        public async Task<Result<IEnumerable<QuizzesSec6>>> GetByRoadmapIdAsync(int roadmapId)
        {
            var quizzesFromDb = await _dbSet
                .Where(q => q.RoadmapId == roadmapId)
                .Include(q => q.Questions)
                .ToListAsync();

            if (!quizzesFromDb.Any())
                return Result.Failure<IEnumerable<QuizzesSec6>>(QuizErrors.QuizNotFound);

            var safeQuizzes = quizzesFromDb.Select(MapSafeQuiz);
            return Result.Success(safeQuizzes);
        }

        public async Task<Result<QuizzesSec6>> GetByIdAsync(int quizId)
        {
            var quizFromDb = await _dbSet
                .Include(q => q.Questions)
                .FirstOrDefaultAsync(q => q.Id == quizId);

            if (quizFromDb == null)
                return Result.Failure<QuizzesSec6>(QuizErrors.QuizNotFound);

            return Result.Success(MapSafeQuiz(quizFromDb));
        }

        public async Task<Result<IEnumerable<QuizzesSec6>>> SearchQuizzesAsync(int roadmapId, string searchTerm)
        {
            var quizzesFromDb = await _dbSet
                .Where(q => q.RoadmapId == roadmapId && q.Title != null && q.Title.Contains(searchTerm))
                .Include(q => q.Questions)
                .ToListAsync();

            if (!quizzesFromDb.Any())
                return Result.Failure<IEnumerable<QuizzesSec6>>(QuizErrors.QuizNotFound);

            var safeQuizzes = quizzesFromDb.Select(MapSafeQuiz);
            return Result.Success(safeQuizzes);
        }

        public async Task<Result<QuizzesSec6>> CreateWithQuestionsAsync(QuizzesSec6 quiz, List<Question> questions)
        {
            if (quiz == null)
                return Result.Failure<QuizzesSec6>(QuizErrors.QuizNull);

            if (!HasQuestions(quiz.Type))
                questions = null;

            await _dbSet.AddAsync(quiz);
            if (questions != null && questions.Any())
                await _context.Set<Question>().AddRangeAsync(questions);

            await _context.SaveChangesAsync();
            return Result.Success(quiz);
        }

        public async Task<Result<bool>> UpdateWithQuestionsAsync(QuizzesSec6 quiz, List<Question> questions)
        {
            if (quiz == null)
                return Result.Failure<bool>(QuizErrors.QuizNull);

            _dbSet.Update(quiz);

            if (HasQuestions(quiz.Type) && questions != null && questions.Any())
                _context.Set<Question>().UpdateRange(questions);

            await _context.SaveChangesAsync();
            return Result.Success(true);
        }

        public async Task<Result<bool>> DeleteQuizWithAnswersAsync(int quizId)
        {
            var quiz = await _dbSet.Include(q => q.Questions)
                                   .ThenInclude(q => q.Answers)
                                   .FirstOrDefaultAsync(q => q.Id == quizId);

            if (quiz == null)
                return Result.Failure<bool>(QuizErrors.QuizNotFound);

            if (quiz.Questions != null)
            {
                foreach (var question in quiz.Questions)
                {
                    if (question.Answers != null)
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
            if (!quizzes.Any())
                return Result.Failure<bool>(QuizErrors.QuizBulkNotFound);

            _dbSet.RemoveRange(quizzes);
            await _context.SaveChangesAsync();
            return Result.Success(true);
        }

        public async Task<Result<bool>> BulkUpdateAsync(List<QuizzesSec6> quizzes)
        {
            if (quizzes == null || !quizzes.Any())
                return Result.Failure<bool>(QuizErrors.QuizNoQuestions);

            _dbSet.UpdateRange(quizzes);
            await _context.SaveChangesAsync();
            return Result.Success(true);
        }
    }
}
