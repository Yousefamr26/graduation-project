using DataAccess.Abstractions;

namespace Business_Logic.Errors
{
    public static class AuthErrors
    {
        public static readonly Error UserCreationFailed =
            new("Auth.UserCreationFailed", "Failed to create user");

        public static readonly Error UserRoleAssignmentFailed =
            new("Auth.UserRoleFailed", "Failed to assign role to user");

        public static readonly Error UserAlreadyExists =
            new("Auth.UserExists", "A user with this email already exists");

        public static readonly Error CompanyCreationFailed =
            new("Auth.CompanyCreationFailed", "Failed to create company profile");

        public static readonly Error CompanyNotFound =
            new("Auth.CompanyNotFound", "Company not found with the given ID");

        public static readonly Error StudentCreationFailed =
            new("Auth.StudentCreationFailed", "Failed to create student profile");

        public static readonly Error GraduateCreationFailed =
            new("Auth.GraduateCreationFailed", "Failed to create graduate profile");

        public static readonly Error TrainingCenterCreationFailed =
            new("Auth.TrainingCenterCreationFailed", "Failed to create training center profile");

        public static readonly Error InvalidUserType =
            new("Auth.InvalidUserType", "User type must be Student, Graduate, Company, or TrainingCenter");

        public static readonly Error NullOrEmptyField =
            new("Auth.NullOrEmptyField", "Required field is missing or empty");

        public static readonly Error InvalidCredentials =
            new("Auth.InvalidCredentials", "Email or password is incorrect");

        public static readonly Error UserNotFound =
            new("Auth.UserNotFound", "User not found with the given email");

        public static readonly Error AccountTypeNotMatch =
            new("Auth.AccountTypeNotMatch", "This account is not of the selected type");

        public static readonly Error AccountNotActive =
            new("Auth.AccountNotActive", "This account is not active. Please contact support");

        public static readonly Error AccountLockedOut =
            new("Auth.AccountLockedOut", "Account is locked due to multiple failed login attempts");

        public static readonly Error EmailNotVerified =
            new("Auth.EmailNotVerified", "Email address is not verified");

        public static readonly Error LoginFailed =
            new("Auth.LoginFailed", "Login failed. Please try again");
    }
}