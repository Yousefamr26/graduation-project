using DataAccess.Contexts;
using DataAccess.Entities.Job;
using DataAccess.Entities.Users;
using DataAccess.IRepository;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore.Storage;

namespace DataAccess.Repository
{
    public class UnitOfWork : IUnitOfWork, IDisposable
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private IDbContextTransaction _transaction;


        // -------- Core --------
        private IRoadmapRepository _roadmaps;
        private IRequiredSkillRepository _requiredSkills;
        private ILearningMaterialRepository _learningMaterials;
        private IProjectRepository _projects;
        private IQuizRepository _quizzes;
        private IWorkshopRepository _workshops;
        private IWorkshopMaterialRepository _workshopMaterials;
        private IWorkshopActivityRepository _workshopActivities;
        private IWorkshopEnrollmentRepository _workshopEnrollments;
        private IInternshipRepository _internshipRepository;
        private IInternshipApplicationRepository _internshipApplicationRepository;
        private IEventRepository _events;
        private IJobRepository _jobs;
        private IJobApplicationRepository _jobApplications;
        private IInterviewRepository _interviews;
        private ICVTemplateRepository _cvTemplateRepository;
        private ICertificateRepository _certificates;



        // -------- Analytics --------
        private IRoadmapAnalyticsRepository _roadmapAnalytics;
        private IWorkshopAnalyticsRepository _workshopAnalytics;
        private IEventAnalyticsRepository _eventAnalytics;
        private IJobAnalyticsRepository _jobAnalytics;
        private IInterviewAnalyticsRepository _interviewAnalytics;
        private IInternshipAnalyticsRepository _internshipAnalytics;
        private IUniversityAnalyticsRepository _universityAnalytics;


        // -------- Auth --------
        private IStudentAuthRepository _studentAuthRepository;
        private IGraduateAuthRepository _graduateAuthRepository;
        private ICompanyAuthRepository _companyAuthRepository;
        private IUniversityAuthRepository _universityAuthRepository;
        private ITrainingCenterAuthRepository _trainingCenterAuthRepository;

        // -------- Other --------
        private IuserProgressRepository _userProgressRepository;
        private IUserRoadmapRepository _userRoadmapRepository;
        private IUserRoadmapItemProgressRepository _userRoadmapItemProgressRepository;
        private IQuestionRepository _questions;
        private IQuizAnswerRepository _quizAnswers;
        private IEventEnrollmentRepository _eventEnrollments;
        private IUserCVRepository _userCVRepository;
        private IPartnershipRepository _partnershipRepository;
        private IQuizAttemptRepository _quizAttemptRepository;

        public UnitOfWork(
            ApplicationDbContext context,
            UserManager<ApplicationUser> userManager,
            SignInManager<ApplicationUser> signInManager)
        {
            _context = context;
            _userManager = userManager;
            _signInManager = signInManager;
        }

        // -------- Core Properties --------
        public IRoadmapRepository Roadmaps =>
            _roadmaps ??= new RoadmapRepository(_context);
        public IRequiredSkillRepository RequiredSkills =>
            _requiredSkills ??= new RequiredSkillRepository(_context);
        public ILearningMaterialRepository LearningMaterials =>
            _learningMaterials ??= new LearningMaterialRepository(_context);
        public IProjectRepository Projects =>
            _projects ??= new ProjectRepository(_context);
        public IQuizRepository Quizzes =>
            _quizzes ??= new QuizRepository(_context);
        public IWorkshopRepository Workshops =>
            _workshops ??= new WorkshopRepository(_context);
        public IWorkshopMaterialRepository WorkshopMaterials =>
            _workshopMaterials ??= new WorkshopMaterialRepository(_context);
        public IWorkshopActivityRepository WorkshopActivities =>
            _workshopActivities ??= new WorkshopActivityRepository(_context);
        public IEventRepository Events =>
            _events ??= new EventRepository(_context);
        public IJobRepository Jobs =>
            _jobs ??= new JobRepository(_context);
        public IInterviewRepository Interviews =>
            _interviews ??= new InterviewRepository(_context);

        // -------- Analytics Properties --------
        public IRoadmapAnalyticsRepository RoadmapAnalytics =>
            _roadmapAnalytics ??= new RoadmapAnalyticsRepository(_context);
        public IWorkshopAnalyticsRepository WorkshopAnalytics =>
            _workshopAnalytics ??= new WorkshopAnalyticsRepository(_context);
        public IEventAnalyticsRepository EventAnalytics =>
            _eventAnalytics ??= new EventAnalyticsRepository(_context);
        public IJobAnalyticsRepository JobAnalytics =>
            _jobAnalytics ??= new JobAnalyticsRepository(_context);
        public IInterviewAnalyticsRepository InterviewAnalytics =>
            _interviewAnalytics ??= new InterviewAnalyticsRepository(_context);
        public IInternshipAnalyticsRepository InternshipAnalytics =>
            _internshipAnalytics ??= new InternshipAnalyticsRepository(_context);
        public IUniversityAnalyticsRepository UniversityAnalytics =>
            _universityAnalytics ??= new UniversityAnalyticsRepository(_context);

        // -------- Auth Properties --------
        public IStudentAuthRepository studentAuthRepository =>
            _studentAuthRepository ??= new StudentAuthRepository(_userManager, _signInManager, _context);
        public IGraduateAuthRepository graduateAuthRepository =>
            _graduateAuthRepository ??= new GraduateAuthRepository(_userManager, _signInManager, _context);
        public ICompanyAuthRepository companyAuthRepository =>
            _companyAuthRepository ??= new CompanyAuthRepository(_userManager, _signInManager, _context);
        public IUniversityAuthRepository universityAuthRepository =>
            _universityAuthRepository ??= new UniversityAuthRepository(_userManager, _signInManager, _context);

        // -------- Other Properties --------
        public IQuestionRepository Questions =>
            _questions ??= new QuestionRepository(_context);
        public IQuizAnswerRepository QuizAnswers =>
           _quizAnswers ??= new QuizAnswerRepository(_context);
        public IEventEnrollmentRepository EventEnrollments =>
            _eventEnrollments ??= new EventEnrollmentRepository(_context);
        public IUserCVRepository userCVRepository =>
            _userCVRepository ??= new UserCVRepository(_context);
        public IJobApplicationRepository jobApplicationRepository =>
            _jobApplications ??= new JobApplicationRepository(_context);
        public IuserProgressRepository userProgress =>
            _userProgressRepository ??= new UserProgressRepository(_context);
        public IUserRoadmapRepository userRoadmaps =>
            _userRoadmapRepository ??= new UserRoadmapRepository(_context);
        public IUserRoadmapItemProgressRepository userRoadmapItemProgressRepository =>
            _userRoadmapItemProgressRepository ??= new UserRoadmapItemProgressRepository(_context);
        public IWorkshopEnrollmentRepository workshopEnrollments =>
            _workshopEnrollments ??= new WorkshopEnrollmentRepository(_context);
        public IInternshipRepository internshipRepository =>
            _internshipRepository ??= new InternshipRepository(_context);
        public IInternshipApplicationRepository internshipApplicationRepository =>
            _internshipApplicationRepository ??= new InternshipApplicationRepository(_context);
        public IPartnershipRepository partnershipRepository =>
            _partnershipRepository ??= new PartnershipRepository(_context);

        public ITrainingCenterAuthRepository trainingCenterAuthRepository =>
          _trainingCenterAuthRepository ??= new TrainingCenterAuthRepository(_userManager, _signInManager, _context);

        public IQuizAttemptRepository quizAttemptRepository => new QuizAttemptRepository(_context);

        public ICVTemplateRepository cvTemplateRepository => new CVTemplateRepository(_context);
        public ICertificateRepository Certificates =>
    _certificates ??= new CertificateRepository(_context);


        // -------- Transactions --------
        public async Task<int> SaveChangesAsync() =>
            await _context.SaveChangesAsync();
        public async Task BeginTransactionAsync() =>
            _transaction = await _context.Database.BeginTransactionAsync();
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