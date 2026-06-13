using Business_Logic.Errors;
using Business_Logic.IService;
using DataAccess.Abstractions;
using DataAccess.Contexts;
using DataAccess.Entities;
using DataAccess.Entities.Users;
using DataAccess.IRepository;
using Mapster;
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
    public class GraduateAuthService : IGraduateAuthService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IConfiguration _configuration;
        private readonly ApplicationDbContext _context;
        private readonly IEmailService _emailService;

        public GraduateAuthService(
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

        public async Task<Result<GraduateResponse>> RegisterGraduateAsync(RegisterGraduateRequest request)
        {
            if (await _unitOfWork.graduateAuthRepository.UserExistsByEmailAsync(request.Email))
                return Result.Failure<GraduateResponse>(AuthErrors.UserAlreadyExists);

            await _unitOfWork.BeginTransactionAsync();
            try
            {
                var user = request.Adapt<ApplicationUser>();
                user.UserName = request.Email;
                user.Email = request.Email;
                user.UserType = "Graduate";
                user.FirstName = request.FirstName;
                user.LastName = request.LastName;
                user.City = request.City;
                user.Country = request.Country;
                user.IsActive = true;
                user.IsEmailVerified = false;

                var userResult = await _unitOfWork.graduateAuthRepository.CreateUserAsync(user, request.Password);
                if (!userResult.IsSuccess)
                    return Result.Failure<GraduateResponse>(userResult.Error);

                var roleResult = await _unitOfWork.graduateAuthRepository.AssignRoleAsync(user, "Graduate");
                if (!roleResult.IsSuccess)
                    return Result.Failure<GraduateResponse>(roleResult.Error);

                // Upload profile image
                string? profileImagePath = null;
                if (request.ProfileImage != null)
                {
                    var fileName = $"{Guid.NewGuid()}{Path.GetExtension(request.ProfileImage.FileName)}";
                    var folderPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "Auth", "graduates");
                    Directory.CreateDirectory(folderPath);

                    var savePath = Path.Combine(folderPath, fileName);
                    using var stream = new FileStream(savePath, FileMode.Create);
                    await request.ProfileImage.CopyToAsync(stream);

                    profileImagePath = $"/Auth/graduates/{fileName}";
                }

                var graduate = request.Adapt<Graduates>();
                graduate.UserId = user.Id;
                graduate.ProfileImage = profileImagePath;

                var graduateResult = await _unitOfWork.graduateAuthRepository.CreateGraduateProfileAsync(graduate);
                if (!graduateResult.IsSuccess)
                    return Result.Failure<GraduateResponse>(graduateResult.Error);

                await _unitOfWork.SaveChangesAsync();
                await _unitOfWork.CommitTransactionAsync();

                // ===================== بعت OTP على الإيميل =====================
                await SendEmailOtpAsync(user);

                var response = new GraduateResponse(
                    user.Id,
                    user.Email,
                    user.FirstName,
                    user.LastName,
                    graduate.Major,
                    graduate.Degree,
                    graduate.University,
                    graduate.GraduationYear,
                    graduate.YearsOfExperience,
                    graduate.LinkedIn,
                    graduate.GitHub,
                    request.Portfolio,
                    graduate.ProfileImage,
                    user.City,
                    user.Country,
                    user.IsActive,
                    user.IsEmailVerified,
                    user.CreatedAt
                );

                return Result.Success(response);
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync();
                return Result.Failure<GraduateResponse>(new Error("Auth.Exception", ex.Message));
            }
        }

        #endregion

        #region Email Verification

        public async Task<Result<string>> VerifyEmailAsync(string email, string otp)
        {
            var user = await _unitOfWork.graduateAuthRepository.GetUserByEmailAsync(email);
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
            var user = await _unitOfWork.graduateAuthRepository.GetUserByEmailAsync(email);
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

            var fullName = $"{user.FirstName} {user.LastName}";
            await _emailService.SendOtpEmailAsync(user.Email!, fullName, otp);
        }

        #endregion

        #region Login

        public async Task<Result<LoginResponse<GraduateResponse>>> LoginAsync(LoginRequest request)
        {
            try
            {
                var user = await _unitOfWork.graduateAuthRepository.GetUserByEmailAsync(request.Email);
                if (user == null)
                    return Result.Failure<LoginResponse<GraduateResponse>>(AuthErrors.InvalidCredentials);

                if (user.UserType != request.AccountType)
                    return Result.Failure<LoginResponse<GraduateResponse>>(AuthErrors.AccountTypeNotMatch);

                if (!user.IsActive)
                    return Result.Failure<LoginResponse<GraduateResponse>>(AuthErrors.AccountNotActive);

                // ===================== تحقق من الإيميل =====================
                if (!user.IsEmailVerified)
                    return Result.Failure<LoginResponse<GraduateResponse>>(
                        new Error("Auth.EmailNotVerified", "Please verify your email before logging in."));

                var isPasswordValid = await _unitOfWork.graduateAuthRepository.CheckPasswordAsync(user, request.Password);
                if (!isPasswordValid)
                    return Result.Failure<LoginResponse<GraduateResponse>>(AuthErrors.InvalidCredentials);

                user.UpdatedAt = DateTime.UtcNow;
                await _unitOfWork.SaveChangesAsync();

                var token = GenerateJwtToken(user);

                var graduateProfile = await _unitOfWork.graduateAuthRepository.GetGraduateProfileByUserIdAsync(user.Id);

                var response = new GraduateResponse(
                    user.Id,
                    user.Email,
                    user.FirstName,
                    user.LastName,
                    graduateProfile?.Major ?? "",
                    graduateProfile?.Degree ?? "",
                    graduateProfile?.University ?? "",
                    graduateProfile?.GraduationYear ?? 0,
                    graduateProfile?.YearsOfExperience ?? 0,
                    graduateProfile?.LinkedIn,
                    graduateProfile?.GitHub,
                    null,
                    graduateProfile?.ProfileImage,
                    user.City,
                    user.Country,
                    user.IsActive,
                    user.IsEmailVerified,
                    user.CreatedAt
                );

                return Result.Success(new LoginResponse<GraduateResponse>(token, response));
            }
            catch (Exception ex)
            {
                return Result.Failure<LoginResponse<GraduateResponse>>(
                    new Error("Auth.LoginException", ex.Message));
            }
        }

        #endregion

        #region JWT

        private string GenerateJwtToken(ApplicationUser user)
        {
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id),
                new Claim("GraduateId", user.Id),
                new Claim(ClaimTypes.Email, user.Email!),
                new Claim(ClaimTypes.Name, $"{user.FirstName} {user.LastName}"),
                new Claim(ClaimTypes.Role, "Graduate"),
                new Claim("UserType", user.UserType),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]!));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"],
                audience: _configuration["Jwt:Audience"],
                claims: claims,
                expires: DateTime.UtcNow.AddDays(Convert.ToDouble(_configuration["Jwt:ExpireDays"])),
                signingCredentials: credentials
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        #endregion
    }
}