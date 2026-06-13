using DataAccess.Abstractions;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DataAccess.IRepository
{
    public interface IQuestionRepository : IGenericRepository<Question>
    {
        Task<Result<Question>> GetByIdAsync(int questionId, bool includeAnswers = true);
        Task<Result<IEnumerable<Question>>> GetByQuizIdAsync(int quizId, bool includeAnswers = true);
    }
}