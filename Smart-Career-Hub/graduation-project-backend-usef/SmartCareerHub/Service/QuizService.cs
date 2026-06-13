using Berad.GradioClient;
using Berad.GradioClient.NET;
using Berad.GradioClient.NET.Models.HuggingFace.Config;
using Business_Logic.Errors;
using Business_Logic.IService;
using DataAccess.Abstractions;
using DataAccess.Entities.RoadMap;
using DataAccess.IRepository;
using Mapster;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using SmartCareerHub.Contracts.Company.CreateRoadmap;
using Stripe;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using File = System.IO.File;
using Path = System.IO.Path;

namespace Business_Logic.Services
{
    public class QuizService : IQuizService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly string _quizFilesPath;
        private readonly IRoadmapService _roadmapService;
        private readonly string[] _allowedTypes = { "MCQ", "TrueFalse", "EssayFile" };
        private readonly HttpClient _httpClient;
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly IWebHostEnvironment _env;


        private const string GRADIO_SPACE_URL = "https://huggingface.co/spaces/ManarMagdy6/Professional-Quiz-Generator/api";

        public QuizService(
        IUnitOfWork unitOfWork,
        IWebHostEnvironment env,
        IRoadmapService roadmapService,
        HttpClient httpClient,
        IServiceScopeFactory scopeFactory)
        {
            // 1. التعيين الصحيح لكل الخدمات
            _unitOfWork = unitOfWork;
            _env = env;
            _roadmapService = roadmapService;
            _httpClient = httpClient;
            _scopeFactory = scopeFactory;

            // 2. تأمين الـ Path
            string webRoot = _env.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            _quizFilesPath = Path.Combine(webRoot, "uploads", "quizzes");

            if (!Directory.Exists(_quizFilesPath))
            {
                Directory.CreateDirectory(_quizFilesPath);
            }

            // 3. إعدادات Mapster (تتحط مرة واحدة بس)
            TypeAdapterConfig<QuizAnswer, QuizAnswerResponse>
                .NewConfig()
                .Map(dest => dest.Id, src => src.Id)
                .Map(dest => dest.UserId, src => src.Attempt.UserId)
                .Map(dest => dest.AnswerText, src => src.AnswerText ?? string.Empty);

            // امسح السطور المكررة اللي كانت هنا تحت الـ Config
        }

        private bool IsValidQuizType(string type) => _allowedTypes.Contains(type);
        private bool BeFileAllowed(string type) => type == "EssayFile";

        private async Task<string> SaveFileAsync(IFormFile file, string subFolder, CancellationToken cancellationToken = default)
        {
            if (file == null || file.Length == 0)
                throw new ArgumentException("File is empty or null");

            var folder = System.IO.Path.Combine(_quizFilesPath, subFolder);
            if (!Directory.Exists(folder))
                Directory.CreateDirectory(folder);

            var fileName = $"{Guid.NewGuid()}{System.IO.Path.GetExtension(file.FileName)}";
            var path = System.IO.Path.Combine(folder, fileName);

            using var stream = new FileStream(path, FileMode.Create);
            await file.CopyToAsync(stream, cancellationToken);

            return $"/uploads/quizzes/{subFolder}/{fileName}";
        }

        private QuizResponse MapToResponse(QuizzesSec6 q) => new QuizResponse(
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
                // التعديل هنا: ابعت الـ string مباشرة لأن الـ Record مستني string
                OptionsJson: qq.OptionsJson ?? "[]",
                CorrectAnswer: qq.CorrectAnswer ?? string.Empty,
                Answers: qq.Answers?.Select(a => a.Adapt<QuizAnswerResponse>()) ?? Enumerable.Empty<QuizAnswerResponse>()
            )) ?? Enumerable.Empty<QuestionResponse>()
        );


        // ===================== GET QUIZZES =====================
        public async Task<Result<QuizResponse?>> GetQuizByIdAsync(int quizId, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Quizzes.GetByIdAsync(quizId);
            if (result.IsFailure)
                return Result.Failure<QuizResponse?>(QuizErrors.QuizNotFound);

            var quiz = result.Value;
            var safeQuiz = MapToResponse(quiz);
            return Result.Success(safeQuiz);
        }

        public async Task<Result<IEnumerable<QuizResponse>>> GetQuizzesByRoadmapIdAsync(int roadmapId, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Quizzes.GetByRoadmapIdAsync(roadmapId);
            if (result.IsFailure || result.Value == null || !result.Value.Any())
                return Result.Success(Enumerable.Empty<QuizResponse>());

            var safeQuizzes = result.Value.Select(q => MapToResponse(q));
            return Result.Success(safeQuizzes);
        }

        // ===================== CREATE / UPDATE / DELETE QUIZ =====================
        public async Task<Result> AddQuizToRoadmapAsync(int roadmapId, QuizRequest request, CancellationToken cancellationToken = default)
        {
            if (string.IsNullOrWhiteSpace(request.Title))
                return Result.Failure(QuizErrors.QuizEmptyTitle);
            if (!IsValidQuizType(request.Type))
                return Result.Failure(new Error("Quiz.InvalidType", "Quiz type is not valid"));

            var quiz = new QuizzesSec6
            {
                RoadmapId = roadmapId,
                Title = request.Title,
                Type = request.Type,
                Points = request.Points,
                QuestionsFile = request.QuestionsFile != null && BeFileAllowed(request.Type)
                    ? await SaveFileAsync(request.QuestionsFile, "files", cancellationToken)
                    : null
            };

            await _unitOfWork.Quizzes.AddAsync(quiz);
            await _unitOfWork.SaveChangesAsync();

            if (quiz.Id <= 0)
                return Result.Failure(new Error("Quiz.CreateFailed", "Quiz ID not generated"));

            if (request.QuestionRequests != null && request.QuestionRequests.Any())
            {
                var questions = request.QuestionRequests.Select(qr => new Question
                {
                    QuizId = quiz.Id,
                    Text = qr.Text,
                    Type = qr.Type,
                    OptionsJson = qr.OptionsJson,
                    CorrectAnswer = qr.CorrectAnswer
                }).ToList();

                await _unitOfWork.Questions.AddRangeAsync(questions);
                await _unitOfWork.SaveChangesAsync();
            }

            return Result.Success();
        }

        public async Task<Result> UpdateQuizAsync(int quizId, QuizRequest request, CancellationToken cancellationToken = default)
        {
            var quizResult = await _unitOfWork.Quizzes.GetByIdAsync(quizId);
            if (quizResult.IsFailure)
                return Result.Failure(QuizErrors.QuizNotFound);
            if (!IsValidQuizType(request.Type))
                return Result.Failure(new Error("Quiz.InvalidType", "Quiz type is not valid"));

            var quiz = quizResult.Value;
            quiz.Title = request.Title;
            quiz.Type = request.Type;
            quiz.Points = request.Points;
            if (request.QuestionsFile != null && BeFileAllowed(request.Type))
                quiz.QuestionsFile = await SaveFileAsync(request.QuestionsFile, "files", cancellationToken);

            _unitOfWork.Quizzes.Update(quiz);
            await _unitOfWork.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<Result> DeleteQuizAsync(int quizId, CancellationToken cancellationToken = default)
        {
            var deleteResult = await _unitOfWork.Quizzes.DeleteQuizWithAnswersAsync(quizId);
            if (deleteResult.IsFailure)
                return Result.Failure(deleteResult.Error);
            return Result.Success();
        }

        // ===================== QUESTIONS CRUD =====================
        public async Task<Result> AddQuestionToQuizAsync(int quizId, QuestionRequest request, CancellationToken cancellationToken = default)
        {
            var quizResult = await _unitOfWork.Quizzes.GetByIdAsync(quizId);
            if (quizResult.IsFailure)
                return Result.Failure(QuizErrors.QuizNotFound);

            var question = request.Adapt<Question>();
            question.QuizId = quizId;

            await _unitOfWork.Questions.AddAsync(question);
            await _unitOfWork.SaveChangesAsync();
            return Result.Success();
        }

        public async Task<Result> AddQuestionsToQuizAsync(int quizId, List<QuestionRequest> requests, CancellationToken cancellationToken = default)
        {
            var quizResult = await _unitOfWork.Quizzes.GetByIdAsync(quizId);
            if (quizResult.IsFailure)
                return Result.Failure(QuizErrors.QuizNotFound);

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
            if (questionResult.IsFailure)
                return Result.Failure(QuizErrors.QuizAnswerNotFound);

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
            if (questionResult.IsFailure)
                return Result.Failure(QuizErrors.QuizAnswerNotFound);

            _unitOfWork.Questions.Delete(questionResult.Value);
            await _unitOfWork.SaveChangesAsync();
            return Result.Success();
        }

        // ===================== STUDENT ANSWERS =====================
        public async Task<Result> SubmitQuizAnswerAsync(
            string userId,
            int attemptId,
            int questionId,
            string? answerText,
            IFormFile? answerFile,
            CancellationToken cancellationToken = default)
        {
            // 1. التأكد من وجود المحاولة وأنها تخص المستخدم الحالي
            var attemptResult = await _unitOfWork.quizAttemptRepository.GetByIdAsync(attemptId);

            if (attemptResult.IsFailure || attemptResult.Value == null)
                return Result.Failure(new Error("Attempt.NotFound", "محاولة الكويز غير موجودة."));

            // تأمين: التأكد أن الـ UserId اللي باعت الإجابة هو صاحب المحاولة فعلياً
            if (attemptResult.Value.UserId != userId)
                return Result.Failure(new Error("Attempt.Unauthorized", "ليس لديك صلاحية لإضافة إجابات لهذه المحاولة."));

            // تأمين: التأكد أن المحاولة لم تُغلق (منع التعديل بعد رؤية النتيجة أو انتهاء الوقت)
            if (attemptResult.Value.IsCompleted)
                return Result.Failure(new Error("Attempt.Closed", "هذه المحاولة مكتملة بالفعل ولا يمكن تعديل إجاباتها."));

            // 2. التحقق من وجود السؤال
            var questionResult = await _unitOfWork.Questions.GetByIdAsync(questionId);
            if (questionResult.IsFailure || questionResult.Value == null)
                return Result.Failure(new Error("Question.NotFound", "السؤال غير موجود."));

            // 3. التعامل مع رفع الملفات (في حالة الأسئلة المقالية التي تتطلب ملف)
            string? savedFilePath = null;
            if (answerFile != null && answerFile.Length > 0)
            {
                // حفظ الملف في مجلد student_answers داخل الـ wwwroot
                savedFilePath = await SaveFileAsync(answerFile, "student_answers", cancellationToken);
            }

            // 4. منطق (Update vs Add): التحقق إذا كان الطالب قد أجاب على هذا السؤال سابقاً في نفس المحاولة
            var existingAnswerResult = await _unitOfWork.QuizAnswers.GetByAttemptAndQuestionAsync(attemptId, questionId);

            if (existingAnswerResult.IsSuccess && existingAnswerResult.Value != null)
            {
                // تحديث الإجابة الموجودة (لحماية الداتابيز من التكرار)
                var answer = existingAnswerResult.Value;
                answer.AnswerText = answerText;

                // إذا قام الطالب برفع ملف جديد، نقوم بتحديث المسار
                if (savedFilePath != null)
                {
                    answer.AnswerFile = savedFilePath;
                }

                _unitOfWork.QuizAnswers.Update(answer);
            }
            else
            {
                // إضافة إجابة جديدة لأول مرة
                var newAnswer = new QuizAnswer
                {
                    AttemptId = attemptId,
                    QuestionId = questionId,
                    AnswerText = answerText,
               
                };

                await _unitOfWork.QuizAnswers.AddAsync(newAnswer);
            }

            // 5. حفظ كافة التغييرات في خطوة واحدة (Atomic Operation)
            await _unitOfWork.SaveChangesAsync();

            return Result.Success();
        }

        public async Task<Result<IEnumerable<QuizAnswerResponse>>> GetStudentAnswersAsync(
            string userId,
            int quizId,
            CancellationToken cancellationToken = default)
        {
            var answersResult = await _unitOfWork.QuizAnswers.GetByUserAndQuizAsync(userId, quizId);
            if (answersResult.IsFailure || answersResult.Value == null)
                return Result.Success(Enumerable.Empty<QuizAnswerResponse>());

            var dtoList = answersResult.Value.Select(a => a.Adapt<QuizAnswerResponse>());
            return Result.Success(dtoList);
        }

        public async Task<Result<QuizScoreResponse>> FinishQuizAttemptAsync(
      string userId,
      int quizId,
      CancellationToken cancellationToken = default)
        {
            // 1. جلب المحاولة المفتوحة حالياً لهذا المستخدم والكويز
            // ملاحظة: تأكد من عمل Include(a => a.Quiz) في الـ Repository لو محتاج الـ Title
            var attempt = await _unitOfWork.quizAttemptRepository.GetByUserIdAndQuizIdAsync(userId, quizId);

            if (attempt == null)
            {
                return Result.Failure<QuizScoreResponse>(new Error("Quiz.NoActiveAttempt", "لا توجد محاولة مفتوحة لهذا الكويز حالياً."));
            }

            // تأمين: لو المحاولة مقفولة أصلاً من قبل كدة
            if (attempt.IsCompleted)
            {
                return Result.Failure<QuizScoreResponse>(new Error("Quiz.AlreadySubmitted", "لقد تم تسليم هذا الكويز مسبقاً."));
            }

            // 2. جلب كل إجابات الطالب مع بيانات الأسئلة المرتبطة
            var studentAnswers = await _unitOfWork.QuizAnswers.GetAnswersWithQuestionsAsync(attempt.Id);

            int correctAnswersCount = 0;
            int totalQuestionsCount = studentAnswers.Count(); // استخدمنا اسم متغير واضح لتفادي التكرار

            // 3. عملية التصحيح التلقائي (Auto-Grading)
            foreach (var answer in studentAnswers)
            {
                var isCorrect = string.Equals(
                    answer.AnswerText?.Trim(),
                    answer.Question.CorrectAnswer?.Trim(),
                    StringComparison.OrdinalIgnoreCase
                );

                if (isCorrect)
                {
                    correctAnswersCount++;
                }
            }

            // 4. تحديث بيانات المحاولة في الداتابيز
            attempt.Score = correctAnswersCount;
            attempt.IsCompleted = true;

            // لو عندك حقل FinishedAt في الـ Entity، يفضل تسجل الوقت هنا
            attempt.FinishedAt = DateTime.UtcNow; 

            _unitOfWork.quizAttemptRepository.Update(attempt);
            await _unitOfWork.SaveChangesAsync();

            // 5. بناء الـ Response النهائي بناءً على الـ QuizScoreResponse Record
            var percentage = totalQuestionsCount > 0
                ? (double)correctAnswersCount / totalQuestionsCount * 100
                : 0;

            var response = new QuizScoreResponse(
                AttemptId: attempt.Id,
                QuizId: quizId,
                QuizTitle: attempt.Quiz?.Title ?? "نتيجة الكويز",
                Score: correctAnswersCount,
                TotalPoints: totalQuestionsCount,
                CorrectAnswers: correctAnswersCount,
                TotalQuestions: totalQuestionsCount,
                Percentage: percentage,
                IsPassed: percentage >= 50,
                CompletedAt: DateTime.UtcNow
            );

            return Result.Success(response);
        }

        public async Task<Result<QuizScoreResponse>> GetQuizScoreAsync(
            string userId,
            int quizId,
            CancellationToken cancellationToken = default)
        {
            var quizResult = await _unitOfWork.Quizzes.GetByIdAsync(quizId);
            if (quizResult.IsFailure)
                return Result.Failure<QuizScoreResponse>(QuizErrors.QuizNotFound);

            var quiz = quizResult.Value;

            var attemptResult = await _unitOfWork.quizAttemptRepository.GetByUserAndQuizAsync(userId, quizId);
            if (attemptResult.IsFailure || attemptResult.Value == null)
                return Result.Failure<QuizScoreResponse>(new Error("Attempt.NotFound", "No quiz attempt found."));

            var attempt = attemptResult.Value;

            if (!attempt.IsCompleted)
                return Result.Failure<QuizScoreResponse>(
                    new Error("Attempt.NotCompleted", "Quiz is not completed yet."));

            int totalQuestions = quiz.Questions?.Count ?? 0;
            int correctCount = attempt.Answers?.Count(a =>
                a.Question?.CorrectAnswer != null &&
                string.Equals(a.AnswerText?.Trim(), a.Question.CorrectAnswer.Trim(),
                    StringComparison.OrdinalIgnoreCase)) ?? 0;

            double percentage = quiz.Points == 0
                ? 0
                : Math.Round((attempt.Score * 100.0) / quiz.Points, 2);

            return Result.Success(new QuizScoreResponse(
                AttemptId: attempt.Id,
                QuizId: quiz.Id,
                QuizTitle: quiz.Title ?? string.Empty,
                Score: attempt.Score,
                TotalPoints: quiz.Points,
                CorrectAnswers: correctCount,
                TotalQuestions: totalQuestions,
                Percentage: percentage,
                IsPassed: percentage >= 50,
                CompletedAt: attempt.CompletedAt ?? DateTime.UtcNow
            ));
        }
        public async Task<Result<int>> StartQuizAttemptAsync(string userId, int quizId, CancellationToken cancellationToken = default)
        {
            // 1. التأكد من وجود الكويز
            var quizResult = await _unitOfWork.Quizzes.GetByIdAsync(quizId);
            if (quizResult.IsFailure)
                return Result.Failure<int>(QuizErrors.QuizNotFound);

            // 2. التحقق لو الطالب عنده محاولة سابقة (عشان نمنع التكرار لو دي سياستك)
            var existingAttempt = await _unitOfWork.quizAttemptRepository.GetByUserAndQuizAsync(userId, quizId);

            if (existingAttempt.IsSuccess && existingAttempt.Value != null)
            {
                // لو المحاولة مكتملة، نمنعه يبدأ من جديد (أو حسب رغبتك في البيزنس لوجيك)
                if (existingAttempt.Value.IsCompleted)
                    return Result.Failure<int>(new Error("Quiz.AlreadyCompleted", "لقد أتممت هذا الكويز بالفعل."));

                // لو عنده محاولة "مفتوحة" لسه مخلصهاش، نرجعه يكملها بدل ما نفتح واحدة جديدة
                return Result.Success(existingAttempt.Value.Id);
            }

            // 3. إنشاء محاولة جديدة (New Attempt)
            var newAttempt = new QuizAttempt
            {
                UserId = userId,
                QuizId = quizId,
                StartedAt = DateTime.UtcNow,
                IsCompleted = false,
                Score = 0
            };

            await _unitOfWork.quizAttemptRepository.AddAsync(newAttempt);
            await _unitOfWork.SaveChangesAsync();

            // نرجع الـ ID للموبايل عشان يبعته في كل إجابة سؤال (SubmitAnswer)
            return Result.Success(newAttempt.Id);
        }

        // ===================== AI QUIZ GENERATION =====================
        // ===================== AI QUIZ GENERATION (The Core Fix) =====================

        public async Task<Result<IEnumerable<QuizResponse>>> GenerateQuizFromAIAsync(int roadmapId, string quizType, int numQuestions, CancellationToken cancellationToken = default)
        {
            // 1. جلب البيانات الأساسية
            var roadmapResult = await _unitOfWork.Roadmaps.GetByIdWithDetailsAsync(roadmapId);
            var pdfMaterial = roadmapResult.Value?.LearningMaterials?
                .FirstOrDefault(m => m.FilePath.EndsWith(".pdf", StringComparison.OrdinalIgnoreCase));

            if (pdfMaterial == null)
                return Result.Failure<IEnumerable<QuizResponse>>(new Error("AI.NoPDF", "لم يتم العثور على ملف PDF صالح."));

            try
            {
                // 2. طلب الداتا من الـ AI
                string publicUrl = $"https://smart-career-hub.com/{pdfMaterial.FilePath.Replace("\\", "/").TrimStart('/')}";
                var rawJson = await CallGradioAIEngine(publicUrl, quizType, numQuestions);

                var aiQuestions = DeserializeAIQuestions(rawJson);
                if (aiQuestions == null || !aiQuestions.Any())
                    return Result.Failure<IEnumerable<QuizResponse>>(new Error("AI.ParseError", "فشل في معالجة الأسئلة من الـ AI."));

                // 3. بناء الكويز (الـ EF هيسيف الأسئلة أوتوماتيك مع الكويز)
                var newQuiz = new QuizzesSec6
                {
                    RoadmapId = roadmapId,
                    Title = $"AI Generated: {pdfMaterial.TitlePdf}",
                    Type = quizType.Contains("True") ? "True/False" : "MCQ",
                    Points = numQuestions * 10,
                    CreationSource = "AI",
                    CreatedAt = DateTime.UtcNow,
                    // هنا بنعمل Mapping للأسئلة جوه الـ Navigation Property
                    Questions = aiQuestions.Select(q => new Question
                    {
                        Text = CleanAIText(q.Question),
                        Type = quizType.Contains("True") ? "True/False" : "MCQ",
                        OptionsJson = JsonSerializer.Serialize(q.Options?.Select(CleanAIText).ToList() ?? new List<string>()),
                        CorrectAnswer = q.GetCorrectAnswer()
                    }).ToList()
                };

                // 4. حفظ الكل في خطوة واحدة
                await _unitOfWork.Quizzes.AddAsync(newQuiz);
                await _unitOfWork.SaveChangesAsync();

                // 5. تحديث إجمالي النقاط (بما إن الكويز اتسيف خلاص)
                await RecalculateRoadmapTotalsAndPointsAsync(roadmapId);

                return Result.Success<IEnumerable<QuizResponse>>(new List<QuizResponse> { MapToResponse(newQuiz) });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[QUIZ-SERVICE-ERROR]: {ex.Message}");
                return Result.Failure<IEnumerable<QuizResponse>>(new Error("AI.Exception", "خطأ فني: " + ex.Message));
            }
        }
        private string CleanAIText(string? input)
        {
            if (string.IsNullOrWhiteSpace(input)) return "";
            // Regex بيسيب العربي والإنجليزي والأرقام وعلامات الترقيم بس
            string pattern = @"[^\u0600-\u06FF\u0020-\u007E]";
            return Regex.Replace(input, pattern, "").Trim();
        }

        private List<AIQuestion>? DeserializeAIQuestions(string rawJson)
        {
            var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
            try
            {
                return JsonSerializer.Deserialize<List<AIQuestion>>(rawJson, options);
            }
            catch
            {
                var nested = JsonSerializer.Deserialize<string>(rawJson, options);
                return JsonSerializer.Deserialize<List<AIQuestion>>(nested ?? "[]", options);
            }
        }

        // ميثود مساعدة لضمان عدم نسيان تحديث الداتابيز عند الفشل
        private async Task<Result<IEnumerable<QuizResponse>>> HandleFailure(QuizGenerationJob? job, string code, string msg)
        {
            if (job != null)
            {
                job.Status = "Failed";
                job.ErrorMessage = msg;
                job.CompletedAt = DateTime.UtcNow;
                await _unitOfWork.SaveChangesAsync();
            }
            return Result.Failure<IEnumerable<QuizResponse>>(new Error(code, msg));
        }
        private async Task RecalculateRoadmapTotalsAndPointsAsync(int roadmapId)
        {
            var result = await _unitOfWork.Roadmaps.GetByIdWithDetailsAsync(roadmapId);
            if (result.IsFailure) return;

            var roadmap = result.Value;
            EnsureCollections(roadmap);

            roadmap.TotalMaterials = roadmap.LearningMaterials.Count;
            roadmap.TotalProjects = roadmap.Projects.Count;
            roadmap.TotalQuizzes = roadmap.Quizzes.Count;

            // بنجمع كل النقط المتاحة في الرودماب (عشان دي الـ 100% بتاعة أي حد)
            roadmap.TotalPoints =
                roadmap.RequiredSkills.Sum(s => s.Points) +
                roadmap.LearningMaterials.Sum(m => m.Points) +
                roadmap.Projects.Sum(p => p.Points) +
                roadmap.Quizzes.Sum(q => q.Points);

            _unitOfWork.Roadmaps.Update(roadmap);
            await _unitOfWork.SaveChangesAsync();
        }
        public async Task<string> CallGradioAIEngine(string publicUrl, string quizType, int numQuestions)
        {
            try
            {
                // 1. رفع الملف وخد الـ Internal Path
                string internalPath = await UploadFileToGradio(publicUrl);
                string fileName = Path.GetFileName(publicUrl.Split('?')[0]);

                string callUrl = "https://manarmagdy6-professional-quiz-generator.hf.space/gradio_api/call/predict";

                // 2. بناء الـ Payload بناءً على الـ Recorded API Call اللي بعتهالي
                var payload = new
                {
                    data = new object[]
                    {
                new {
                    path = internalPath,
                    url = (string)null, // سيبه null السيرفر هيمليه
                    size = 0,
                    orig_name = fileName,
                    mime_type = "application/pdf",
                    is_stream = false,
                    meta = new { _type = "gradio.FileData" } // دي أهم حتة في الديكيومنت
                },
                "Generate questions based on this PDF content", // raw_text (Required)
                quizType, // MCQ أو True/False
                (float)numQuestions // Slider value as float
                    }
                };

                // 3. طلب الـ Event ID
                var callResponse = await _httpClient.PostAsJsonAsync(callUrl, payload);
                callResponse.EnsureSuccessStatusCode();

                var callResult = await callResponse.Content.ReadFromJsonAsync<JsonElement>();
                string eventId = callResult.GetProperty("event_id").GetString();

                // 4. الاستماع للـ SSE Stream (التعديل لضمان قراءة الداتا صح)
                string resultUrl = $"{callUrl}/{eventId}";
                using var streamResponse = await _httpClient.GetAsync(resultUrl, HttpCompletionOption.ResponseHeadersRead);
                using var reader = new StreamReader(await streamResponse.Content.ReadAsStreamAsync());

                while (!reader.EndOfStream)
                {
                    string line = await reader.ReadLineAsync();
                    if (string.IsNullOrWhiteSpace(line)) continue;

                    if (line.StartsWith("event: complete"))
                    {
                        string dataLine = await reader.ReadLineAsync();
                        if (dataLine != null && dataLine.StartsWith("data: "))
                        {
                            string jsonContent = dataLine.Substring(6).Trim();
                            using var doc = JsonDocument.Parse(jsonContent);

                            // الديكيومنت بيقول الرد بيرجع Tuple [0] هو الـ JSON String
                            return doc.RootElement[0].GetString();
                        }
                    }
                    else if (line.StartsWith("event: error"))
                    {
                        var errorLine = await reader.ReadLineAsync();
                        throw new Exception($"AI Engine Logic Error: {errorLine}");
                    }
                }

                throw new Exception("AI Process did not return a 'complete' event.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[CRITICAL-AI] {ex.Message}");
                throw;
            }
        }

        // الميثود المساعدة للرفع (عشان تضمن الـ 100%)
        private async Task<string> UploadFileToGradio(string publicUrl)
        {
            // 1. استخراج اسم الملف من المسار أو اللينك
            string fileName = Path.GetFileName(publicUrl.Split('?')[0]);

            // 2. تحديد المسار الفيزيائي على السيرفر (بنجرب المسارات المحتملة في MonsterASP)
            string rootPath = Directory.GetCurrentDirectory();

            // المسار المرجح (wwwroot/uploads/...)
            string filePath = Path.Combine(rootPath, "wwwroot", "uploads", "roadmaps", "materials", fileName);

            // محاولة بديلة لو الـ wwwroot مكررة في الهيكل التنظيمي
            if (!System.IO.File.Exists(filePath))
            {
                filePath = Path.Combine(rootPath, "wwwroot", "wwwroot", "uploads", "roadmaps", "materials", fileName);
            }

            // لو لسه مش موجود، بنرمي Exception واضح بالمسار اللي دورنا فيه
            if (!File.Exists(filePath))
            {
                throw new FileNotFoundException($"AI Error: الملف غير موجود في المسار الفيزيائي: {filePath}");
            }

            // 3. تحويل الملف لـ Bytes للرفع
            byte[] fileBytes = await File.ReadAllBytesAsync(filePath);

            using var content = new MultipartFormDataContent();
            var fileContent = new ByteArrayContent(fileBytes);
            // مهم جداً تحديد الـ MimeType عشان السيرفر يقبله كـ PDF
            fileContent.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue("application/pdf");
            content.Add(fileContent, "files", fileName);

            // 4. الرفع لـ API الـ Upload الخاص بـ Gradio
            var uploadRes = await _httpClient.PostAsync("https://manarmagdy6-professional-quiz-generator.hf.space/gradio_api/upload", content);

            if (!uploadRes.IsSuccessStatusCode)
            {
                var errorContent = await uploadRes.Content.ReadAsStringAsync();
                throw new Exception($"Upload Failed Status: {uploadRes.StatusCode}, Details: {errorContent}");
            }

            // 5. قراءة الرد (الـ API ده بيرجع JSON Array of Strings)
            // مثال للرد: ["/tmp/gradio/8772c.../document.pdf"]
            var result = await uploadRes.Content.ReadFromJsonAsync<List<string>>();

            if (result == null || result.Count == 0)
            {
                throw new Exception("AI Server returned an empty file list after upload.");
            }

            // بنرجع أول مسار (index 0) وهو الـ Internal Path اللي الـ Predict محتاجه
            return result[0];
        }








        private string? ExtractJsonFromGradio(string dataLine)
        {
            try
            {
                string jsonRaw = dataLine.Replace("data:", "").Trim();
                using var doc = JsonDocument.Parse(jsonRaw);
                if (doc.RootElement.ValueKind == JsonValueKind.Array && doc.RootElement.GetArrayLength() > 0)
                {
                    var firstElement = doc.RootElement[0];
                    return firstElement.ValueKind == JsonValueKind.String ? firstElement.GetString() : firstElement.GetRawText();
                }
            }
            catch { }
            return null;
        }
        // ===================== BACKGROUND JOB =====================
        // ===================== BACKGROUND JOB (The Final Version) =====================
        public async Task<int> GenerateQuizFromAIJobAsync(int roadmapId, string quizType, int numQuestions, CancellationToken cancellationToken = default)
        {
            // 1. استدعاء الميثود الأساسية لتوليد الكويز
            // الميثود دي جواها بتكلم الـ AI، بتفك الـ JSON، وبتحفظ الكويز والأسئلة في الداتابيز
            var result = await GenerateQuizFromAIAsync(roadmapId, quizType, numQuestions, cancellationToken);

            // 2. التحقق من نجاح العملية
            if (result.IsFailure)
            {
                // بنرمي Exception عشان الـ Worker يمسكها ويحول حالة الـ Job لـ Failed
                throw new Exception(result.Error.Description);
            }

            // 3. الخطوة الأهم: إرجاع الـ ID الحقيقي (int) للكويز اللي تم إنشاؤه
            // ده بيضمن إن الـ Worker يبعت رقم صحيح لـ MarkJobAsCompletedAsync
            var generatedQuiz = result.Value.FirstOrDefault();

            if (generatedQuiz == null)
            {
                throw new Exception("AI generated the quiz but failed to retrieve the new ID.");
            }

            return generatedQuiz.Id;
        }

        // ===================== HELPERS & GETTERS =====================

        public async Task<Result<IEnumerable<QuizResponse>>> GetGeneratedQuizzesByRoadmapIdAsync(int roadmapId)
        {
            var result = await _unitOfWork.Quizzes.GetByRoadmapIdAsync(roadmapId);
            if (result.IsFailure || result.Value == null) return Result.Success(Enumerable.Empty<QuizResponse>());

            var generated = result.Value.Where(q => q.CreationSource == "AI").Select(MapToResponse);
            return Result.Success(generated);
        }
     


        private class AIQuestion
        {
            [JsonPropertyName("question")]
            public string Question { get; set; } = "";

            // غيرنا من Dictionary إلى List
            [JsonPropertyName("options")]
            public List<string> Options { get; set; } = new();

            [JsonPropertyName("answer")]
            public string Answer { get; set; } = "";

            [JsonPropertyName("correct_answer")]
            public string CorrectAnswer { get; set; } = "";

            // ميثود مساعدة لجلب الإجابة الصحيحة
            public string GetCorrectAnswer() => !string.IsNullOrEmpty(Answer) ? Answer : CorrectAnswer;
        }

        private void EnsureCollections(RoadmapSec1 roadmap)
        {
            roadmap.RequiredSkills ??= new List<RequiredSkillSec2>();
            roadmap.LearningMaterials ??= new List<LearningMaterialSec34>();
            roadmap.Projects ??= new List<ProjectSec5>();
            roadmap.Quizzes ??= new List<QuizzesSec6>();
        }
    }
}