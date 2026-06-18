using DataAccess.Abstractions;

namespace DataAccess.IRepository
{
    public interface ICandidateRepository
    {
        Task<DataAccess.Abstractions.Result<IEnumerable<CandidateResponse>>> GetAllCandidatesAsync();
        Task<Result<CandidateResponse>> GetCandidateByIdAsync(string userId);
    }
}




public record CandidateResponse(
        string UserId,
        string FullName,
        string Email,
        string UserType,
        int RoadmapId,
        string RoadmapName,
        int TotalPoints,
        string? ProfileImage
    );