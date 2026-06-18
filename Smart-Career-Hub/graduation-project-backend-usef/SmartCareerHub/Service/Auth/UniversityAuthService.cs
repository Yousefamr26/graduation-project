using Business_Logic.Errors;
using Business_Logic.IService;
using DataAccess.Abstractions;
using DataAccess.Contexts;
using DataAccess.Entities;
using DataAccess.Entities.User;
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
    public class UniversityAuthService : IUniversityAuthService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IConfiguration _configuration;
        private readonly ApplicationDbContext _context;
        private readonly IEmailService _emailService;

        public UniversityAuthService(
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

        public async Task<Result<UniversityRegisterResponse>> RegisterUniversityAsync(UniversityRegisterRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.City) || string.IsNullOrWhiteSpace(request.Country))
                return Result.Failure<UniversityRegisterResponse>(new Error("Auth.Validation", "City and Country are required fields."));

            if (string.IsNullOrWhiteSpace(request.Name) || string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
                return Result.Failure<UniversityRegisterResponse>(new Error("Auth.Validation", "Name, Email, and Password are required fields."));

            if (request.Password != request.ConfirmPassword)
                return Result.Failure<UniversityRegisterResponse>(new Error("Auth.Validation", "Password and ConfirmPassword do not match."));

            if (await _unitOfWork.universityAuthRepository.UserExistsByEmailAsync(request.Email))
                return Result.Failure<UniversityRegisterResponse>(AuthErrors.UserAlreadyExists);

            await _unitOfWork.BeginTransactionAsync();

            try
            {
                var user = new ApplicationUser
                {
                    UserName = request.Email,
                    Email = request.Email,
                    FirstName = request.Name,
                    LastName = "University",
                    UserType = "University",
                    PhoneNumber = request.PhoneNumber,
                    Country = request.Country,
                    City = request.City,
                    IsActive = true,
                    IsEmailVerified = false,
                    CreatedAt = DateTime.UtcNow
                };

                var userResult = await _unitOfWork.universityAuthRepository.CreateUserAsync(user, request.Password);
                if (!userResult.IsSuccess)
                    return Result.Failure<UniversityRegisterResponse>(userResult.Error);

                var roleResult = await _unitOfWork.universityAuthRepository.AssignRoleAsync(user, "University");
                if (!roleResult.IsSuccess)
                    return Result.Failure<UniversityRegisterResponse>(roleResult.Error);

                string? logoPath = null;
                if (request.OrganizationLogo != null)
                {
                    var fileName = $"{Guid.NewGuid()}{Path.GetExtension(request.OrganizationLogo.FileName)}";
                    var folderPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "Auth", "universities");
                    Directory.CreateDirectory(folderPath);
                    var savePath = Path.Combine(folderPath, fileName);

                    using var stream = new FileStream(savePath, FileMode.Create);
                    await request.OrganizationLogo.CopyToAsync(stream);

                    logoPath = $"/Auth/universities/{fileName}";
                }

                var university = new University
                {
                    UserId = user.Id,
                    Name = request.Name,
                    City = request.City,
                    Country = request.Country,
                    OrganizationLogo = logoPath,
                    CreatedAt = DateTime.UtcNow,
                    User = user
                };

                var universityResult = await _unitOfWork.universityAuthRepository.CreateUniversityProfileAsync(university);
                if (!universityResult.IsSuccess)
                    return Result.Failure<UniversityRegisterResponse>(universityResult.Error);

                await _unitOfWork.SaveChangesAsync();
                await _unitOfWork.CommitTransactionAsync();

                // ===================== بعت OTP على الإيميل =====================
                await SendEmailOtpAsync(user);

                var response = new UniversityRegisterResponse(
                    Id: university.Id,
                    Name: university.Name,
                    Email: user.Email!,
                    PhoneNumber: user.PhoneNumber,
                    Country: university.Country,
                    City: university.City,
                    OrganizationLogoUrl: university.OrganizationLogo,
                    CreatedAt: university.CreatedAt
                );

                return Result.Success(response);
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync();
                return Result.Failure<UniversityRegisterResponse>(new Error("Auth.Exception",
                    "An error occurred while processing the request: " + ex.Message));
            }
        }

        #endregion

        #region Email Verification

        public async Task<Result<string>> VerifyEmailAsync(string email, string otp)
        {
            var user = await _unitOfWork.universityAuthRepository.GetUserByEmailAsync(email);
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
            var user = await _unitOfWork.universityAuthRepository.GetUserByEmailAsync(email);
            if (user == null)
                return Result.Failure<string>(new Error("Auth.NotFound", "User not found."));

            if (user.IsEmailVerified)
                return Result.Failure<string>(new Error("Auth.AlreadyVerified", "Email is already verified."));

            await SendEmailOtpAsync(user);
            return Result.Success("OTP sent successfully.");
        }

        private async Task SendEmailOtpAsync(ApplicationUser user)
        {
            var otp = new Random().Next(100000, 999999).ToString();
            var expiresAt = DateTime.UtcNow.AddMinutes(10);

            var existingOtp = await _context.PasswordResetOtps
                .FirstOrDefaultAsync(o => o.UserId == user.Id && !o.IsUsed);

            if (existingOtp != null)
            {
                existingOtp.OtpCode = otp;
                existingOtp.ExpiresAt = expiresAt;
                existingOtp.IsUsed = false;
                existingOtp.CreatedAt = DateTime.UtcNow;
            }
            else
            {
                _context.PasswordResetOtps.Add(new PasswordResetOtp
                {
                    UserId = user.Id,
                    OtpCode = otp,
                    ExpiresAt = expiresAt,
                    IsUsed = false
                });
            }

            await _context.SaveChangesAsync();

            var fullName = user.FirstName ?? "University";
            await _emailService.SendOtpEmailAsync(user.Email!, fullName, otp);
        }

        #endregion

        #region Login

        public async Task<Result<LoginResponse<UniversityRegisterResponse>>> LoginAsync(LoginRequest request)
        {
            try
            {
                var user = await _unitOfWork.universityAuthRepository.GetUserByEmailAsync(request.Email);
                if (user == null)
                    return Result.Failure<LoginResponse<UniversityRegisterResponse>>(AuthErrors.InvalidCredentials);

                if (user.UserType != "University")
                    return Result.Failure<LoginResponse<UniversityRegisterResponse>>(AuthErrors.AccountTypeNotMatch);

                if (!user.IsActive)
                    return Result.Failure<LoginResponse<UniversityRegisterResponse>>(AuthErrors.AccountNotActive);

                // ===================== تحقق من الإيميل =====================
                if (!user.IsEmailVerified)
                    return Result.Failure<LoginResponse<UniversityRegisterResponse>>(
                        new Error("Auth.EmailNotVerified", "Please verify your email before logging in."));

                var isPasswordValid = await _unitOfWork.universityAuthRepository.CheckPasswordAsync(user, request.Password);
                if (!isPasswordValid)
                    return Result.Failure<LoginResponse<UniversityRegisterResponse>>(AuthErrors.InvalidCredentials);

                user.UpdatedAt = DateTime.UtcNow;
                await _unitOfWork.SaveChangesAsync();

                var token = GenerateJwtToken(user);

                var universityProfile = await _unitOfWork.universityAuthRepository.GetUniversityProfileByUserIdAsync(user.Id);

                var response = new UniversityRegisterResponse(
                    Id: universityProfile!.Id,
                    Name: universityProfile.Name,
                    Email: user.Email!,
                    PhoneNumber: user.PhoneNumber,
                    Country: universityProfile.Country,
                    City: universityProfile.City,
                    OrganizationLogoUrl: universityProfile.OrganizationLogo,
                    CreatedAt: universityProfile.CreatedAt
                );

                return Result.Success(new LoginResponse<UniversityRegisterResponse>(token, response));
            }
            catch (Exception ex)
            {
                return Result.Failure<LoginResponse<UniversityRegisterResponse>>(new Error("Auth.LoginException",
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
        new Claim(ClaimTypes.Name, user.FirstName ?? ""),
        new Claim("role", user.UserType),
        new Claim(ClaimTypes.Role, user.UserType),
        new Claim("UserType", user.UserType),
        new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
    };

            // ← ضيف الـ UniversityId في الـ token
            var universityProfile = _unitOfWork.universityAuthRepository
                .GetUniversityProfileByUserIdAsync(user.Id).Result;

            if (universityProfile != null)
                claims.Add(new Claim("UniversityId", universityProfile.Id.ToString()));

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