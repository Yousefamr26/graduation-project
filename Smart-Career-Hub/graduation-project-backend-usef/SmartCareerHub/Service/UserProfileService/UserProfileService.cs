using DataAccess.Entities.RoadMap;
using DataAccess.Entities.Users;
using DataAccess.IRepository;
using SmartCareerHub.IService.UserProfileService;
using System.Linq;

namespace SmartCareerHub.Service.UserProfileService
{
    public class UserProfileService : IUserProfileService
    {
        private readonly IUnitOfWork _unitOfWork;

        public UserProfileService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<UserProfileResponse> GetMyProfileAsync(string userId)
        {
            return await BuildProfileAsync(userId);
        }

        public async Task<UserProfileResponse> GetPublicProfileAsync(string userId)
        {
            return await BuildProfileAsync(userId);
        }
        public async Task<UserProfileResponse> UpdateProfileAsync(string userId, UpdateProfileRequest request)
        {
            var userRoadmaps = await _unitOfWork.userRoadmaps.GetByUserIdAsync(userId);
            var user = userRoadmaps.FirstOrDefault()?.User;
            if (user == null) throw new Exception("User not found");

            // Update ApplicationUser
            user.PhoneNumber = request.PhoneNumber ?? user.PhoneNumber;
            user.Country = request.Country ?? user.Country;
            user.City = request.City ?? user.City;

            // Handle Profile Image
            if (request.ProfileImage != null)
            {
                var fileName = $"{Guid.NewGuid()}{Path.GetExtension(request.ProfileImage.FileName)}";
                var folderPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "profiles");
                Directory.CreateDirectory(folderPath);
                var savePath = Path.Combine(folderPath, fileName);
                using var stream = new FileStream(savePath, FileMode.Create);
                await request.ProfileImage.CopyToAsync(stream);
                var imagePath = $"/uploads/profiles/{fileName}";

                if (user.StudentProfile != null)
                    user.StudentProfile.ProfileImage = imagePath;
                else if (user.GraduateProfile != null)
                    user.GraduateProfile.ProfileImage = imagePath;
            }

            // Update Student
            if (user.StudentProfile != null)
            {
                user.StudentProfile.GitHub = request.GitHub ?? user.StudentProfile.GitHub;
                user.StudentProfile.LinkedIn = request.LinkedIn ?? user.StudentProfile.LinkedIn;
                user.StudentProfile.Major = request.Major ?? user.StudentProfile.Major;
                user.StudentProfile.University = request.University ?? user.StudentProfile.University;
                user.StudentProfile.Degree = request.Degree ?? user.StudentProfile.Degree;
                user.StudentProfile.ExpectedGraduation = request.ExpectedGraduation ?? user.StudentProfile.ExpectedGraduation;
            }

            // Update Graduate
            if (user.GraduateProfile != null)
            {
                user.GraduateProfile.GitHub = request.GitHub ?? user.GraduateProfile.GitHub;
                user.GraduateProfile.LinkedIn = request.LinkedIn ?? user.GraduateProfile.LinkedIn;
                user.GraduateProfile.Major = request.Major ?? user.GraduateProfile.Major;
                user.GraduateProfile.University = request.University ?? user.GraduateProfile.University;
                user.GraduateProfile.Degree = request.Degree ?? user.GraduateProfile.Degree;
                user.GraduateProfile.GraduationYear = request.GraduationYear ?? user.GraduateProfile.GraduationYear;
                user.GraduateProfile.YearsOfExperience = request.YearsOfExperience ?? user.GraduateProfile.YearsOfExperience;
                user.GraduateProfile.ExperienceSummary = request.ExperienceSummary ?? user.GraduateProfile.ExperienceSummary;
            }

            await _unitOfWork.SaveChangesAsync();
            return await BuildProfileAsync(userId);
        }

        private async Task<UserProfileResponse> BuildProfileAsync(string userId)
        {
            var userRoadmaps = await _unitOfWork.userRoadmaps.GetByUserIdAsync(userId);
            var roadmapsList = userRoadmaps.ToList();

            if (!roadmapsList.Any())
                throw new Exception("User has no roadmaps enrolled");

            var user = roadmapsList.First().User;
            if (user == null)
                throw new Exception("User not found");

            var student = user.StudentProfile;
            var graduate = user.GraduateProfile;

            bool isStudent = student != null;
            bool isGraduate = graduate != null;

            if (!isStudent && !isGraduate)
                throw new Exception("User is neither Student nor Graduate");

            var basicInfo = BuildBasicInfo(user, student, graduate, isStudent, isGraduate);
            var stats = CalculateStats(roadmapsList);
            var roadmapsProgress = BuildRoadmapsProgress(roadmapsList);
            var skills = ExtractSkills(roadmapsList);
            var achievements = CalculateAchievements(stats, roadmapsList);

            var activityDtos = new List<ActivityDto>();

            var userWorkshops = await _unitOfWork.workshopEnrollments.GetEnrollmentsByUserAsync(userId);
            activityDtos.AddRange(userWorkshops.Select(w => new ActivityDto(
                ActivityId: w.Id,
                Title: w.Workshop?.Title ?? "N/A",
                Type: "Workshop",
                CompanyName: "N/A",
                RegisteredAt: w.RegisteredAt
            )));

            var userInternships = await _unitOfWork.internshipApplicationRepository.GetByUserIdAsync(userId);
            activityDtos.AddRange(userInternships.Select(i => new ActivityDto(
                ActivityId: i.Id,
                Title: i.Internship?.Title ?? "N/A",
                Type: "Training",
                CompanyName: i.Internship?.Company?.OrganizationName ?? "N/A",
                RegisteredAt: i.AppliedAt
            )));
            // ================== Jobs ✅ ==================
            // ================== Jobs ✅ ==================
            var userJobsResult = await _unitOfWork.jobApplicationRepository.GetByUserIdAsync(userId);
            if (!userJobsResult.IsFailure)
            {
                activityDtos.AddRange(userJobsResult.Value.Select(j => new ActivityDto(
                    ActivityId: j.Id.ToString(), // ✅ حول لـ string
                    Title: j.Job?.Title ?? "N/A",
                    Type: "Job",
                    CompanyName: j.Job?.CompanyUser?.OrganizationName ?? "N/A",
                    RegisteredAt: j.AppliedAt
                )));
            }

            var userEvents = await _unitOfWork.EventEnrollments.GetUserEnrollmentsAsync(userId);
            activityDtos.AddRange(userEvents.Select(e => new ActivityDto(
                ActivityId: e.Id,
                Title: e.Event?.Title ?? "N/A",
                Type: "Event",
                CompanyName: "N/A",
                RegisteredAt: e.EnrolledAt
            )));

            activityDtos = activityDtos.OrderByDescending(a => a.RegisteredAt).ToList();

            return new UserProfileResponse(
                BasicInfo: basicInfo,
                Stats: stats,
                RoadmapsProgress: roadmapsProgress,
                Skills: skills,
                Achievements: achievements,
                ActivityDtos: activityDtos
            );
        }

        private UserBasicInfoDto BuildBasicInfo(
       ApplicationUser user,
       Student? student,
       Graduates? graduate,
       bool isStudent,
       bool isGraduate)
        {
            if (isStudent && student != null)
            {
                return new UserBasicInfoDto(
                    UserId: user.Id,
                    FullName: $"{user.FirstName} {user.LastName}",
                    Email: user.Email ?? "N/A",
                    PhoneNumber: user.PhoneNumber ?? "N/A",
                    Country: user.Country ?? "N/A",
                    City: user.City ?? "N/A",
                    UserType: "Student",
                    Major: student.Major ?? "N/A",
                    Degree: student.Degree ?? "N/A",
                    University: student.University ?? "N/A",
                    ExpectedGraduation: student.ExpectedGraduation,
                    GraduationYear: null,
                    YearsOfExperience: null,
                    ExperienceSummary: null,
                    GitHub: student.GitHub ?? "N/A",
                    LinkedIn: student.LinkedIn ?? "N/A",
                    ProfileImage: student.ProfileImage ?? "/default-profile.png",
                    JoinedAt: user.CreatedAt
                );
            }
            else if (isGraduate && graduate != null)
            {
                return new UserBasicInfoDto(
                    UserId: user.Id,
                    FullName: $"{user.FirstName} {user.LastName}",
                    Email: user.Email ?? "N/A",
                    PhoneNumber: user.PhoneNumber ?? "N/A",
                    Country: user.Country ?? "N/A",
                    City: user.City ?? "N/A",
                    UserType: "Graduate",
                    Major: graduate.Major ?? "N/A",
                    Degree: graduate.Degree ?? "N/A",
                    University: graduate.University ?? "N/A",
                    ExpectedGraduation: null,
                    GraduationYear: graduate.GraduationYear, // int عادي → ما فيش ??
                    YearsOfExperience: graduate.YearsOfExperience, // int عادي → ما فيش ??
                    ExperienceSummary: graduate.ExperienceSummary ?? "N/A",
                    GitHub: graduate.GitHub ?? "N/A",
                    LinkedIn: graduate.LinkedIn ?? "N/A",
                    ProfileImage: graduate.ProfileImage ?? "/default-profile.png",
                    JoinedAt: user.CreatedAt
                );
            }

            throw new Exception("Invalid user type");
        }

        // باقي الدوال زي ما هي بدون تغيير
        private UserStatsDto CalculateStats(List<UserRoadmap> userRoadmaps)
        {
            var totalRoadmaps = userRoadmaps.Count;
            var completedRoadmaps = userRoadmaps.Count(ur => ur.Status == "Completed");
            var inProgressRoadmaps = totalRoadmaps - completedRoadmaps;

            var allProgressItems = userRoadmaps
                .SelectMany(ur => ur.ProgressItems ?? new List<UserProgress>())
                .ToList();

            var totalPoints = allProgressItems.Sum(p => p.PointsEarned);
            var level = CalculateLevel(totalPoints);

            var completedMaterials = allProgressItems.Count(p =>
                p.MaterialType == ProgressMaterialType.LearningMaterial && p.Completed);
            var completedProjects = allProgressItems.Count(p =>
                p.MaterialType == ProgressMaterialType.Project && p.Completed);
            var completedQuizzes = allProgressItems.Count(p =>
                p.MaterialType == ProgressMaterialType.Quiz && p.Completed);

            var careerReadiness = totalRoadmaps > 0
                ? (int)userRoadmaps.Average(ur => ur.ProgressPercent)
                : 0;

            return new UserStatsDto(
                TotalPoints: totalPoints,
                Level: level,
                TotalRoadmaps: totalRoadmaps,
                CompletedRoadmaps: completedRoadmaps,
                InProgressRoadmaps: inProgressRoadmaps,
                CareerReadinessScore: careerReadiness,
                CompletedMaterials: completedMaterials,
                CompletedProjects: completedProjects,
                CompletedQuizzes: completedQuizzes
            );
        }

        private List<RoadmapProgressCardDto> BuildRoadmapsProgress(List<UserRoadmap> userRoadmaps)
        {
            return userRoadmaps.Select(ur =>
            {
                var earnedPoints = ur.ProgressItems?.Sum(p => p.PointsEarned) ?? 0;

                var breakdown = new ProgressBreakdownDto(
                    CompletedMaterials: ur.ProgressItems?.Count(p =>
                        p.MaterialType == ProgressMaterialType.LearningMaterial && p.Completed) ?? 0,
                    TotalMaterials: ur.Roadmap?.TotalMaterials ?? 0,
                    CompletedProjects: ur.ProgressItems?.Count(p =>
                        p.MaterialType == ProgressMaterialType.Project && p.Completed) ?? 0,
                    TotalProjects: ur.Roadmap?.TotalProjects ?? 0,
                    CompletedQuizzes: ur.ProgressItems?.Count(p =>
                        p.MaterialType == ProgressMaterialType.Quiz && p.Completed) ?? 0,
                    TotalQuizzes: ur.Roadmap?.TotalQuizzes ?? 0
                );

                return new RoadmapProgressCardDto(
                    RoadmapId: ur.RoadmapId,
                    Title: ur.Roadmap?.Title ?? "N/A",
                    Description: ur.Roadmap?.Description ?? "",
                    TargetRole: ur.Roadmap?.TargetRole ?? "N/A",
                    CompanyName: ur.Roadmap?.Company?.OrganizationName ?? "N/A",
                    CoverImageUrl: ur.Roadmap?.CoverImageUrl,
                    ProgressPercent: ur.ProgressPercent,
                    Status: ur.Status,
                    EarnedPoints: earnedPoints,
                    TotalPoints: ur.Roadmap?.TotalPoints ?? 0,
                    EnrolledAt: ur.EnrolledAt,
                    CompletedAt: ur.Status == "Completed" ? ur.UpdatedAt : null,
                    Breakdown: breakdown
                );
            })
            .OrderByDescending(r => r.ProgressPercent)
            .ToList();
        }

        private List<SkillProgressDto> ExtractSkills(List<UserRoadmap> userRoadmaps)
        {
            return userRoadmaps
                .Where(ur => ur.Roadmap?.RequiredSkills != null)
                .SelectMany(ur => ur.Roadmap.RequiredSkills)
                .GroupBy(rs => rs.SkillName)
                .Select(g =>
                {
                    var level = g.First().Level;
                    var progressPercent = CalculateSkillProgress(g.Key, userRoadmaps);

                    return new SkillProgressDto(
                        SkillName: g.Key,
                        Level: level,
                        ProgressPercent: progressPercent
                    );
                })
                .OrderByDescending(s => s.ProgressPercent)
                .ToList();
        }

        private List<AchievementDto> CalculateAchievements(UserStatsDto stats, List<UserRoadmap> userRoadmaps)
        {
            var achievements = new List<AchievementDto>();

            if (stats.CompletedRoadmaps >= 1)
            {
                var firstCompleted = userRoadmaps
                    .Where(ur => ur.Status == "Completed")
                    .OrderBy(ur => ur.UpdatedAt)
                    .FirstOrDefault();

                if (firstCompleted != null)
                {
                    achievements.Add(new AchievementDto(
                        Title: "Top Graduate",
                        Description: "Ranked in top 30",
                        Icon: "🏆",
                        EarnedAt: firstCompleted.UpdatedAt ?? DateTime.UtcNow
                    ));
                }
            }

            if (stats.CompletedMaterials >= 6)
            {
                achievements.Add(new AchievementDto(
                    Title: "Course Champion",
                    Description: "Completed 6 courses",
                    Icon: "📚",
                    EarnedAt: DateTime.UtcNow
                ));
            }

            if (stats.CareerReadinessScore >= 60)
            {
                achievements.Add(new AchievementDto(
                    Title: "Industry Ready",
                    Description: "60% career readiness",
                    Icon: "💼",
                    EarnedAt: DateTime.UtcNow
                ));
            }

            return achievements;
        }

        private int CalculateLevel(int totalPoints)
        {
            return (totalPoints / 100) + 1;
        }

        private int CalculateSkillProgress(string skillName, List<UserRoadmap> userRoadmaps)
        {
            var roadmapsWithSkill = userRoadmaps
                .Where(ur => ur.Roadmap?.RequiredSkills?.Any(rs => rs.SkillName == skillName) == true)
                .ToList();

            if (!roadmapsWithSkill.Any())
                return 0;

            return (int)roadmapsWithSkill.Average(ur => ur.ProgressPercent);
        }
    }
}