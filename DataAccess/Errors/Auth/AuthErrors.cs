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

        public static readonly Error InvalidCredentials =
            new("Auth.InvalidCredentials", "Email or password is incorrect");

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


        

    }
}
