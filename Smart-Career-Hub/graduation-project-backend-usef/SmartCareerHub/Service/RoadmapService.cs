using Business_Logic.Errors;
using Business_Logic.IService;
using DataAccess.Abstractions;
using DataAccess.Entities.RoadMap;
using DataAccess.Entities.Users;
using DataAccess.IRepository;
using Mapster;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using SmartCareerHub.Contracts.Company.CreateRoadmap;
using SmartCareerHub.Contracts.Student.Roadmaps;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Business_Logic.Services
{
    public class RoadmapService : IRoadmapService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IUserRoadmapRepository _userRoadmapRepository;
        private readonly IRealTimeNotificationService _realTimeNotificationService;
        private readonly IStripePaymentService _stripePaymentService;


        private readonly string _roadmapsPath;

        public RoadmapService(
            IUnitOfWork unitOfWork,
            IWebHostEnvironment env,
            IUserRoadmapRepository userRoadmapRepository,
            IRealTimeNotificationService realTimeNotificationService
                    
            ,
            IStripePaymentService stripePaymentService)
        {
            _unitOfWork = unitOfWork;
            _userRoadmapRepository = userRoadmapRepository;
            _realTimeNotificationService = realTimeNotificationService;

            _roadmapsPath = Path.Combine(env.WebRootPath ?? "wwwroot", "uploads", "roadmaps");
            if (!Directory.Exists(_roadmapsPath))
                Directory.CreateDirectory(_roadmapsPath);
            _stripePaymentService = stripePaymentService;
        }

        private void EnsureCollections(RoadmapSec1 roadmap)
        {
            roadmap.RequiredSkills ??= new List<RequiredSkillSec2>();
            roadmap.LearningMaterials ??= new List<LearningMaterialSec34>();
            roadmap.Projects ??= new List<ProjectSec5>();
            roadmap.Quizzes ??= new List<QuizzesSec6>();
        }

        private async Task<string> SaveFileAsync(IFormFile file, string subFolder, CancellationToken cancellationToken = default)
        {
            if (file == null || file.Length == 0)
                throw new ArgumentException("File is empty or null");

            var folder = Path.Combine(_roadmapsPath, subFolder);
            if (!Directory.Exists(folder))
                Directory.CreateDirectory(folder);

            var fileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
            var path = Path.Combine(folder, fileName);

            using var stream = new FileStream(path, FileMode.Create);
            await file.CopyToAsync(stream, cancellationToken);

            return $"/uploads/roadmaps/{subFolder}/{fileName}";
        }

        private async Task RecalculateRoadmapTotalsAndPointsAsync(int roadmapId)
        {
            var result = await _unitOfWork.Roadmaps.GetByIdWithDetailsAsync(roadmapId);
            if (result.IsFailure) return;

            var roadmap = result.Value;
            EnsureCollections(roadmap);

            // ✅ تحديث نقاط الكويزات (خصوصًا AI)
            foreach (var quiz in roadmap.Quizzes)
            {
                if (quiz.Type == "AI") // 👈 مهم جدًا
                {
                    var questionsResult = await _unitOfWork.Questions.GetByQuizIdAsync(quiz.Id);

                    var questions = questionsResult.IsFailure || questionsResult.Value == null
                        ? Enumerable.Empty<Question>()
                        : questionsResult.Value;

                    quiz.Points = questions.Count() * 10;
                }
            }

            roadmap.TotalMaterials = roadmap.LearningMaterials.Count;
            roadmap.TotalProjects = roadmap.Projects.Count;
            roadmap.TotalQuizzes = roadmap.Quizzes.Count;

            roadmap.TotalPoints =
                roadmap.RequiredSkills.Sum(s => s.Points) +
                roadmap.LearningMaterials.Sum(m => m.Points) +
                roadmap.Projects.Sum(p => p.Points) +
                roadmap.Quizzes.Sum(q => q.Points);

            _unitOfWork.Roadmaps.Update(roadmap);
            await _unitOfWork.SaveChangesAsync();
        }

        // =================== GET ===================
        public async Task<PagedResponse<RoadmapResponse>> GetAllAsync(
     QueryParameters query,
     CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Roadmaps.GetAllWithDetailsAsync();
            if (result.IsFailure)
                return PagedResponse<RoadmapResponse>.Create(
                    Enumerable.Empty<RoadmapResponse>(), query.Page, query.PageSize);

            var roadmaps = result.Value.AsQueryable();

            // Filtering
            if (!string.IsNullOrWhiteSpace(query.Search))
                roadmaps = roadmaps.Where(r =>
                    r.Title.Contains(query.Search, StringComparison.OrdinalIgnoreCase) ||
                    r.TargetRole.Contains(query.Search, StringComparison.OrdinalIgnoreCase) ||
                    (r.Company != null && r.Company.OrganizationName
                        .Contains(query.Search, StringComparison.OrdinalIgnoreCase)) ||
                    (r.TrainingCenter != null && r.TrainingCenter.Name
                        .Contains(query.Search, StringComparison.OrdinalIgnoreCase)));

            // Sorting
            roadmaps = query.SortBy?.ToLower() switch
            {
                "title" => query.SortDirection == "asc"
                    ? roadmaps.OrderBy(r => r.Title)
                    : roadmaps.OrderByDescending(r => r.Title),
                "points" => query.SortDirection == "asc"
                    ? roadmaps.OrderBy(r => r.TotalPoints)
                    : roadmaps.OrderByDescending(r => r.TotalPoints),
                _ => roadmaps.OrderByDescending(r => r.CreatedAt)
            };

            foreach (var roadmap in roadmaps)
                EnsureCollections(roadmap);

            var mappedList = roadmaps.ToList();
            var mapped = mappedList.Select(r => r.Adapt<RoadmapResponse>() with
            {
                CompanyName = r.Company != null ? r.Company.OrganizationName
                            : r.TrainingCenter != null ? r.TrainingCenter.Name
                            : ""
            });
            return PagedResponse<RoadmapResponse>.Create(mapped, query.Page, query.PageSize);
        }

        public async Task<PagedResponse<RoadmapResponse>> GetPublishedAsync(
            QueryParameters query,
            CancellationToken cancellationToken = default)
        {
            var result = await GetAllAsync(query, cancellationToken);
            var filtered = result.Data.Where(r => r.IsPublished);
            return PagedResponse<RoadmapResponse>.Create(filtered, query.Page, query.PageSize);
        }

        public async Task<PagedResponse<RoadmapResponse>> GetByTargetRoleAsync(
            string role,
            QueryParameters query,
            CancellationToken cancellationToken = default)
        {
            var result = await GetAllAsync(query, cancellationToken);
            var filtered = result.Data.Where(r =>
                r.TargetRole.Equals(role, StringComparison.OrdinalIgnoreCase));
            return PagedResponse<RoadmapResponse>.Create(filtered, query.Page, query.PageSize);
        }

        public async Task<RoadmapResponse?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Roadmaps.GetByIdWithDetailsAsync(id);

            if (result.IsFailure)
                throw new InvalidOperationException(RoadmapErrors.RoadmapNotFound.Description);

            var roadmap = result.Value;

            EnsureCollections(roadmap);

            return new RoadmapResponse(
                roadmap.Id,
                roadmap.Title,
                roadmap.Description,
                roadmap.TargetRole,
                roadmap.CoverImageUrl,
                roadmap.StartDate,
                roadmap.EndDate,
                roadmap.IsPublished,
                roadmap.CreatedAt,
                roadmap.TotalPoints,
               roadmap.Company?.OrganizationName ?? roadmap.TrainingCenter?.Name ?? string.Empty,
                roadmap.Price, // ✅ السعر هنا
                roadmap.RequiredSkills
                    .Select(skill => new RequiredSkillResponse(
                        skill.Id,
                        skill.SkillName,
                        skill.Level,
                        skill.Points
                    )).ToList(),
                roadmap.Projects
                    .Select(project => new ProjectResponse(
                        project.Id,
                        project.Title,
                        project.Description,
                        project.Difficulty,
                        project.Points
                    )).ToList(),
                roadmap.LearningMaterials
                    .Select(lm => new LearningMaterialResponse(
                        lm.Id,
                        lm.TitleVideos,
                        lm.TitlePdf,
                        lm.VideoDuration,
                        lm.PdfDuration,
                        lm.MaterialType,
                        lm.FilePath,
                        lm.Points
                    )).ToList(),
                     roadmap.Quizzes.Select(q => new QuizResponse(
        q.Id,
        q.Title,
        q.Type,
        q.QuestionsFile,
        q.Points,
        q.RoadmapId,
        new List<QuestionResponse>()
    )).ToList() // ← ضيف ده
            );
        }

        // =================== ADD ===================
        public async Task<RoadmapResponse> AddAsync(string userId, RoadmapRequest request, CancellationToken cancellationToken = default)
        {
            await _unitOfWork.BeginTransactionAsync();
            try
            {
                // ===== جلب بيانات الشركة أو مركز التدريب =====
                var company = await _unitOfWork.companyAuthRepository.GetCompanyProfileByUserIdAsync(userId);

                if (company == null)
                {
                    var trainingCenter = await _unitOfWork.trainingCenterAuthRepository
                        .GetTrainingCenterProfileByUserIdAsync(userId);

                    if (trainingCenter == null)
                        throw new InvalidOperationException("Company or Training Center profile not found.");
                }

                // ===== تحقق من تكرار العنوان =====
                if (await IsTitleExistsAsync(request.Title))
                    throw new InvalidOperationException(RoadmapErrors.RoadmapTitleExists.Description);

                // ===== إنشاء Roadmap من request =====
                var roadmap = request.Adapt<RoadmapSec1>();
                roadmap.CreatedAt = DateTime.UtcNow;
                roadmap.IsPublished = request.IsPublished;
                roadmap.Price = request.Price ?? 0;

                if (company != null)
                {
                    roadmap.CompanyUserId = company.Id;
                    roadmap.TrainingCenterId = null;
                }
                else
                {
                    var trainingCenter = await _unitOfWork.trainingCenterAuthRepository
                        .GetTrainingCenterProfileByUserIdAsync(userId);
                    roadmap.TrainingCenterId = trainingCenter!.Id;
                    roadmap.CompanyUserId = null;
                }

                // ===== حفظ صورة الغلاف لو موجودة =====
                if (request.CoverImage != null)
                    roadmap.CoverImageUrl = await SaveFileAsync(request.CoverImage, "covers", cancellationToken);

                // ===== إضافة الرودماب للـ DB =====
                var addResult = await _unitOfWork.Roadmaps.AddRoadmapAsync(roadmap);
                if (addResult.IsFailure)
                    throw new InvalidOperationException(RoadmapErrors.RoadmapCreationFailed.Description);

                roadmap = addResult.Value;

                // ===== إضافة المهارات المطلوبة =====
                if (request.SkillRequests?.Any() == true)
                {
                    var skills = request.SkillRequests.Select(s => new RequiredSkillSec2
                    {
                        RoadmapId = roadmap.Id,
                        SkillName = s.SkillName,
                        Level = s.Level,
                        Points = s.LevelPoints
                    }).ToList();

                    await _unitOfWork.RequiredSkills.AddRangeAsync(skills);
                }

                // ===== إضافة المواد التعليمية =====
                if (request.LearningMaterialRequests?.Any() == true)
                {
                    foreach (var m in request.LearningMaterialRequests)
                    {
                        var mat = new LearningMaterialSec34
                        {
                            RoadmapId = roadmap.Id,
                            MaterialType = m.Type,
                            TitleVideos = m.TitleVideos,
                            TitlePdf = m.TitlePdf,
                            VideoDuration = m.Duration,
                            PdfDuration = m.Durationpdf,
                            Points = m.Points,
                            FilePath = m.FilePath != null
                                ? await SaveFileAsync(m.FilePath, "materials", cancellationToken)
                                : null
                        };
                        await _unitOfWork.LearningMaterials.AddAsync(mat);
                    }
                }

                // ===== إضافة المشاريع =====
                if (request.ProjectRequests?.Any() == true)
                {
                    var projects = request.ProjectRequests.Select(p => new ProjectSec5
                    {
                        RoadmapId = roadmap.Id,
                        Title = p.Title,
                        Description = p.Description,
                        Difficulty = p.Difficulty,
                        Points = p.Points
                    }).ToList();

                    await _unitOfWork.Projects.AddRangeAsync(projects);
                }

                // ===== إضافة الكويزات =====
                if (request.QuizRequests?.Any() == true)
                {
                    foreach (var q in request.QuizRequests)
                    {
                        var quiz = new QuizzesSec6
                        {
                            RoadmapId = roadmap.Id,
                            Title = q.Title,
                            Type = q.Type,
                            Points = q.Points
                        };
                        await _unitOfWork.Quizzes.AddAsync(quiz);
                        await _unitOfWork.SaveChangesAsync();

                        if (q.QuestionRequests?.Any() == true)
                        {
                            foreach (var question in q.QuestionRequests)
                            {
                                var newQuestion = new Question
                                {
                                    QuizId = quiz.Id,
                                    Text = question.Text,
                                    Type = question.Type,
                                    OptionsJson = question.OptionsJson,
                                    CorrectAnswer = question.CorrectAnswer
                                };
                                await _unitOfWork.Questions.AddAsync(newQuestion);
                            }
                            await _unitOfWork.SaveChangesAsync();
                        }
                    }
                }

                // ===== حفظ كل التغييرات =====
                await _unitOfWork.SaveChangesAsync();

                // ===== إعادة حساب الإجمالي والنقاط =====
                await RecalculateRoadmapTotalsAndPointsAsync(roadmap.Id);

                await _unitOfWork.CommitTransactionAsync();

                // ===== إعادة تحميل الرودماب النهائي =====
                var fullResult = await _unitOfWork.Roadmaps.GetByIdWithDetailsAsync(roadmap.Id);
                EnsureCollections(fullResult.Value);

                return fullResult.Value.Adapt<RoadmapResponse>() with
                {
                    LearningMaterials = fullResult.Value.LearningMaterials.Select(lm => new LearningMaterialResponse(
                        lm.Id,
                        lm.TitleVideos,
                        lm.TitlePdf,
                        lm.VideoDuration,
                        lm.PdfDuration,
                        lm.MaterialType,
                        lm.FilePath,
                        lm.Points
                    )).ToList()
                };
            }
            catch
            {
                await _unitOfWork.RollbackTransactionAsync();
                throw;
            }
        }

        // =================== UPDATE ===================
        public async Task<bool> UpdateAsync(string userId, int id, RoadmapRequest request, IFormFile? coverImage = null, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Roadmaps.GetByIdWithDetailsAsync(id);
            if (result.IsFailure)
                throw new InvalidOperationException(RoadmapErrors.RoadmapNotFound.Description);

            var roadmap = result.Value;

            var company = await _unitOfWork.companyAuthRepository.GetCompanyProfileByUserIdAsync(userId);
            var trainingCenter = await _unitOfWork.trainingCenterAuthRepository.GetTrainingCenterProfileByUserIdAsync(userId);

            bool isOwner = (company != null && roadmap.CompanyUserId == company.Id) ||
                           (trainingCenter != null && roadmap.TrainingCenterId == trainingCenter.Id);

            if (!isOwner)
                throw new InvalidOperationException("You are not allowed to edit this roadmap.");

            roadmap.Title = request.Title;
            roadmap.Description = request.Description;
            roadmap.TargetRole = request.TargetRole;
            roadmap.UpdatedAt = DateTime.UtcNow;
            roadmap.Price = request.Price ?? roadmap.Price;

            if (coverImage != null)
                roadmap.CoverImageUrl = await SaveFileAsync(coverImage, "covers", cancellationToken);

            _unitOfWork.Roadmaps.Update(roadmap);
            await _unitOfWork.SaveChangesAsync();
            await RecalculateRoadmapTotalsAndPointsAsync(roadmap.Id);

            return true;
        }

        // =================== DELETE ===================
        public async Task<bool> DeleteWithAllChildrenAsync(string userId, int id, CancellationToken cancellationToken = default)
        {
            // جلب الرودماب بالتفاصيل
            var result = await _unitOfWork.Roadmaps.GetByIdWithDetailsAsync(id);
            if (result.IsFailure)
                throw new InvalidOperationException(RoadmapErrors.RoadmapNotFound.Description);

            var roadmap = result.Value;

            // التأكد من الشركة
            var company = await _unitOfWork.companyAuthRepository.GetCompanyProfileByUserIdAsync(userId);
            if (company == null || roadmap.CompanyUserId != company.Id)
                throw new InvalidOperationException("You are not allowed to delete this roadmap.");

            // التأكد من أن المجموعات ليست null
            EnsureCollections(roadmap);

            // حذف كل العناصر المرتبطة بالرودماب
            foreach (var skill in roadmap.RequiredSkills)
            {
                _unitOfWork.RequiredSkills.Delete(skill);
            }

            foreach (var material in roadmap.LearningMaterials)
            {
                _unitOfWork.LearningMaterials.Delete(material);
            }

            foreach (var project in roadmap.Projects)
            {
                _unitOfWork.Projects.Delete(project);
            }

            foreach (var quiz in roadmap.Quizzes)
            {
                _unitOfWork.Quizzes.Delete(quiz);
            }

            // حذف الرودماب نفسه
            _unitOfWork.Roadmaps.Delete(roadmap);

            // حفظ التغييرات
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<bool> BulkDeleteAsync(string userId, List<int> ids, CancellationToken cancellationToken = default)
        {
            if (ids == null || !ids.Any())
                throw new InvalidOperationException(RoadmapErrors.RoadmapNoIdsProvided.Description);

            foreach (var id in ids)
            {
                await DeleteWithAllChildrenAsync(userId, id, cancellationToken);
            }
            return true;
        }

        public async Task<bool> IsTitleExistsAsync(string title, int? excludeId = null, CancellationToken cancellationToken = default)
            => await _unitOfWork.Roadmaps.IsTitleExistsAsync(title, excludeId);

        // =================== ENROLL ===================
        public async Task EnrollAsync(string userId, EnrollRoadmapRequest request, CancellationToken cancellationToken = default)
        {
            if (request == null) throw new ArgumentNullException(nameof(request));

            var roadmap = await _unitOfWork.Roadmaps.GetByIdAsync(request.RoadmapId);
            if (roadmap == null) throw new InvalidOperationException("Roadmap not found.");

            if (await _unitOfWork.userRoadmaps.IsJoinedAsync(userId, request.RoadmapId))
                throw new InvalidOperationException("User is already enrolled in this roadmap.");

            if (roadmap.Price > 0)
            {
                if (string.IsNullOrEmpty(request.StripePaymentId) || request.PaymentStatus != "Succeeded")
                    throw new InvalidOperationException("Payment is required to enroll in this roadmap.");
            }

            var userRoadmap = new UserRoadmap
            {
                UserId = userId,
                RoadmapId = request.RoadmapId,
                JoinedAt = DateTime.UtcNow,
                ProgressPercent = 0,
                Status = "In Progress"
            };

            await _unitOfWork.userRoadmaps.AddAsync(userRoadmap);
            await _unitOfWork.SaveChangesAsync();

            // ← الـ ownerId بيكون CompanyUserId أو UserId بتاع TrainingCenter
            var ownerId = roadmap.CompanyUserId ?? roadmap.TrainingCenter?.UserId;

            await _realTimeNotificationService.SendToUserAsync(userId, "Roadmap Enrollment", $"You have enrolled in '{roadmap.Title}'");

            if (!string.IsNullOrEmpty(ownerId))
                await _realTimeNotificationService.SendToUserAsync(ownerId, "New Enrollment", $"{userId} enrolled in '{roadmap.Title}'");
        }

        // =================== UNENROLL ===================
        public async Task<Result> UnenrollAsync(string userId, int roadmapId)
        {
            var enrollment = await _unitOfWork.userRoadmaps.FirstOrDefaultAsync(ur =>
     ur.UserId == userId && ur.RoadmapId == roadmapId);

            if (enrollment == null)
                return Result.Failure(new Error("UserRoadmap.NotEnrolled", "User is not enrolled in this roadmap."));

            // ← جيب الـ roadmap منفصل
            var roadmap = await _unitOfWork.Roadmaps.GetByIdAsync(roadmapId);
            if (roadmap == null)
                return Result.Failure(new Error("Roadmap.NotFound", "Roadmap not found."));

            _unitOfWork.userRoadmaps.Delete(enrollment);
            await _unitOfWork.SaveChangesAsync();

            var ownerId = roadmap.CompanyUserId ?? roadmap.TrainingCenter?.UserId;

            await _realTimeNotificationService.SendToUserAsync(userId, "Enrollment Cancelled", $"You have unenrolled from '{roadmap.Title}'");

            if (!string.IsNullOrEmpty(ownerId))
                await _realTimeNotificationService.SendToUserAsync(ownerId, "Student Cancelled Enrollment", $"{userId} cancelled enrollment in '{roadmap.Title}'");

            return Result.Success();
        }

        // =================== USER PROGRESS ===================
        public async Task UpdateProgressAsync(string userId, UpdateRoadmapProgressRequest request)
        {
            var roadmapResult = await _unitOfWork.Roadmaps.GetByIdWithDetailsAsync(request.RoadmapId);
            if (roadmapResult.IsFailure) throw new Exception("Roadmap not found.");

            var roadmap = roadmapResult.Value;
            EnsureCollections(roadmap);

            var enrollment = await _unitOfWork.userRoadmaps.GetByUserIdAndRoadmapAsync(userId, request.RoadmapId);
            if (enrollment == null) throw new Exception("Enrollment not found.");

            ProgressMaterialType materialType = request.ItemType.ToLower() switch
            {
                "material" => ProgressMaterialType.LearningMaterial,
                "learningmaterial" => ProgressMaterialType.LearningMaterial,
                "project" => ProgressMaterialType.Project,
                "quiz" => ProgressMaterialType.Quiz,
                _ => throw new Exception("Invalid item type.")
            };

            var itemProgress = enrollment.ProgressItems
                .FirstOrDefault(x => x.MaterialId == request.ItemId && x.MaterialType == materialType);

            if (itemProgress == null)
            {
                itemProgress = new UserProgress
                {
                    UserRoadmapId = enrollment.Id,
                    MaterialId = request.ItemId,
                    MaterialType = materialType
                };
                enrollment.ProgressItems.Add(itemProgress);
            }

            int itemPoints = materialType switch
            {
                ProgressMaterialType.LearningMaterial => roadmap.LearningMaterials.FirstOrDefault(x => x.Id == request.ItemId)?.Points ?? 0,
                ProgressMaterialType.Project => roadmap.Projects.FirstOrDefault(x => x.Id == request.ItemId)?.Points ?? 0,
                ProgressMaterialType.Quiz => roadmap.Quizzes.FirstOrDefault(x => x.Id == request.ItemId)?.Points ?? 0,
                _ => 0
            };

            if (!itemProgress.Completed)
            {
                itemProgress.Completed = true;
                itemProgress.PointsEarned = itemPoints;
                itemProgress.CompletedAt = DateTime.UtcNow;
            }

            int totalItems = roadmap.LearningMaterials.Count + roadmap.Projects.Count + roadmap.Quizzes.Count;
            int completedItems = enrollment.ProgressItems.Count(x => x.Completed);
            enrollment.ProgressPercent = totalItems == 0 ? 0 : (completedItems * 100) / totalItems;

            if (enrollment.ProgressPercent == 100)
            {
                enrollment.Status = "Completed";
                enrollment.CompletedAt = DateTime.UtcNow;

                var ownerId = roadmap.CompanyUserId ?? roadmap.TrainingCenter?.UserId;

                await _realTimeNotificationService.SendToUserAsync(userId, "Roadmap Completed 🎉", $"Congratulations! You completed '{roadmap.Title}'");

                if (!string.IsNullOrEmpty(ownerId))
                    await _realTimeNotificationService.SendToUserAsync(ownerId, "Student Completed Roadmap ✅", $"{userId} completed '{roadmap.Title}'");
            }

            await _unitOfWork.SaveChangesAsync();
        }

        public async Task<Result> AddOrUpdateUserProgressAsync(string userId, int userRoadmapId, int materialId, string materialType, int pointsEarned = 0)
        {
            ProgressMaterialType type = materialType.ToLower() switch
            {
                "material" => ProgressMaterialType.LearningMaterial,
                "learningmaterial" => ProgressMaterialType.LearningMaterial,
                "project" => ProgressMaterialType.Project,
                "quiz" => ProgressMaterialType.Quiz,
                _ => throw new ArgumentException("Invalid material type")
            };

            var progress = new UserProgress
            {
                UserRoadmapId = userRoadmapId,
                MaterialId = materialId,
                MaterialType = type,
                Completed = true,
                CompletedAt = DateTime.UtcNow,
                PointsEarned = pointsEarned
            };

            return await _userRoadmapRepository.AddOrUpdateProgressAsync(progress);
        }

        // =================== STATUS ===================
        public async Task<bool> ToggleStatusAsync(string userId, int id, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Roadmaps.GetByIdWithDetailsAsync(id);
            if (result.IsFailure)
                throw new InvalidOperationException(RoadmapErrors.RoadmapNotFound.Description);

            var roadmap = result.Value;
            roadmap.IsPublished = !roadmap.IsPublished;
            roadmap.UpdatedAt = DateTime.UtcNow;

            _unitOfWork.Roadmaps.Update(roadmap);
            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task<bool> BulkUpdateStatusAsync(string userId, List<int> ids, bool isPublished, CancellationToken cancellationToken = default)
        {
            if (ids == null || !ids.Any())
                throw new InvalidOperationException(RoadmapErrors.RoadmapNoIdsProvided.Description);

            foreach (var id in ids)
            {
                var result = await _unitOfWork.Roadmaps.GetByIdWithDetailsAsync(id);
                if (!result.IsFailure)
                {
                    var roadmap = result.Value;
                    roadmap.IsPublished = isPublished;
                    roadmap.UpdatedAt = DateTime.UtcNow;
                    _unitOfWork.Roadmaps.Update(roadmap);
                }
            }
            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        // =================== USER ROADMAPS ===================
        public async Task<IEnumerable<RoadmapCatalogItemResponse>> GetUserRoadmapsAsync(string userId, CancellationToken cancellationToken = default)
        {
            var userRoadmaps = await _unitOfWork.userRoadmaps.GetByUserIdAsync(userId);
            return userRoadmaps
                .Where(ur => ur.Roadmap != null)
                .Select(ur =>
                {
                    var roadmap = ur.Roadmap!;
                    return new RoadmapCatalogItemResponse(
                        RoadmapId: ur.RoadmapId,
                        Title: roadmap.Title,
                        TargetRole: roadmap.TargetRole,
                        CompanyName: roadmap.Company?.OrganizationName
                                  ?? roadmap.TrainingCenter?.Name  // ← عدل ده
                                  ?? "",
                        CoverImageUrl: roadmap.CoverImageUrl,
                        IsEnrolled: true,
                        ProgressPercent: ur.ProgressPercent,
                        Level: roadmap.RequiredSkills.FirstOrDefault()?.Level ?? "",
                        Skills: roadmap.RequiredSkills.Select(rs => rs.SkillName).ToList(),
                        IsAiPick: false
                    );
                }).ToList();
        }

        public async Task<RoadmapDetailsResponse> GetUserRoadmapDetailsAsync(string userId, int roadmapId, CancellationToken cancellationToken = default)
        {
            var userRoadmap = await _unitOfWork.userRoadmaps.GetByUserIdAndRoadmapAsync(userId, roadmapId);
            if (userRoadmap == null) throw new InvalidOperationException("User not enrolled in this roadmap.");

            var roadmap = userRoadmap.Roadmap ?? throw new InvalidOperationException("Roadmap not found.");
            var allProgress = userRoadmap.ProgressItems;
            var sections = new List<RoadmapSectionResponse>();

            if (roadmap.LearningMaterials?.Any() == true)
            {
                sections.Add(new RoadmapSectionResponse(
                    "Learning Materials",
                    roadmap.LearningMaterials.Select(m =>
                    {
                        var progress = allProgress.FirstOrDefault(p =>
                            p.MaterialId == m.Id && p.MaterialType == ProgressMaterialType.LearningMaterial);

                        return new RoadmapItemResponse(
                            m.Id,
                            m.TitleVideos ?? m.TitlePdf ?? string.Empty,
                            "Video",
                            progress?.Completed ?? false,
                            progress?.PointsEarned ?? 0,
                            m.FilePath,
                            null
                        );
                    }).ToList()
                ));
            }

            if (roadmap.Projects?.Any() == true)
            {
                sections.Add(new RoadmapSectionResponse(
                    "Projects",
                    roadmap.Projects.Select(p =>
                    {
                        var progress = allProgress.FirstOrDefault(pr =>
                            pr.MaterialId == p.Id && pr.MaterialType == ProgressMaterialType.Project);

                        return new RoadmapItemResponse(
                            p.Id,
                            p.Title,
                            "Project",
                            progress?.Completed ?? false,
                            progress?.PointsEarned ?? 0,
                            p.Description,
                            null
                        );
                    }).ToList()
                ));
            }

            if (roadmap.Quizzes?.Any() == true)
            {
                sections.Add(new RoadmapSectionResponse(
                    "Quizzes",
                    roadmap.Quizzes.Select(q =>
                    {
                        var progress = allProgress.FirstOrDefault(pr =>
                            pr.MaterialId == q.Id && pr.MaterialType == ProgressMaterialType.Quiz);

                        return new RoadmapItemResponse(
                            q.Id,
                            q.Title,
                            "Quiz",
                            progress?.Completed ?? false,
                            progress?.PointsEarned ?? 0,
                            null,
                            null
                        );
                    }).ToList()
                ));
            }

            return new RoadmapDetailsResponse(
                roadmap.Id,
                roadmap.Title,
                roadmap.Description,
                userRoadmap.ProgressPercent,
                sections
            );
        }
        // في RoadmapService.cs
        public async Task<RoadmapDetailsAnalyticsResponse> GetRoadmapDetailsAsync(string userId, int roadmapId, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Roadmaps.GetByIdWithDetailsAsync(roadmapId);
            if (result.IsFailure)
                throw new InvalidOperationException(RoadmapErrors.RoadmapNotFound.Description);

            var roadmap = result.Value;
            EnsureCollections(roadmap);

            // ← عدل الـ check
            var company = await _unitOfWork.companyAuthRepository.GetCompanyProfileByUserIdAsync(userId);
            var trainingCenter = await _unitOfWork.trainingCenterAuthRepository.GetTrainingCenterProfileByUserIdAsync(userId);

            bool isOwner = (company != null && roadmap.CompanyUserId == company.Id) ||
                           (trainingCenter != null && roadmap.TrainingCenterId == trainingCenter.Id);

            if (!isOwner)
                throw new InvalidOperationException("You are not allowed to view this roadmap details.");

            var enrollments = await _unitOfWork.userRoadmaps.GetByRoadmapIdAsync(roadmapId);

            int enrolledCount = enrollments.Count();
            int completedCount = enrollments.Count(e => e.Status == "Completed");
            double completionRate = enrolledCount == 0 ? 0 : Math.Round((completedCount * 100.0) / enrolledCount, 2);
            double averageProgress = enrolledCount == 0 ? 0 : Math.Round(enrollments.Average(e => e.ProgressPercent), 2);

            return new RoadmapDetailsAnalyticsResponse(
                roadmap.Id,
                roadmap.Title,
                roadmap.Description,
                roadmap.TargetRole,
                roadmap.CoverImageUrl,
                roadmap.IsPublished,
                roadmap.CreatedAt,
                enrolledCount,
                completedCount,
                completionRate,
                averageProgress,
                roadmap.TotalMaterials,
                roadmap.TotalProjects,
                roadmap.TotalQuizzes,
                roadmap.TotalPoints
            );
        }

        public async Task<Result<int>> GetOrCreateQuizAttemptIdAsync(string userId, int quizId)
        {
            var attemptResult = await _unitOfWork.quizAttemptRepository.GetByUserAndQuizAsync(userId, quizId);

            // لو موجود رجعه
            if (!attemptResult.IsFailure && attemptResult.Value != null)
                return Result.Success(attemptResult.Value.Id);

            // لو مش موجود، اعمل جديد
            var newAttempt = new QuizAttempt
            {
                UserId = userId,
                QuizId = quizId,
                StartedAt = DateTime.UtcNow
            };

            await _unitOfWork.quizAttemptRepository.AddAsync(newAttempt);
            await _unitOfWork.SaveChangesAsync();

            return Result.Success(newAttempt.Id);
        }
        public async Task<Result> AddAiGeneratedQuizAsync(int roadmapId, string quizTitle, List<Question> generatedQuestions)
        {
            if (generatedQuestions == null || !generatedQuestions.Any())
                return Result.Failure(new Error("AIQuiz.Empty", "No questions were provided by AI."));

            // نبدأ Transaction لأننا سنعدل في 3 جداول (Quizzes, Questions, Roadmaps)
            await _unitOfWork.BeginTransactionAsync();
            try
            {
                // 1. التحقق من وجود الرودماب
                var result = await _unitOfWork.Roadmaps.GetByIdAsync(roadmapId);
                if (result == null)
                    return Result.Failure(new Error("Roadmap.NotFound", "Roadmap not found."));

                // 2. إنشاء كائن الكويز (Section 6)
                var aiQuiz = new QuizzesSec6
                {
                    RoadmapId = roadmapId,
                    Title = quizTitle,
                    Type = "AI", // تمييزه كـ AI Generated
                    Points = generatedQuestions.Count * 10, // تعيين 10 نقاط لكل سؤال تلقائياً
                    CreatedAt = DateTime.UtcNow
                };

                // إضافة الكويز للحصول على الـ Id الخاص به
                await _unitOfWork.Quizzes.AddAsync(aiQuiz);
                await _unitOfWork.SaveChangesAsync();

                // 3. ربط الأسئلة بـ Id الكويز الجديد وإضافتها
                foreach (var q in generatedQuestions)
                {
                    q.QuizId = aiQuiz.Id; // ربط ForeignKey
                    await _unitOfWork.Questions.AddAsync(q);
                }

                // حفظ الأسئلة
                await _unitOfWork.SaveChangesAsync();

                // 4. إعادة حساب الإجماليات والنقاط للـ Roadmap 
                // (نستخدم الميثود الموجودة عندك فعلياً في السرفيس)
                await RecalculateRoadmapTotalsAndPointsAsync(roadmapId);

                // 5. اعتماد التغييرات نهائياً
                await _unitOfWork.CommitTransactionAsync();

                return Result.Success();
            }
            catch (Exception ex)
            {
                // في حالة حدوث أي خطأ نلغي كل العمليات السابقة
                await _unitOfWork.RollbackTransactionAsync();
                return Result.Failure(new Error("AIQuiz.SaveError", $"Failed to save AI quiz: {ex.Message}"));
            }
        }


    }
}
