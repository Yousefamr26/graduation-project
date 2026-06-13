using Business_Logic.IService;
using DataAccess.Abstractions;
using DataAccess.IRepository;

namespace Business_Logic.Service
{
    public class CandidateService : ICandidateService
    {
        private readonly ICandidateRepository _candidateRepository;

        public CandidateService(ICandidateRepository candidateRepository)
        {
            _candidateRepository = candidateRepository;
        }

        public async Task<DataAccess.Abstractions.Result<IEnumerable<CandidateResponse>>> GetAllCandidatesAsync()
        {
            return await _candidateRepository.GetAllCandidatesAsync();
        }
        public async Task<Result<CandidateResponse>> GetCandidateByIdAsync(string userId)
        {
            return await _candidateRepository.GetCandidateByIdAsync(userId);
        }
    }
}