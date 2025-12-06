using Business_Logic.Errors;
using Business_Logic.IService;
using DataAccess.Abstractions;
using DataAccess.Entities.Users;
using DataAccess.IRepository;
using Mapster;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using SmartCareerHub.Contracts.Auth;

namespace Business_Logic.Service
{
    public class AuthService : IAuthService
    {
        private readonly IUnitOfWork _unitOfWork;

        public AuthService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<Result<CompanyResponse>> RegisterCompanyAsync(RegisterCompanyRequest request)
        {
            if (await _unitOfWork.companyAuthRepository.UserExistsByEmailAsync(request.Email))
                return Result.Failure<CompanyResponse>(AuthErrors.UserAlreadyExists);

            await _unitOfWork.BeginTransactionAsync();

            try
            {
                var user = request.Adapt<ApplicationUser>();

                user.UserName = request.Email; 
                user.Email = request.Email;
                user.UserType = "Company";
                user.FirstName = request.FirstName;
                user.LastName = request.LastName;
                user.Country = request.Country;
                user.City = request.City;
                user.IsActive = true;
                user.IsEmailVerified = false;

                var userResult = await _unitOfWork.companyAuthRepository.CreateUserAsync(user, request.Password);
                if (!userResult.IsSuccess)
                    return Result.Failure<CompanyResponse>(userResult.Error);

                var roleResult = await _unitOfWork.companyAuthRepository.AssignRoleAsync(user, "Company");
                if (!roleResult.IsSuccess)
                    return Result.Failure<CompanyResponse>(roleResult.Error);

                string? logoPath = null;
                if (request.OrganizationLogo != null)
                {
                    var fileName = $"{Guid.NewGuid()}{Path.GetExtension(request.OrganizationLogo.FileName)}";
                    var folderPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "Auth", "companies");
                    Directory.CreateDirectory(folderPath);
                    var savePath = Path.Combine(folderPath, fileName);
                    using var stream = new FileStream(savePath, FileMode.Create);
                    await request.OrganizationLogo.CopyToAsync(stream);
                    logoPath = $"/Auth/companies/{fileName}";
                }

                var company = request.Adapt<CompanyUser>();
                company.Id = user.Id;
                company.OrganizationLogo = logoPath;

                var companyResult = await _unitOfWork.companyAuthRepository.CreateCompanyProfileAsync(company);
                if (!companyResult.IsSuccess)
                    return Result.Failure<CompanyResponse>(companyResult.Error);

                await _unitOfWork.SaveChangesAsync();
                await _unitOfWork.CommitTransactionAsync();

                var response = new CompanyResponse(
                    user.Id,
                    user.Email,
                    user.FirstName,
                    user.LastName,
                    company.OrganizationName,
                    company.OrganizationLogo,
                    company.Country,
                    company.City,
                    user.IsActive,
                    user.IsEmailVerified,
                    user.CreatedAt
                );

                return Result.Success(response);
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync();
                return Result.Failure<CompanyResponse>(new Error("Auth.Exception",
                    "An error occurred while processing the request: " + ex.Message));
            }
        }

    }
}
