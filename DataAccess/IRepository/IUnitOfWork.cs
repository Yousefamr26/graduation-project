using System;
using System.Threading.Tasks;

namespace DataAccess.IRepository
{
    public interface IUnitOfWork : IDisposable
    {
        IRoadmapRepository Roadmaps { get; }
        IRequiredSkillRepository RequiredSkills { get; }
        ILearningMaterialRepository LearningMaterials { get; }
        IProjectRepository Projects { get; }
        IQuizRepository Quizzes { get; } 

        IWorkshopRepository Workshops { get; }
        IWorkshopMaterialRepository WorkshopMaterials { get; }
        IWorkshopActivityRepository WorkshopActivities { get; }

        IEventRepository Events { get; }
        IJobRepository Jobs { get; }
        IInterviewRepository Interviews { get; }
        IQuestionRepository Questions { get; }
        IQuizAnswerRepository QuizAnswers { get; }


        IRoadmapAnalyticsRepository RoadmapAnalytics { get; }
        IWorkshopAnalyticsRepository WorkshopAnalytics { get; }
        IEventAnalyticsRepository EventAnalytics { get; }
        IJobAnalyticsRepository JobAnalytics { get; }
        IInterviewAnalyticsRepository InterviewAnalytics { get; }
        ICompanyAuthRepository companyAuthRepository { get; }

        Task<int> SaveChangesAsync();
        Task BeginTransactionAsync();
        Task CommitTransactionAsync();
        Task RollbackTransactionAsync();
    }
}
