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

        // -------- Analytics --------
        IRoadmapAnalyticsRepository RoadmapAnalytics { get; }
        IWorkshopAnalyticsRepository WorkshopAnalytics { get; }
        IEventAnalyticsRepository EventAnalytics { get; }
        IJobAnalyticsRepository JobAnalytics { get; }
        IInterviewAnalyticsRepository InterviewAnalytics { get; }
        IInternshipAnalyticsRepository InternshipAnalytics { get; }
        IUniversityAnalyticsRepository UniversityAnalytics { get; }

        // -------- Auth --------
        ICompanyAuthRepository companyAuthRepository { get; }
        IStudentAuthRepository studentAuthRepository { get; }
        IGraduateAuthRepository graduateAuthRepository { get; }
        IUniversityAuthRepository universityAuthRepository { get; }
        ITrainingCenterAuthRepository trainingCenterAuthRepository { get; }

        // -------- Other --------
        IJobApplicationRepository jobApplicationRepository { get; }
        IInternshipRepository internshipRepository { get; }
        IInternshipApplicationRepository internshipApplicationRepository { get; }
        IuserProgressRepository userProgress { get; }
        IUserRoadmapRepository userRoadmaps { get; }
        IUserRoadmapItemProgressRepository userRoadmapItemProgressRepository { get; }
        IWorkshopEnrollmentRepository workshopEnrollments { get; }
        IEventEnrollmentRepository EventEnrollments { get; }
        IUserCVRepository userCVRepository { get; }
        IPartnershipRepository partnershipRepository { get; }
        IQuizAttemptRepository quizAttemptRepository { get; }
        ICVTemplateRepository cvTemplateRepository { get; }
        ICertificateRepository Certificates { get; }

        Task<int> SaveChangesAsync();
        Task BeginTransactionAsync();
        Task CommitTransactionAsync();
        Task RollbackTransactionAsync();
    }
}