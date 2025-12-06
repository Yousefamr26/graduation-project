using DataAccess.Contexts;
using DataAccess.IRepository;
using Microsoft.EntityFrameworkCore.Storage;
using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;

namespace DataAccess.Repository
{
    public class UnitOfWork : IUnitOfWork
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<ApplicationUser> _userManager;
        private IDbContextTransaction _transaction;

        // Repositories
        private IRoadmapRepository _roadmaps;
        private IRequiredSkillRepository _requiredSkills;
        private ILearningMaterialRepository _learningMaterials;
        private IProjectRepository _projects;
        private IQuizRepository _quizzes;

        private IWorkshopRepository _workshops;
        private IWorkshopMaterialRepository _workshopMaterials;
        private IWorkshopActivityRepository _workshopActivities;

        private IEventRepository _events;
        private IJobRepository _jobs;
        private IInterviewRepository _interviews;

        private IRoadmapAnalyticsRepository _roadmapAnalytics;
        private IWorkshopAnalyticsRepository _workshopAnalytics;
        private IEventAnalyticsRepository _eventAnalytics;
        private IJobAnalyticsRepository _jobAnalytics;
        private IInterviewAnalyticsRepository _interviewAnalytics;

        private ICompanyAuthRepository _companyAuthRepository;

        public UnitOfWork(ApplicationDbContext context, UserManager<ApplicationUser> userManager)
        {
            _context = context;
            _userManager = userManager;
        }

        // Repository properties
        public IRoadmapRepository Roadmaps => _roadmaps ??= new RoadmapRepository(_context);
        public IRequiredSkillRepository RequiredSkills => _requiredSkills ??= new RequiredSkillRepository(_context);
        public ILearningMaterialRepository LearningMaterials => _learningMaterials ??= new LearningMaterialRepository(_context);
        public IProjectRepository Projects => _projects ??= new ProjectRepository(_context);
        public IQuizRepository Quizzes => _quizzes ??= new QuizRepository(_context);

        public IWorkshopRepository Workshops => _workshops ??= new WorkshopRepository(_context);
        public IWorkshopMaterialRepository WorkshopMaterials => _workshopMaterials ??= new WorkshopMaterialRepository(_context);
        public IWorkshopActivityRepository WorkshopActivities => _workshopActivities ??= new WorkshopActivityRepository(_context);

        public IEventRepository Events => _events ??= new EventRepository(_context);
        public IJobRepository Jobs => _jobs ??= new JobRepository(_context);
        public IInterviewRepository Interviews => _interviews ??= new InterviewRepository(_context);

        public IRoadmapAnalyticsRepository RoadmapAnalytics => _roadmapAnalytics ??= new RoadmapAnalyticsRepository(_context);
        public IWorkshopAnalyticsRepository WorkshopAnalytics => _workshopAnalytics ??= new WorkshopAnalyticsRepository(_context);
        public IEventAnalyticsRepository EventAnalytics => _eventAnalytics ??= new EventAnalyticsRepository(_context);
        public IJobAnalyticsRepository JobAnalytics => _jobAnalytics ??= new JobAnalyticsRepository(_context);
        public IInterviewAnalyticsRepository InterviewAnalytics => _interviewAnalytics ??= new InterviewAnalyticsRepository(_context);

        public ICompanyAuthRepository companyAuthRepository =>
            _companyAuthRepository ??= new CompanyAuthRepository(_userManager, _context);
        private IQuestionRepository _questions;
        private IQuizAnswerRepository _quizAnswers;

        public IQuestionRepository Questions => _questions ??= new QuestionRepository(_context);
        public IQuizAnswerRepository QuizAnswers => _quizAnswers ??= new QuizAnswerRepository(_context);


        // Transaction methods
        public async Task<int> SaveChangesAsync() => await _context.SaveChangesAsync();

        public async Task BeginTransactionAsync() => _transaction = await _context.Database.BeginTransactionAsync();

        public async Task CommitTransactionAsync()
        {
            try
            {
                await _context.SaveChangesAsync();
                await _transaction.CommitAsync();
            }
            catch
            {
                await RollbackTransactionAsync();
                throw;
            }
            finally
            {
                if (_transaction != null)
                {
                    await _transaction.DisposeAsync();
                    _transaction = null;
                }
            }
        }

        public async Task RollbackTransactionAsync()
        {
            if (_transaction != null)
            {
                await _transaction.RollbackAsync();
                await _transaction.DisposeAsync();
                _transaction = null;
            }
        }

        public void Dispose()
        {
            _transaction?.Dispose();
            _context?.Dispose();
        }
    }
}
