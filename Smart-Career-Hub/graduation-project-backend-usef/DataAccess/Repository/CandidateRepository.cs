using DataAccess.Abstractions;
using DataAccess.Contexts;
using DataAccess.IRepository;
using Microsoft.EntityFrameworkCore;
namespace DataAccess.Repository
{
    public class CandidateRepository : ICandidateRepository
    {
        private readonly ApplicationDbContext _context;

        public CandidateRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<DataAccess.Abstractions.Result<IEnumerable<CandidateResponse>>> GetAllCandidatesAsync()
        {
            var userRoadmaps = await _context.userRoadmaps
                .Include(ur => ur.User)
                    .ThenInclude(u => u.StudentProfile)
                .Include(ur => ur.User)
                    .ThenInclude(u => u.GraduateProfile)
                .Include(ur => ur.Roadmap)
                .Include(ur => ur.ProgressItems)
                .Where(ur => ur.User.UserType == "Student" || ur.User.UserType == "Graduate")
                .ToListAsync();

            var candidates = userRoadmaps.Select(ur => new CandidateResponse(
                UserId: ur.UserId,
                FullName: $"{ur.User.FirstName} {ur.User.LastName}",
                Email: ur.User.Email ?? "",
                UserType: ur.User.UserType,
                RoadmapId: ur.RoadmapId,
                RoadmapName: ur.Roadmap?.Title ?? "",
                TotalPoints: ur.ProgressItems?.Sum(p => p.PointsEarned) ?? 0,
                ProfileImage: ur.User.StudentProfile?.ProfileImage ?? ur.User.GraduateProfile?.ProfileImage
            ));

            return DataAccess.Abstractions.Result.Success<IEnumerable<CandidateResponse>>(candidates);
        }

        public async Task<Result<CandidateResponse>> GetCandidateByIdAsync(string userId)
        {
            var userRoadmap = await _context.userRoadmaps
                .Include(ur => ur.User)
                    .ThenInclude(u => u.StudentProfile)
                .Include(ur => ur.User)
                    .ThenInclude(u => u.GraduateProfile)
                .Include(ur => ur.Roadmap)
                .Include(ur => ur.ProgressItems)
                .FirstOrDefaultAsync(ur => ur.UserId == userId &&
                    (ur.User.UserType == "Student" || ur.User.UserType == "Graduate"));

            if (userRoadmap == null)
                return Result.Failure<CandidateResponse>(new Error("Candidate.NotFound", "Candidate not found"));

            var candidate = new CandidateResponse(
                UserId: userRoadmap.UserId,
                FullName: $"{userRoadmap.User.FirstName} {userRoadmap.User.LastName}",
                Email: userRoadmap.User.Email ?? "",
                UserType: userRoadmap.User.UserType,
                RoadmapId: userRoadmap.RoadmapId,
                RoadmapName: userRoadmap.Roadmap?.Title ?? "",
                TotalPoints: userRoadmap.ProgressItems?.Sum(p => p.PointsEarned) ?? 0,
                ProfileImage: userRoadmap.User.StudentProfile?.ProfileImage ?? userRoadmap.User.GraduateProfile?.ProfileImage
            );

            return Result.Success(candidate);
        }
    }
}