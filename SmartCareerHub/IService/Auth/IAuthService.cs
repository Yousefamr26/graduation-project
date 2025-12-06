using SmartCareerHub.Contracts.Auth;
using DataAccess.Abstractions;
using System.Threading.Tasks;

namespace Business_Logic.IService
{
    public interface IAuthService
    {
        Task<Result<CompanyResponse>> RegisterCompanyAsync(RegisterCompanyRequest request);
    }
}
