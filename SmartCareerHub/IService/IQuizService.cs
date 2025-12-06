using DataAccess.Abstractions;
using Microsoft.AspNetCore.Http;
using SmartCareerHub.Contracts.Company.CreateRoadmap;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Business_Logic.IService
{
    public interface IQuizService
    {
        Task<Result<QuizResponse?>> GetQuizByIdAsync(int quizId, CancellationToken cancellationToken = default);
        Task<Result<IEnumerable<QuizResponse>>> GetQuizzesByRoadmapIdAsync(int roadmapId, CancellationToken cancellationToken = default);

        Task<Result> AddQuizToRoadmapAsync(int roadmapId, QuizRequest quizRequest, CancellationToken cancellationToken = default);
        Task<Result> UpdateQuizAsync(int quizId, QuizRequest quizRequest, CancellationToken cancellationToken = default);
        Task<Result> DeleteQuizAsync(int quizId, CancellationToken cancellationToken = default);

        Task<Result> AddQuestionToQuizAsync(int quizId, QuestionRequest questionRequest, CancellationToken cancellationToken = default);
        Task<Result> AddQuestionsToQuizAsync(int quizId, List<QuestionRequest> questionRequests, CancellationToken cancellationToken = default);
        Task<Result> UpdateQuestionAsync(int questionId, QuestionRequest questionRequest, CancellationToken cancellationToken = default);
        Task<Result> DeleteQuestionAsync(int questionId, CancellationToken cancellationToken = default);

        Task<Result> SubmitQuizAnswerAsync(int userId, int quizId, int questionId, string? answerText, IFormFile? answerFile, CancellationToken cancellationToken = default);
        Task<Result<IEnumerable<QuizAnswerResponse>>> GetStudentAnswersAsync(int userId, int quizId, CancellationToken cancellationToken = default);
    }
}
