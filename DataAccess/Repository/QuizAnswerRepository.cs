using DataAccess.Abstractions;
using DataAccess.Contexts;
using DataAccess.Entities.RoadMap;
using DataAccess.IRepository;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataAccess.Repository
{
    public class QuizAnswerRepository : GenericRepository<QuizAnswer>, IQuizAnswerRepository
    {
        public QuizAnswerRepository(ApplicationDbContext context) : base(context) { }

        public async Task<Result<IEnumerable<QuizAnswer>>> GetByUserAndQuizAsync(int userId, int quizId)
        {
            var answers = await _dbSet.Where(a => a.UserId == userId && a.QuizId == quizId).ToListAsync();
            return answers.Any() ? Result.Success(answers.AsEnumerable()) : Result.Failure<IEnumerable<QuizAnswer>>(new Error("QuizAnswer.NotFound", "No answers found for this quiz and user"));
        }
    }
}

