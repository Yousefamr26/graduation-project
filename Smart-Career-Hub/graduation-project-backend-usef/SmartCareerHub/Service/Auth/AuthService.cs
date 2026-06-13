using Business_Logic.Errors;
using Business_Logic.IService;
using DataAccess.Abstractions;
using DataAccess.Contexts;
using DataAccess.Entities;
using DataAccess.Entities.Users;
using DataAccess.IRepository;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using SmartCareerHub.Contracts.Auth;
using SmartCareerHub.Services;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace Business_Logic.Service
{
    public class AuthService : IAuthService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IConfiguration _configuration;
        private readonly ApplicationDbContext _context;
        private readonly IEmailService _emailService;

        public AuthService(
            IUnitOfWork unitOfWork,
            IConfiguration configuration,
            ApplicationDbContext context,
            IEmailService emailService)
        {
            _unitOfWork = unitOfWork;
            _configuration = configuration;
            _context = context;
            _emailService = emailService;
        }

        #region Register

        public async Task<Result<CompanyResponse>> RegisterCompanyAsync(RegisterCompanyRequest request)
        {
            if (await _unitOfWork.companyAuthRepository.UserExistsByEmailAsync(request.Email))
                return Result.Failure<CompanyResponse>(AuthErrors.UserAlreadyExists);

            await _unitOfWork.BeginTransactionAsync();

            ApplicationUser? savedUser = null;
            CompanyUser? company = null;

            try
            {
                var user = new ApplicationUser
                {
                    UserName = request.Email,
                    Email = request.Email,
                    UserType = "Company",
                    FirstName = request.FirstName,
                    LastName = request.LastName,
                    Country = request.Country,
                    City = request.City,
                    IsActive = true,
                    IsEmailVerified = false,
                    CreatedAt = DateTime.UtcNow
                };

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

                company = new CompanyUser
                {
                    Id = user.Id,
                    UserId = user.Id,
                    OrganizationName = request.OrganizationName,
                    OrganizationLogo = logoPath,
                    Country = request.Country,
                    City = request.City,
                    User = user
                };

                var companyResult = await _unitOfWork.companyAuthRepository.CreateCompanyProfileAsync(company);
                if (!companyResult.IsSuccess)
                    return Result.Failure<CompanyResponse>(companyResult.Error);

                await _unitOfWork.SaveChangesAsync();
                await _unitOfWork.CommitTransactionAsync();

                savedUser = user;
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync();
                return Result.Failure<CompanyResponse>(new Error("Auth.Exception",
                    "An error occurred while processing the request: " + ex.Message));
            }

            // ===================== OTP - بره الـ transaction =====================
            try
            {
                var otp = new Random().Next(100000, 999999).ToString();
                _context.PasswordResetOtps.Add(new PasswordResetOtp
                {
                    UserId = savedUser.Id,
                    OtpCode = otp,
                    ExpiresAt = DateTime.UtcNow.AddMinutes(10),
                    IsUsed = false
                });
                await _context.SaveChangesAsync();

                var fullName = $"{savedUser.FirstName} {savedUser.LastName}";
                await _emailService.SendOtpEmailAsync(savedUser.Email!, fullName, otp);
            }
            catch (Exception emailEx)
            {
                return Result.Failure<CompanyResponse>(
                    new Error("Auth.EmailFailed", $"Registration successful but email failed: {emailEx.Message}"));
            }

            var response = new CompanyResponse(
                savedUser.Id,
                savedUser.Email,
                savedUser.FirstName,
                savedUser.LastName,
                company!.OrganizationName,
                company.OrganizationLogo,
                company.Country,
                company.City,
                savedUser.IsActive,
                savedUser.IsEmailVerified,
                savedUser.CreatedAt
            );

            return Result.Success(response);
        }

        #endregion

        #region Email Verification

        public async Task<Result<string>> VerifyEmailAsync(string email, string otp)
        {
            var user = await _unitOfWork.companyAuthRepository.GetUserByEmailAsync(email);
            if (user == null)
                return Result.Failure<string>(new Error("Auth.NotFound", "User not found."));

            if (user.IsEmailVerified)
                return Result.Failure<string>(new Error("Auth.AlreadyVerified", "Email is already verified."));

            var otpRecord = await _context.PasswordResetOtps
                .FirstOrDefaultAsync(o => o.UserId == user.Id && !o.IsUsed);

            if (otpRecord == null)
                return Result.Failure<string>(new Error("Auth.NoOtp", "No OTP found. Please request a new one."));

            if (otpRecord.ExpiresAt < DateTime.UtcNow)
                return Result.Failure<string>(new Error("Auth.OtpExpired", "OTP expired. Please request a new one."));

            if (otpRecord.OtpCode != otp)
                return Result.Failure<string>(new Error("Auth.InvalidOtp", "Invalid OTP."));

            otpRecord.IsUsed = true;
            user.IsEmailVerified = true;
            await _context.SaveChangesAsync();

            return Result.Success("Email verified successfully.");
        }

        public async Task<Result<string>> ResendEmailOtpAsync(string email)
        {
            var user = await _unitOfWork.companyAuthRepository.GetUserByEmailAsync(email);
            if (user == null)
                return Result.Failure<string>(new Error("Auth.NotFound", "User not found."));

            if (user.IsEmailVerified)
                return Result.Failure<string>(new Error("Auth.AlreadyVerified", "Email is already verified."));

            try
            {
                var otp = new Random().Next(100000, 999999).ToString();

                var existingOtp = await _context.PasswordResetOtps
                    .FirstOrDefaultAsync(o => o.UserId == user.Id && !o.IsUsed);

                if (existingOtp != null)
                {
                    existingOtp.OtpCode = otp;
                    existingOtp.ExpiresAt = DateTime.UtcNow.AddMinutes(10);
                    existingOtp.IsUsed = false;
                    existingOtp.CreatedAt = DateTime.UtcNow;
                }
                else
                {
                    _context.PasswordResetOtps.Add(new PasswordResetOtp
                    {
                        UserId = user.Id,
                        OtpCode = otp,
                        ExpiresAt = DateTime.UtcNow.AddMinutes(10),
                        IsUsed = false
                    });
                }

                await _context.SaveChangesAsync();

                var fullName = $"{user.FirstName} {user.LastName}";
                await _emailService.SendOtpEmailAsync(user.Email!, fullName, otp);
            }
            catch (Exception emailEx)
            {
                return Result.Failure<string>(new Error("Auth.EmailFailed", $"Failed to send OTP: {emailEx.Message}"));
            }

            return Result.Success("OTP sent successfully.");
        }

        #endregion

        #region Login

        public async Task<Result<LoginResponse<CompanyResponse>>> LoginAsync(LoginRequest request)
        {
            try
            {
                var user = await _unitOfWork.companyAuthRepository.GetUserByEmailAsync(request.Email);
                if (user == null)
                    return Result.Failure<LoginResponse<CompanyResponse>>(AuthErrors.InvalidCredentials);

                if (user.UserType != request.AccountType)
                    return Result.Failure<LoginResponse<CompanyResponse>>(AuthErrors.AccountTypeNotMatch);

                if (!user.IsActive)
                    return Result.Failure<LoginResponse<CompanyResponse>>(AuthErrors.AccountNotActive);

                if (!user.IsEmailVerified)
                    return Result.Failure<LoginResponse<CompanyResponse>>(
                        new Error("Auth.EmailNotVerified", "Please verify your email before logging in."));

                var isPasswordValid = await _unitOfWork.companyAuthRepository.CheckPasswordAsync(user, request.Password);
                if (!isPasswordValid)
                    return Result.Failure<LoginResponse<CompanyResponse>>(AuthErrors.InvalidCredentials);

                user.UpdatedAt = DateTime.UtcNow;
                await _unitOfWork.SaveChangesAsync();

                var token = GenerateJwtToken(user);

                var companyProfile = await _unitOfWork.companyAuthRepository.GetCompanyProfileByUserIdAsync(user.Id);

                var response = new CompanyResponse(
                    user.Id,
                    user.Email,
                    user.FirstName,
                    user.LastName,
                    companyProfile?.OrganizationName ?? string.Empty,
                    companyProfile?.OrganizationLogo,
                    companyProfile?.Country ?? user.Country,
                    companyProfile?.City ?? user.City,
                    user.IsActive,
                    user.IsEmailVerified,
                    user.CreatedAt
                );

                return Result.Success(new LoginResponse<CompanyResponse>(token, response));
            }
            catch (Exception ex)
            {
                return Result.Failure<LoginResponse<CompanyResponse>>(new Error("Auth.LoginException",
                    "An error occurred during login: " + ex.Message));
            }
        }

        #endregion

        #region JWT Token Generation

        private string GenerateJwtToken(ApplicationUser user)
        {
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id),
                new Claim(ClaimTypes.Email, user.Email!),
                new Claim(ClaimTypes.Name, $"{user.FirstName} {user.LastName}"),
                new Claim(ClaimTypes.Role, user.UserType),
                new Claim("UserType", user.UserType),
                new Claim("FirstName", user.FirstName),
                new Claim("LastName", user.LastName),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]!));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
            var expires = DateTime.UtcNow.AddDays(Convert.ToDouble(_configuration["Jwt:ExpireDays"]));

            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"],
                audience: _configuration["Jwt:Audience"],
                claims: claims,
                expires: expires,
                signingCredentials: credentials
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        #endregion
    }
}