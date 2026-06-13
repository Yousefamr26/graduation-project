using Business_Logic.IService;
using Business_Logic.Service;
using Business_Logic.Services;
using DataAccess.Contexts;
using DataAccess.IRepository;
using DataAccess.Repository;
using Mapster;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using SmartCareerHub;

var builder = WebApplication.CreateBuilder(args);

builder.WebHost.UseWebRoot("wwwroot");

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("SmartCareerHub")
    )
);

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

builder.Services.AddControllers()
    .AddJsonOptions(o =>
    {
        o.JsonSerializerOptions.DefaultIgnoreCondition =
            System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull;
    });

builder.Services.AddScoped<IRoadmapAnalyticsRepository, RoadmapAnalyticsRepository>();
builder.Services.AddScoped<IRequiredSkillRepository, RequiredSkillRepository>();
builder.Services.AddScoped<ILearningMaterialRepository, LearningMaterialRepository>();
builder.Services.AddScoped<IProjectRepository, ProjectRepository>();
builder.Services.AddScoped<IQuizRepository, QuizRepository>(); // موجود
builder.Services.AddScoped<IQuestionRepository, QuestionRepository>(); 

builder.Services.AddScoped<IWorkshopAnalyticsRepository, WorkshopAnalyticsRepository>();
builder.Services.AddScoped<IWorkshopMaterialRepository, WorkshopMaterialRepository>();
builder.Services.AddScoped<IWorkshopActivityRepository, WorkshopActivityRepository>();

builder.Services.AddScoped<IEventAnalyticsRepository, EventAnalyticsRepository>();
builder.Services.AddScoped<IJobAnalyticsRepository, JobAnalyticsRepository>();
builder.Services.AddScoped<IInterviewRepository, InterviewRepository>();
builder.Services.AddScoped<ICompanyAuthRepository, CompanyAuthRepository>();

builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();

builder.Services.AddScoped<IRoadmapService, RoadmapService>();
builder.Services.AddScoped<IQuizService, QuizService>(); 
builder.Services.AddScoped<IWorkshopService, WorkshopService>();
builder.Services.AddScoped<IWorkshopActivityService, WorkshopActivityService>();
builder.Services.AddScoped<IWorkshopMaterialService, WorkshopMaterialService>();
builder.Services.AddScoped<IEventService, EventService>();
builder.Services.AddScoped<IInterviewService, InterviewService>();
builder.Services.AddScoped<IJobService, JobService>();
builder.Services.AddScoped<IAnalyticsService, AnalyticsService>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddHttpContextAccessor();

RoadmapMappingConfig.RegisterMappings();
WorkshopMappingConfig.RegisterMappings();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();
    var roles = new[] { "Company", "Student", "Graduate", "TrainingCenter" };

    foreach (var role in roles)
    {
        if (!await roleManager.RoleExistsAsync(role))
        {
            await roleManager.CreateAsync(new IdentityRole(role));
        }
    }
}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseStaticFiles();
app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
