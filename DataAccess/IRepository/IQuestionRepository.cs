using DataAccess.Abstractions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataAccess.IRepository
{
    public interface IQuestionRepository : IGenericRepository<Question>
    {
        Task<Result<Question>> GetByIdAsync(int questionId);
        Task<Result<IEnumerable<Question>>> GetByQuizIdAsync(int quizId);

    }
}
