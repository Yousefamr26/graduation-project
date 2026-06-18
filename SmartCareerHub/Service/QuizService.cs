using Business_Logic.Errors;
using Business_Logic.IService;
using DataAccess.Abstractions;
using DataAccess.Entities.RoadMap;
using DataAccess.IRepository;
using Mapster;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using SmartCareerHub.Contracts.Company.CreateRoadmap;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Business_Logic.Services
{
    public class QuizService : IQuizService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly string _quizFilesPath;

        private readonly string[] _allowedTypes = { "MCQ", "TrueFalse", "EssayFile" };

        public QuizService(IUnitOfWork unitOfWork, IWebHostEnvironment env)
        {
            _unitOfWork = unitOfWork;
            _quizFilesPath = Path.Combine(env.WebRootPath ?? "wwwroot", "uploads", "quizzes");
            if (!Directory.Exists(_quizFilesPath))
                Directory.CreateDirectory(_quizFilesPath);
        }

        private bool IsValidQuizType(string type)
            => _allowedTypes.Contains(type);

        private bool BeFileAllowed(string type)
            => type == "EssayFile";

        private async Task<string> SaveFileAsync(IFormFile file, string subFolder, CancellationToken cancellationToken = default)
        {
            if (file == null || file.Length == 0)
                throw new ArgumentException("File is empty or null");

            var folder = Path.Combine(_quizFilesPath, subFolder);
            if (!Directory.Exists(folder))
                Directory.CreateDirectory(folder);

            var fileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
            var path = Path.Combine(folder, fileName);

            using var stream = new FileStream(path, FileMode.Create);
            await file.CopyToAsync(stream, cancellationToken);

            return $"/uploads/quizzes/{subFolder}/{fileName}";
        }

        // ===============================================
        //                   GET QUIZ
        // ===============================================

        public async Task<Result<QuizResponse?>> GetQuizByIdAsync(int quizId, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Quizzes.GetByIdAsync(quizId);
            if (result.IsFailure) return Result.Failure<QuizResponse?>(QuizErrors.QuizNotFound);

            var quiz = result.Value;

            var safeQuiz = new QuizResponse(
                Id: quiz.Id,
                Title: quiz.Title ?? string.Empty,
                Type: quiz.Type ?? string.Empty,
                QuestionsFile: BeFileAllowed(quiz.Type) ? quiz.QuestionsFile ?? string.Empty : string.Empty,
                Points: quiz.Points,
                RoadmapId: quiz.RoadmapId,
                Questions: quiz.Questions?.Select(q => new QuestionResponse(
                    Id: q.Id,
                    Text: q.Text ?? string.Empty,
                    Type: q.Type ?? string.Empty,
                    OptionsJson: q.OptionsJson ?? string.Empty,
                    CorrectAnswer: q.CorrectAnswer ?? string.Empty,
                    Answers: q.Answers?.Select(a => a.Adapt<QuizAnswerResponse>())
                             ?? Enumerable.Empty<QuizAnswerResponse>()
                )) ?? Enumerable.Empty<QuestionResponse>()
            );

            return Result.Success(safeQuiz);
        }

        public async Task<Result<IEnumerable<QuizResponse>>> GetQuizzesByRoadmapIdAsync(int roadmapId, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Quizzes.GetByRoadmapIdAsync(roadmapId);

            if (result.IsFailure || result.Value == null || !result.Value.Any())
                return Result.Success(Enumerable.Empty<QuizResponse>());

            var safeQuizzes = result.Value.Select(q => new QuizResponse(
                Id: q.Id,
                Title: q.Title ?? string.Empty,
                Type: q.Type ?? string.Empty,
                QuestionsFile: BeFileAllowed(q.Type) ? q.QuestionsFile ?? string.Empty : string.Empty,
                Points: q.Points,
                RoadmapId: q.RoadmapId,
                Questions: q.Questions?.Select(qq => new QuestionResponse(
                    Id: qq.Id,
                    Text: qq.Text ?? string.Empty,
                    Type: qq.Type ?? string.Empty,
                    OptionsJson: qq.OptionsJson ?? string.Empty,
                    CorrectAnswer: qq.CorrectAnswer ?? string.Empty,
                    Answers: qq.Answers?.Select(a => a.Adapt<QuizAnswerResponse>())
                             ?? Enumerable.Empty<QuizAnswerResponse>()
                )) ?? Enumerable.Empty<QuestionResponse>()
            ));

            return Result.Success(safeQuizzes);
        }

        // ===============================================
        //                    CREATE
        // ===============================================

        public async Task<Result> AddQuizToRoadmapAsync(int roadmapId, QuizRequest request, CancellationToken cancellationToken = default)
        {
            if (string.IsNullOrWhiteSpace(request.Title))
                return Result.Failure(QuizErrors.QuizEmptyTitle);

            if (!IsValidQuizType(request.Type))
                return Result.Failure(new Error("Quiz.InvalidType", "Quiz type is not valid"));

            await _unitOfWork.BeginTransactionAsync();

            try
            {
                var quiz = new QuizzesSec6
                {
                    RoadmapId = roadmapId,
                    Title = request.Title,
                    Type = request.Type,
                    Points = request.Points,
                    QuestionsFile = (request.QuestionsFile != null && BeFileAllowed(request.Type))
                        ? await SaveFileAsync(request.QuestionsFile, "files", cancellationToken)
                        : null
                };

                var questions = request.QuestionRequests?.Select(q => q.Adapt<Question>()).ToList()
                               ?? new List<Question>();

                var addResult = await _unitOfWork.Quizzes.CreateWithQuestionsAsync(quiz, questions);
                if (addResult.IsFailure)
                    return Result.Failure(addResult.Error);

                await _unitOfWork.CommitTransactionAsync();
                return Result.Success();
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync();
                return Result.Failure(new Error("Quiz.CreateFailed", ex.Message));
            }
        }

        // ===============================================
        //                    UPDATE
        // ===============================================

        public async Task<Result> UpdateQuizAsync(int quizId, QuizRequest request, CancellationToken cancellationToken = default)
        {
            var quizResult = await _unitOfWork.Quizzes.GetByIdAsync(quizId);
            if (quizResult.IsFailure) return Result.Failure(QuizErrors.QuizNotFound);

            if (!IsValidQuizType(request.Type))
                return Result.Failure(new Error("Quiz.InvalidType", "Quiz type is not valid"));

            var quiz = quizResult.Value;

            quiz.Title = request.Title;
            quiz.Type = request.Type;
            quiz.Points = request.Points;

            if (request.QuestionsFile != null && BeFileAllowed(request.Type))
            {
                quiz.QuestionsFile = await SaveFileAsync(request.QuestionsFile, "files", cancellationToken);
            }

            _unitOfWork.Quizzes.Update(quiz);
            await _unitOfWork.SaveChangesAsync();
            return Result.Success();
        }

        // ===============================================
        //                    DELETE
        // ===============================================

        public async Task<Result> DeleteQuizAsync(int quizId, CancellationToken cancellationToken = default)
        {
            var deleteResult = await _unitOfWork.Quizzes.DeleteQuizWithAnswersAsync(quizId);
            if (deleteResult.IsFailure) return Result.Failure(deleteResult.Error);

            return Result.Success();
        }

        // ===============================================
        //                QUESTIONS CRUD
        // ===============================================

        public async Task<Result> AddQuestionToQuizAsync(int quizId, QuestionRequest request, CancellationToken cancellationToken = default)
        {
            var quizResult = await _unitOfWork.Quizzes.GetByIdAsync(quizId);
            if (quizResult.IsFailure) return Result.Failure(QuizErrors.QuizNotFound);

            var question = request.Adapt<Question>();
            question.QuizId = quizId;

            await _unitOfWork.Questions.AddAsync(question);
            await _unitOfWork.SaveChangesAsync();
            return Result.Success();
        }


        public async Task<Result> AddQuestionsToQuizAsync(int quizId, List<QuestionRequest> requests, CancellationToken cancellationToken = default)
        {
            var quizResult = await _unitOfWork.Quizzes.GetByIdAsync(quizId);
            if (quizResult.IsFailure) return Result.Failure(QuizErrors.QuizNotFound);

            var questions = requests.Select(q =>
            {
                var question = q.Adapt<Question>();
                question.QuizId = quizId;
                return question;
            }).ToList();

            await _unitOfWork.Questions.AddRangeAsync(questions);
            await _unitOfWork.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<Result> UpdateQuestionAsync(int questionId, QuestionRequest request, CancellationToken cancellationToken = default)
        {
            var questionResult = await _unitOfWork.Questions.GetByIdAsync(questionId);
            if (questionResult.IsFailure) return Result.Failure(QuizErrors.QuizAnswerNotFound);

            var question = questionResult.Value;

            question.Text = request.Text;
            question.Type = request.Type;
            question.OptionsJson = request.OptionsJson;
            question.CorrectAnswer = request.CorrectAnswer;

            _unitOfWork.Questions.Update(question);
            await _unitOfWork.SaveChangesAsync();
            return Result.Success();
        }


        public async Task<Result> DeleteQuestionAsync(int questionId, CancellationToken cancellationToken = default)
        {
            var questionResult = await _unitOfWork.Questions.GetByIdAsync(questionId);
            if (questionResult.IsFailure) return Result.Failure(QuizErrors.QuizAnswerNotFound);

            _unitOfWork.Questions.Delete(questionResult.Value);
            await _unitOfWork.SaveChangesAsync();
            return Result.Success();
        }

        // ===============================================
        //             STUDENT ANSWERS
        // ===============================================

        public async Task<Result> SubmitQuizAnswerAsync(int userId, int quizId, int questionId, string? answerText, IFormFile? answerFile, CancellationToken cancellationToken = default)
        {
            var answer = new QuizAnswer
            {
                UserId = userId,
                QuizId = quizId,
                QuestionId = questionId,
                AnswerText = answerText,
                FileUrl = answerFile != null ? await SaveFileAsync(answerFile, "answers", cancellationToken) : null
            };

            await _unitOfWork.QuizAnswers.AddAsync(answer);
            await _unitOfWork.SaveChangesAsync();

            return Result.Success();
        }

        public async Task<Result<IEnumerable<QuizAnswerResponse>>> GetStudentAnswersAsync(int userId, int quizId, CancellationToken cancellationToken = default)
        {
            var answers = await _unitOfWork.QuizAnswers.GetByUserAndQuizAsync(userId, quizId);

            return answers.IsFailure
                ? Result.Success(Enumerable.Empty<QuizAnswerResponse>())
                : Result.Success(answers.Value.Adapt<IEnumerable<QuizAnswerResponse>>());
        }
    }
}
