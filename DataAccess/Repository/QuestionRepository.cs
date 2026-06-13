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
        public QuestionRepository(ApplicationDbContext context) : base(context) { }

        public async Task<Result<Question>> GetByIdAsync(int questionId)
        {
            var question = await _dbSet.FirstOrDefaultAsync(q => q.Id == questionId);
            return question != null
                ? Result.Success(question)
                : Result.Failure<Question>(new Error("Question.NotFound", "Question not found"));
        }

        public async Task<Result<IEnumerable<Question>>> GetByQuizIdAsync(int quizId)
        {
            var questions = await _dbSet.Where(q => q.QuizId == quizId).ToListAsync();
            return questions.Any()
                ? Result.Success(questions.AsEnumerable())
                : Result.Failure<IEnumerable<Question>>(new Error("Question.NotFound", "No questions found for this quiz"));
        }
    }
}
