using Mapster;
using DataAccess.Entities.RoadMap;
using SmartCareerHub.Contracts.Company.CreateRoadmap;
using System;
using System.Collections.Generic;

public static class RoadmapMappingConfig
{
    public static void RegisterMappings()
    {
        // ========= Roadmap Mapping =========
        TypeAdapterConfig<RoadmapSec1, RoadmapResponse>
            .NewConfig()
            .MapWith(src => new RoadmapResponse(
                src.Id,
                src.Title ?? string.Empty,
                src.Description ?? string.Empty,
                src.TargetRole ?? string.Empty,
                src.CoverImageUrl ?? string.Empty,
                src.StartDate,
                src.EndDate,
                src.IsPublished,
                src.CreatedAt,
                src.TotalPoints,
                src.RequiredSkills != null
                    ? src.RequiredSkills.Adapt<List<RequiredSkillResponse>>()
                    : new List<RequiredSkillResponse>(),
                src.Projects != null
                    ? src.Projects.Adapt<List<ProjectResponse>>()
                    : new List<ProjectResponse>(),
                src.Quizzes != null
                    ? src.Quizzes.Adapt<List<QuizResponse>>()
                    : new List<QuizResponse>(),
                src.LearningMaterials != null
                    ? src.LearningMaterials.Adapt<List<LearningMaterialResponse>>()
                    : new List<LearningMaterialResponse>()
            ));

        // ========= RequiredSkill Mapping =========
        TypeAdapterConfig<RequiredSkillSec2, RequiredSkillResponse>
            .NewConfig()
            .MapWith(src => new RequiredSkillResponse(
                src.Id,
                src.SkillName ?? string.Empty,
                src.Level ?? string.Empty,
                src.Points
            ));

        // ========= LearningMaterial Mapping =========
        TypeAdapterConfig<LearningMaterialSec34, LearningMaterialResponse>
            .NewConfig()
            .MapWith(src => new LearningMaterialResponse(
                src.Id,
                src.TitleVideos ?? string.Empty,
                src.TitlePdf ?? string.Empty,
                src.VideoDuration != null ? src.VideoDuration.ToString() : null,
                src.PdfDuration != null ? src.PdfDuration.ToString() : null,
                src.MaterialType.ToString(),
                src.FilePath ?? string.Empty
            ));

        // ========= Project Mapping =========
        TypeAdapterConfig<ProjectSec5, ProjectResponse>
            .NewConfig()
            .MapWith(src => new ProjectResponse(
                src.Id,
                src.Title ?? string.Empty,
                src.Description ?? string.Empty,
                src.Difficulty.ToString(),
                src.Points
            ));

        // ========= Quiz Mapping =========
        TypeAdapterConfig<QuizzesSec6, QuizResponse>
            .NewConfig()
            .MapWith(src => new QuizResponse(
                src.Id,
                src.Title ?? string.Empty,
                src.Type.ToString(),
                src.QuestionsFile ?? string.Empty,
                src.Points,
                src.RoadmapId,
                src.Questions != null
                    ? src.Questions.Adapt<IEnumerable<QuestionResponse>>()
                    : new List<QuestionResponse>()
            ));

        // ========= Question Mapping =========
        TypeAdapterConfig<Question, QuestionResponse>
            .NewConfig()
            .MapWith(src => new QuestionResponse(
                src.Id,
                src.Text ?? string.Empty,
                src.Type ?? string.Empty,
                src.OptionsJson ?? string.Empty,
                src.CorrectAnswer ?? string.Empty,
                src.Answers != null
                    ? src.Answers.Adapt<IEnumerable<QuizAnswerResponse>>()
                    : new List<QuizAnswerResponse>()
            ));

        // ========= QuizAnswer Mapping =========
        // Fix for CS7036: Use constructor with required parameters for QuizAnswerResponse
        TypeAdapterConfig<QuizAnswer, QuizAnswerResponse>
            .NewConfig()
            .MapWith(src => new QuizAnswerResponse(
                src.Id,
                src.UserId,
                src.AnswerText ?? string.Empty,
                src.FileUrl ?? string.Empty
            ));
    }
}
