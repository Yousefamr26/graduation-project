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
    public class TrainingCenterAuthService : ITrainingCenterAuthService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IConfiguration _configuration;
        private readonly ApplicationDbContext _context;
        private readonly IEmailService _emailService;

        public TrainingCenterAuthService(
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

        public async Task<Result<TrainingCenterRegisterResponse>> RegisterTrainingCenterAsync(TrainingCenterRegisterRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.City) || string.IsNullOrWhiteSpace(request.Country))
                return Result.Failure<TrainingCenterRegisterResponse>(new Error("Auth.Validation", "City and Country are required fields."));

            if (string.IsNullOrWhiteSpace(request.Name) || string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
                return Result.Failure<TrainingCenterRegisterResponse>(new Error("Auth.Validation", "Name, Email, and Password are required fields."));

            if (request.Password != request.ConfirmPassword)
                return Result.Failure<TrainingCenterRegisterResponse>(new Error("Auth.Validation", "Password and ConfirmPassword do not match."));

            if (await _unitOfWork.trainingCenterAuthRepository.UserExistsByEmailAsync(request.Email))
                return Result.Failure<TrainingCenterRegisterResponse>(AuthErrors.UserAlreadyExists);

            await _unitOfWork.BeginTransactionAsync();

            TrainingCenter? trainingCenter = null;
            ApplicationUser? savedUser = null;

            try
            {
                var user = new ApplicationUser
                {
                    UserName = request.Email,
                    Email = request.Email,
                    FirstName = request.Name,
                    LastName = "TrainingCenter",
                    UserType = "TrainingCenter",
                    PhoneNumber = request.PhoneNumber,
                    Country = request.Country,
                    City = request.City,
                    IsActive = true,
                    IsEmailVerified = false,
                    CreatedAt = DateTime.UtcNow
                };

                var userResult = await _unitOfWork.trainingCenterAuthRepository.CreateUserAsync(user, request.Password);
                if (!userResult.IsSuccess)
                    return Result.Failure<TrainingCenterRegisterResponse>(userResult.Error);

                var roleResult = await _unitOfWork.trainingCenterAuthRepository.AssignRoleAsync(user, "TrainingCenter");
                if (!roleResult.IsSuccess)
                    return Result.Failure<TrainingCenterRegisterResponse>(roleResult.Error);

                string? logoPath = null;
                if (request.OrganizationLogo != null)
                {
                    var fileName = $"{Guid.NewGuid()}{Path.GetExtension(request.OrganizationLogo.FileName)}";
                    var folderPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "Auth", "trainingcenters");
                    Directory.CreateDirectory(folderPath);
                    var savePath = Path.Combine(folderPath, fileName);

                    using var stream = new FileStream(savePath, FileMode.Create);
                    await request.OrganizationLogo.CopyToAsync(stream);

                    logoPath = $"/Auth/trainingcenters/{fileName}";
                }

                trainingCenter = new TrainingCenter
                {
                    UserId = user.Id,
                    Name = request.Name,
                    City = request.City,
                    Country = request.Country,
                    OrganizationLogo = logoPath,
                    CreatedAt = DateTime.UtcNow,
                    User = user
                };

                var trainingCenterResult = await _unitOfWork.trainingCenterAuthRepository.CreateTrainingCenterProfileAsync(trainingCenter);
                if (!trainingCenterResult.IsSuccess)
                    return Result.Failure<TrainingCenterRegisterResponse>(trainingCenterResult.Error);

                // ← ضيف entry في جدول CompanyUser عشان يقدر يعمل Roadmap
                var companyEntry = new CompanyUser
                {
                    Id = user.Id,
                    UserId = user.Id,
                    OrganizationName = request.Name,
                    OrganizationLogo = logoPath,
                    Country = request.Country,
                    City = request.City,
                    User = user
                };
                await _unitOfWork.companyAuthRepository.CreateCompanyProfileAsync(companyEntry);

                await _unitOfWork.SaveChangesAsync();
                await _unitOfWork.CommitTransactionAsync();

                savedUser = user;
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync();
                return Result.Failure<TrainingCenterRegisterResponse>(new Error("Auth.Exception",
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

                await _emailService.SendOtpEmailAsync(savedUser.Email!, savedUser.FirstName ?? "", otp);
            }
            catch (Exception emailEx)
            {
                return Result.Failure<TrainingCenterRegisterResponse>(
                    new Error("Auth.EmailFailed", $"Registration successful but email failed: {emailEx.Message}"));
            }

            var response = new TrainingCenterRegisterResponse(
                Id: trainingCenter!.Id,
                Name: trainingCenter.Name,
                Email: savedUser.Email!,
                PhoneNumber: savedUser.PhoneNumber,
                Country: trainingCenter.Country,
                City: trainingCenter.City,
                OrganizationLogoUrl: trainingCenter.OrganizationLogo,
                CreatedAt: trainingCenter.CreatedAt
            );

            return Result.Success(response);
        }

        #endregion

        #region Email Verification

        public async Task<Result<string>> VerifyEmailAsync(string email, string otp)
        {
            var user = await _unitOfWork.trainingCenterAuthRepository.GetUserByEmailAsync(email);
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
            var user = await _unitOfWork.trainingCenterAuthRepository.GetUserByEmailAsync(email);
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
                await _emailService.SendOtpEmailAsync(user.Email!, user.FirstName ?? "", otp);
            }
            catch (Exception emailEx)
            {
                return Result.Failure<string>(new Error("Auth.EmailFailed", $"Failed to send OTP: {emailEx.Message}"));
            }

            return Result.Success("OTP sent successfully.");
        }

        #endregion

        #region Login

        public async Task<Result<LoginResponse<TrainingCenterRegisterResponse>>> LoginAsync(LoginRequest request)
        {
            try
            {
                var user = await _unitOfWork.trainingCenterAuthRepository.GetUserByEmailAsync(request.Email);
                if (user == null)
                    return Result.Failure<LoginResponse<TrainingCenterRegisterResponse>>(AuthErrors.InvalidCredentials);

                if (user.UserType != "TrainingCenter")
                    return Result.Failure<LoginResponse<TrainingCenterRegisterResponse>>(AuthErrors.AccountTypeNotMatch);

                if (!user.IsActive)
                    return Result.Failure<LoginResponse<TrainingCenterRegisterResponse>>(AuthErrors.AccountNotActive);

                if (!user.IsEmailVerified)
                    return Result.Failure<LoginResponse<TrainingCenterRegisterResponse>>(
                        new Error("Auth.EmailNotVerified", "Please verify your email before logging in."));

                var isPasswordValid = await _unitOfWork.trainingCenterAuthRepository.CheckPasswordAsync(user, request.Password);
                if (!isPasswordValid)
                    return Result.Failure<LoginResponse<TrainingCenterRegisterResponse>>(AuthErrors.InvalidCredentials);

                user.UpdatedAt = DateTime.UtcNow;
                await _unitOfWork.SaveChangesAsync();

                var trainingCenterProfile = await _unitOfWork.trainingCenterAuthRepository.GetTrainingCenterProfileByUserIdAsync(user.Id);
                var token = GenerateJwtToken(user, trainingCenterProfile!.Id);

                var response = new TrainingCenterRegisterResponse(
                    Id: trainingCenterProfile!.Id,
                    Name: trainingCenterProfile.Name,
                    Email: user.Email!,
                    PhoneNumber: user.PhoneNumber,
                    Country: trainingCenterProfile.Country,
                    City: trainingCenterProfile.City,
                    OrganizationLogoUrl: trainingCenterProfile.OrganizationLogo,
                    CreatedAt: trainingCenterProfile.CreatedAt
                );

                return Result.Success(new LoginResponse<TrainingCenterRegisterResponse>(token, response));
            }
            catch (Exception ex)
            {
                return Result.Failure<LoginResponse<TrainingCenterRegisterResponse>>(new Error("Auth.LoginException",
                    "An error occurred during login: " + ex.Message));
            }
        }

        #endregion

        #region JWT

        private string GenerateJwtToken(ApplicationUser user, int trainingCenterId)
        {
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id),
                new Claim(ClaimTypes.Email, user.Email!),
                new Claim(ClaimTypes.Name, user.FirstName ?? ""),
                new Claim(ClaimTypes.Role, "TrainingCenter"),
                new Claim("UserType", user.UserType),
                new Claim("TrainingCenterId", trainingCenterId.ToString()),
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