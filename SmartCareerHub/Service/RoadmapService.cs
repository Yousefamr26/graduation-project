using Business_Logic.IService;
using Business_Logic.Errors;
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
    public class RoadmapService : IRoadmapService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly string _roadmapsPath;

        public RoadmapService(IUnitOfWork unitOfWork, IWebHostEnvironment env)
        {
            _unitOfWork = unitOfWork;
            _roadmapsPath = Path.Combine(env.WebRootPath ?? "wwwroot", "uploads", "roadmaps");
            if (!Directory.Exists(_roadmapsPath))
                Directory.CreateDirectory(_roadmapsPath);
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

        public async Task<IEnumerable<RoadmapResponse>> GetAllAsync(CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Roadmaps.GetAllWithDetailsAsync();
            if (result.IsFailure) return Enumerable.Empty<RoadmapResponse>();

            foreach (var roadmap in result.Value)
                EnsureCollections(roadmap);

            return result.Value.Adapt<IEnumerable<RoadmapResponse>>();
        }

        public async Task<RoadmapResponse?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Roadmaps.GetByIdWithDetailsAsync(id);
            if (result.IsFailure)
                throw new InvalidOperationException(RoadmapErrors.RoadmapNotFound.Description);

            EnsureCollections(result.Value);
            return result.Value.Adapt<RoadmapResponse>();
        }

        public async Task<RoadmapResponse> AddAsync(RoadmapRequest request, CancellationToken cancellationToken = default)
        {
            await _unitOfWork.BeginTransactionAsync();
            try
            {
                if (await IsTitleExistsAsync(request.Title))
                    throw new InvalidOperationException(RoadmapErrors.RoadmapTitleExists.Description);

                var roadmap = request.Adapt<RoadmapSec1>();
                roadmap.CreatedAt = DateTime.UtcNow;
                roadmap.CoverImageUrl = request.CoverImage != null
                    ? await SaveFileAsync(request.CoverImage, "covers", cancellationToken)
                    : null;

                var addResult = await _unitOfWork.Roadmaps.AddRoadmapAsync(roadmap);
                if (addResult.IsFailure)
                    throw new InvalidOperationException(RoadmapErrors.RoadmapCreationFailed.Description);

                roadmap = addResult.Value;

                // Required Skills
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

                // Learning Materials
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

                // Projects
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

                // Quizzes
                if (request.QuizRequests?.Any() == true)
                {
                    foreach (var q in request.QuizRequests)
                    {
                        var quiz = new QuizzesSec6
                        {
                            RoadmapId = roadmap.Id,
                            Title = q.Title,
                            Type = q.Type,
                            Points = q.Points,
                            Questions = new List<Question>()
                        };

                        if (q.Type.Equals("FileUpload", StringComparison.OrdinalIgnoreCase))
                        {
                            if (q.QuestionsFile != null)
                            {
                                quiz.QuestionsFile = await SaveFileAsync(q.QuestionsFile, "quizzes", cancellationToken);
                            }
                            else
                            {
                                throw new InvalidOperationException(RoadmapErrors.RoadmapInvalidRequest.Description);
                            }
                        }
                        else
                        {
                            if (q.QuestionRequests?.Any() == true)
                            {
                                quiz.Questions = q.QuestionRequests.Select(qr => new Question
                                {
                                    Text = qr.Text,
                                    Type = qr.Type,
                                    OptionsJson = qr.OptionsJson,
                                    CorrectAnswer = qr.CorrectAnswer
                                }).ToList();
                            }
                        }

                        await _unitOfWork.Quizzes.AddAsync(quiz);
                    }
                }

                await _unitOfWork.SaveChangesAsync();
                await RecalculateRoadmapTotalsAndPointsAsync(roadmap.Id);
                await _unitOfWork.CommitTransactionAsync();

                var fullResult = await _unitOfWork.Roadmaps.GetByIdWithDetailsAsync(roadmap.Id);
                if (fullResult.IsFailure)
                    throw new InvalidOperationException(RoadmapErrors.RoadmapNotFound.Description);

                EnsureCollections(fullResult.Value);
                return fullResult.Value.Adapt<RoadmapResponse>();
            }
            catch
            {
                await _unitOfWork.RollbackTransactionAsync();
                throw;
            }
        }

        public async Task<bool> UpdateAsync(int id, RoadmapRequest request, IFormFile? coverImage = null, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Roadmaps.GetByIdWithDetailsAsync(id);
            if (result.IsFailure)
                throw new InvalidOperationException(RoadmapErrors.RoadmapNotFound.Description);

            var roadmap = result.Value;
            roadmap.Title = request.Title;
            roadmap.Description = request.Description;
            roadmap.TargetRole = request.TargetRole;
            roadmap.UpdatedAt = DateTime.UtcNow;

            if (coverImage != null)
                roadmap.CoverImageUrl = await SaveFileAsync(coverImage, "covers", cancellationToken);

            _unitOfWork.Roadmaps.Update(roadmap);
            await _unitOfWork.SaveChangesAsync();
            await RecalculateRoadmapTotalsAndPointsAsync(roadmap.Id);

            return true;
        }

        public async Task<bool> ToggleStatusAsync(int id, CancellationToken cancellationToken = default)
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

        public async Task<bool> DeleteWithAllChildrenAsync(int id, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Roadmaps.GetByIdWithDetailsAsync(id);
            if (result.IsFailure)
                throw new InvalidOperationException(RoadmapErrors.RoadmapNotFound.Description);

            var roadmap = result.Value;
            EnsureCollections(roadmap);

            foreach (var skill in roadmap.RequiredSkills)
                _unitOfWork.RequiredSkills.Delete(skill);

            foreach (var material in roadmap.LearningMaterials)
                _unitOfWork.LearningMaterials.Delete(material);

            foreach (var project in roadmap.Projects)
                _unitOfWork.Projects.Delete(project);

            foreach (var quiz in roadmap.Quizzes)
                _unitOfWork.Quizzes.Delete(quiz);

            _unitOfWork.Roadmaps.Delete(roadmap);
            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task<bool> BulkUpdateStatusAsync(List<int> ids, bool isPublished, CancellationToken cancellationToken = default)
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

        public async Task<bool> BulkDeleteAsync(List<int> ids, CancellationToken cancellationToken = default)
        {
            if (ids == null || !ids.Any())
                throw new InvalidOperationException(RoadmapErrors.RoadmapNoIdsProvided.Description);

            foreach (var id in ids)
            {
                await DeleteWithAllChildrenAsync(id, cancellationToken);
            }
            return true;
        }

        public async Task<bool> IsTitleExistsAsync(string title, int? excludeId = null, CancellationToken cancellationToken = default)
        {
            return await _unitOfWork.Roadmaps.IsTitleExistsAsync(title, excludeId);
        }
    }
}
