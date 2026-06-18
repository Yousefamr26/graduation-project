using DataAccess.Abstractions;
using DataAccess.Entities.RoadMap;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataAccess.IRepository
{
    public interface IQuizAnswerRepository: IGenericRepository<QuizAnswer>
    {
        Task<Result<IEnumerable<QuizAnswer>>> GetByUserAndQuizAsync(int userId, int quizId);

    }
}
