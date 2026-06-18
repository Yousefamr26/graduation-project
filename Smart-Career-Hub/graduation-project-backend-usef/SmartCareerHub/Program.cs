using Business_Logic.IService;
using Business_Logic.Service;
using Business_Logic.Services;
using DataAccess.Contexts;
using DataAccess.IRepository;
using DataAccess.Repository;
using FluentValidation;
using FluentValidation.AspNetCore;
using Mapster;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using SmartCareerHub;
using SmartCareerHub.IService.UserProfileService;
using SmartCareerHub.Service.UserProfileService;
using SmartCareerHub.Services;
using Stripe;
using System.Text;
using System.Text.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);

builder.WebHost.UseWebRoot("wwwroot");

// ===== DbContext =====
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("SmartCareerHub")
    )
);

// ===== Identity =====
builder.Services.AddIdentity<ApplicationUser, IdentityRole>(options =>
{
    options.Password.RequireDigit = true;
    options.Password.RequireLowercase = true;
    options.Password.RequireUppercase = true;
    options.Password.RequireNonAlphanumeric = true;
    options.Password.RequiredLength = 8;

    options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(5);
    options.Lockout.MaxFailedAccessAttempts = 5;
    options.Lockout.AllowedForNewUsers = true;

    options.User.RequireUniqueEmail = true;

    options.SignIn.RequireConfirmedEmail = false;
    options.SignIn.RequireConfirmedPhoneNumber = false;
})
.AddEntityFrameworkStores<ApplicationDbContext>()
.AddDefaultTokenProviders();

// ===== Authentication (JWT) =====
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.SaveToken = true;
    options.RequireHttpsMetadata = false;

    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidAudience = builder.Configuration["Jwt:Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!))
    };

    options.Events = new JwtBearerEvents
    {
        OnMessageReceived = context =>
        {
            var accessToken = context.Request.Query["access_token"];

            var path = context.HttpContext.Request.Path;
            if (!string.IsNullOrEmpty(accessToken) &&
                (path.StartsWithSegments("/notificationHub") ||
                 path.StartsWithSegments("/hubs/chat")))
            {
                context.Token = accessToken;
            }

            return Task.CompletedTask;
        }
    };
});

// ===== Controllers + JSON options + FluentValidation =====
builder.Services.AddControllers()
    .AddJsonOptions(o =>
    {
        o.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
        o.JsonSerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
    })
    .AddFluentValidation(fv =>
    {
        fv.RegisterValidatorsFromAssemblyContaining<Program>();
    });

// ===== Repositories =====
builder.Services.AddScoped<IRoadmapAnalyticsRepository, RoadmapAnalyticsRepository>();
builder.Services.AddScoped<IRequiredSkillRepository, RequiredSkillRepository>();
builder.Services.AddScoped<ILearningMaterialRepository, LearningMaterialRepository>();
builder.Services.AddScoped<IProjectRepository, ProjectRepository>();
builder.Services.AddScoped<IQuizRepository, QuizRepository>();
builder.Services.AddScoped<IQuestionRepository, QuestionRepository>();
builder.Services.AddScoped<IWorkshopAnalyticsRepository, WorkshopAnalyticsRepository>();
builder.Services.AddScoped<IWorkshopMaterialRepository, WorkshopMaterialRepository>();
builder.Services.AddScoped<IWorkshopActivityRepository, WorkshopActivityRepository>();
builder.Services.AddScoped<IEventAnalyticsRepository, EventAnalyticsRepository>();
builder.Services.AddScoped<IJobAnalyticsRepository, JobAnalyticsRepository>();
builder.Services.AddScoped<IInterviewRepository, InterviewRepository>();
builder.Services.AddScoped<ICompanyAuthRepository, CompanyAuthRepository>();
builder.Services.AddScoped<IStudentAuthRepository, StudentAuthRepository>();
builder.Services.AddScoped<IGraduateAuthRepository, GraduateAuthRepository>();
builder.Services.AddScoped<IUserRoadmapRepository, UserRoadmapRepository>();
builder.Services.AddScoped<IuserProgressRepository, UserProgressRepository>();
builder.Services.AddScoped<IEventEnrollmentRepository, EventEnrollmentRepository>();
builder.Services.AddScoped<IUserCVRepository, UserCVRepository>();
builder.Services.AddScoped<IJobApplicationRepository, JobApplicationRepository>();
builder.Services.AddScoped<IWorkshopEnrollmentRepository, WorkshopEnrollmentRepository>();
builder.Services.AddScoped<IPartnershipRepository, PartnershipRepository>();
builder.Services.AddScoped<IUniversityAuthRepository, UniversityAuthRepository>();
builder.Services.AddScoped<ICandidateRepository, CandidateRepository>();
builder.Services.AddScoped<ITrainingCenterAuthRepository, TrainingCenterAuthRepository>();
builder.Services.AddScoped<ICVTemplateRepository, CVTemplateRepository>();

// ===== Services =====
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
builder.Services.AddScoped<IRoadmapService, RoadmapService>();
builder.Services.AddHttpClient<IQuizService, QuizService>(client =>
{
    client.Timeout = TimeSpan.FromSeconds(120); 
});
builder.Services.AddScoped<IWorkshopService, WorkshopService>();
builder.Services.AddScoped<IWorkshopActivityService, WorkshopActivityService>();
builder.Services.AddScoped<IWorkshopMaterialService, WorkshopMaterialService>();
builder.Services.AddScoped<IEventService, Business_Logic.Services.EventService>();
builder.Services.AddScoped<IInterviewService, InterviewService>();
builder.Services.AddScoped<IJobService, JobService>();
builder.Services.AddScoped<IAnalyticsService, AnalyticsService>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IStudentAuthService, StudentAuthService>();
builder.Services.AddScoped<IGraduateAuthService, GraduateAuthService>();
builder.Services.AddScoped<IUniversityAuthService, UniversityAuthService>();
builder.Services.AddScoped<ITrainingCenterAuthService, TrainingCenterAuthService>();
builder.Services.AddScoped<IEventEnrollmentService, EventEnrollmentService>();
builder.Services.AddScoped<ICVService, CVService>();
builder.Services.AddScoped<IJobApplicationService, JobApplicationService>();
builder.Services.AddScoped<IUserProfileService, UserProfileService>();
builder.Services.AddScoped<IWorkshopEnrollmentService, WorkshopEnrollmentService>();
builder.Services.AddScoped<IInternshipService, InternshipService>();
builder.Services.AddScoped<IPartnershipService, PartnershipService>();
builder.Services.AddScoped<ICandidateService, CandidateService>();
builder.Services.AddScoped<ICalendarService, CalendarService>();
builder.Services.AddScoped<IRealTimeNotificationService, RealTimeNotificationService>();
builder.Services.AddScoped<IStripePaymentService, StripePaymentService>();
builder.Services.AddScoped<IEmailService, EmailService>();
builder.Services.AddScoped<ITrainCenterAnalyticsService, TrainCenterAnalyticsService>();
builder.Services.AddScoped<IQuizGenerationJobService, QuizGenerationJobService>();
builder.Services.AddHostedService<QuizJobWorker>();
builder.Services.AddSingleton<IBackgroundJobQueue, BackgroundJobQueue>();
//builder.Services.AddHostedService<QueuedHostedService>();

// ===== Chat Services =====
builder.Services.AddScoped<IChatService, ChatService>();

builder.Services.AddHttpContextAccessor();

// ===== Mapster Mappings =====
RoadmapMappingConfig.RegisterMappings();
WorkshopMappingConfig.RegisterMappings();

// ===== Swagger =====
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// ===== CORS =====
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

builder.Services.AddSignalR();

// ===== Gemini Client =====
builder.Services.AddHttpClient<GeminiClient>();
builder.Services.AddScoped<ProgrammingTrackAnalyzerService>();

var stripeSecretKey = builder.Configuration["Stripe:SecretKey"];
StripeConfiguration.ApiKey = stripeSecretKey;

var app = builder.Build();

// ===== Create Roles =====
using (var scope = app.Services.CreateScope())
{
    var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();
    var roles = new[] { "Company", "Student", "Graduate", "TrainingCenter", "University" };

    foreach (var role in roles)
    {
        if (!await roleManager.RoleExistsAsync(role))
            await roleManager.CreateAsync(new IdentityRole(role));
    }
}

// ===== Middleware =====
app.UseSwagger();
app.UseSwaggerUI();

app.UseCors("AllowAll");

app.UseStaticFiles();
app.UseHttpsRedirection();

app.Use(async (context, next) =>
{
    if (context.Request.Path.StartsWithSegments("/api/payment/webhook"))
    {
        context.Request.EnableBuffering();
    }
    await next();
});

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHub<NotificationHub>("/notificationHub");
app.MapHub<ChatHub>("/hubs/chat");

app.Run();