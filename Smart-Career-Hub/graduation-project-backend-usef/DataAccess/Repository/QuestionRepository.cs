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
    public class QuestionRepository : GenericRepository<Question>, IQuestionRepository
    {
        private readonly ApplicationDbContext _context;

        public QuestionRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;
        }

        public async Task<Result<Question>> GetByIdAsync(int questionId, bool includeAnswers = true)
        {
            var query = _dbSet.AsQueryable();

            if (includeAnswers)
                query = query.Include(q => q.Answers);

            var question = await query.FirstOrDefaultAsync(q => q.Id == questionId);

            return question != null
                ? Result.Success(question)
                : Result.Failure<Question>(new Error("Question.NotFound", "Question not found"));
        }

        public async Task<Result<IEnumerable<Question>>> GetByQuizIdAsync(int quizId, bool includeAnswers = true)
        {
            var query = _dbSet.Where(q => q.QuizId == quizId);

            if (includeAnswers)
                query = query.Include(q => q.Answers);

            var questions = await query.ToListAsync();

            return questions.Any()
                ? Result.Success(questions.AsEnumerable())
                : Result.Failure<IEnumerable<Question>>(new Error("Question.NotFound", "No questions found for this quiz"));
        }
    }
}