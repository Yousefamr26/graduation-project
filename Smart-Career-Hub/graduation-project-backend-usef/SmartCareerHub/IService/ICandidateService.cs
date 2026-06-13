using DataAccess.Abstractions;

namespace Business_Logic.IService
{
    public interface ICandidateService
    {
        Task<DataAccess.Abstractions.Result<IEnumerable<CandidateResponse>>> GetAllCandidatesAsync();
        Task<Result<CandidateResponse>> GetCandidateByIdAsync(string userId);

    }
}